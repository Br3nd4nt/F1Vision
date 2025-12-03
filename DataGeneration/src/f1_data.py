# CODE FROM https://github.com/IAmTomShaw/f1-race-replay
# CHECK HIM OUT!!!!!

import os
import fastf1
import fastf1.plotting
import numpy as np
import json
from datetime import timedelta

from src.lib.tyres import get_tyre_compound_int

class RaceTelemetryProcessor:
    FPS = 25
    DT = 1 / FPS

    def __init__(self, year, round_number, cache_dir=".fastf1-cache", output_dir="computed_data"):
        self.year = year
        self.round_number = round_number
        self.cache_dir = cache_dir
        self.output_dir = output_dir
        self.enable_cache()

    # --------------------------
    #  CACHE
    # --------------------------
    def enable_cache(self):
        if not os.path.exists(self.cache_dir):
            print("Creating FastF1 cache directory at:", self.cache_dir)
            os.makedirs(self.cache_dir)
        print("Using FastF1 cache at:", self.cache_dir)
        fastf1.Cache.enable_cache(self.cache_dir)
        fastf1.set_log_level("ERROR")

    # --------------------------
    #  LOAD SESSION
    # --------------------------
    def load_race_session(self):
        print("Loading race session for year", self.year, "round", self.round_number)
        self.session = fastf1.get_session(self.year, self.round_number, "R")
        self.session.load(telemetry=True)
        self.event_name = str(self.session).replace(" ", "_")
        return self.session
    

     # --------------------------
    #  TRACK LAYOUT GENERATION
    # --------------------------
    def generate_track_layout(self, track_width=200):
        print("Generating track layout for ", self.event_name)
        lap = self.session.laps.pick_fastest().get_telemetry()
        plot_x_ref = lap["X"].to_numpy()
        plot_y_ref = lap["Y"].to_numpy()
        d_lap = lap["Distance"].to_numpy()

        dx = np.gradient(plot_x_ref)
        dy = np.gradient(plot_y_ref)

        norm = np.sqrt(dx**2 + dy**2)
        norm[norm == 0] = 1.0
        dx /= norm
        dy /= norm

        nx = -dy
        ny = dx

        x_outer = plot_x_ref + nx * (track_width / 2)
        y_outer = plot_y_ref + ny * (track_width / 2)
        x_inner = plot_x_ref - nx * (track_width / 2)
        y_inner = plot_y_ref - ny * (track_width / 2)

        x_min = min(plot_x_ref.min(), x_inner.min(), x_outer.min())
        x_max = max(plot_x_ref.max(), x_inner.max(), x_outer.max())
        y_min = min(plot_y_ref.min(), y_inner.min(), y_outer.min())
        y_max = max(plot_y_ref.max(), y_inner.max(), y_outer.max())

        track_points = [
            {
                "x": float(x_ref),
                "y": float(y_ref),
                "x_inner": float(x_in),
                "y_inner": float(y_in),
                "x_outer": float(x_out),
                "y_outer": float(y_out),
                "distance": float(dist),
            }
            for (x_ref, y_ref, x_in, y_in, x_out, y_out, dist)
            in zip(plot_x_ref, plot_y_ref, x_inner, y_inner, x_outer, y_outer, d_lap)
        ]

        if not os.path.exists(self.output_dir):
            os.makedirs(self.output_dir)

        with open(f"{self.output_dir}/{self.event_name}_track_layout.json", "w") as f:
            json.dump({
                "track_name": self.event_name,
                "track_points": track_points,
                "world_bounds": {
                    "x_min": float(x_min),
                    "x_max": float(x_max),
                    "y_min": float(y_min),
                    "y_max": float(y_max),
                },
            }, f, indent=2)

        print("Track layout saved.")

    # --------------------------
    #  MAIN TELEMETRY PARSER
    # --------------------------
    def get_race_telemetry(self):
        # Load if exists
        try:
            if "--refresh-data" not in os.sys.argv:
                with open(f"{self.output_dir}/{self.event_name}_race_telemetry.json", "r") as f:
                    print("Loaded cached telemetry data.")
                    return json.load(f)
        except FileNotFoundError:
            pass


        drivers = self.session.drivers
        driver_codes = {
            num: self.session.get_driver(num)["Abbreviation"]
            for num in drivers
        }

        driver_data = {}
        global_t_min = None
        global_t_max = None

        # --------------------------
        #  LOAD RAW TELEMETRY
        # --------------------------
        for driver_no in drivers:
            code = driver_codes[driver_no]
            print("Getting telemetry for:", code)

            laps_driver = self.session.laps.pick_drivers(driver_no)
            if laps_driver.empty:
                continue

            t_all = []
            x_all = []
            y_all = []
            race_dist_all = []
            rel_dist_all = []
            lap_numbers = []
            tyre_compounds = []
            speed_all = []
            gear_all = []
            drs_all = []

            total_dist_so_far = 0.0

            for _, lap in laps_driver.iterlaps():
                lap_tel = lap.get_telemetry()
                if lap_tel.empty:
                    continue

                lap_number = lap.LapNumber
                tyre_as_int = get_tyre_compound_int(lap.Compound)

                t_lap = lap_tel["SessionTime"].dt.total_seconds().to_numpy()
                x_lap = lap_tel["X"].to_numpy()
                y_lap = lap_tel["Y"].to_numpy()
                d_lap = lap_tel["Distance"].to_numpy()
                rd_lap = lap_tel["RelativeDistance"].to_numpy()
                speed_kph = lap_tel["Speed"].to_numpy()
                gear = lap_tel["nGear"].to_numpy()
                drs = lap_tel["DRS"].to_numpy()

                d_lap -= d_lap.min()
                lap_length = d_lap.max()

                race_d_lap = total_dist_so_far + d_lap
                total_dist_so_far += lap_length

                t_all.append(t_lap)
                x_all.append(x_lap)
                y_all.append(y_lap)
                race_dist_all.append(race_d_lap)
                rel_dist_all.append(rd_lap)
                lap_numbers.append(np.full_like(t_lap, lap_number))
                tyre_compounds.append(np.full_like(t_lap, tyre_as_int))
                speed_all.append(speed_kph)
                gear_all.append(gear)
                drs_all.append(drs)

            if not t_all:
                continue

            t_all = np.concatenate(t_all)
            x_all = np.concatenate(x_all)
            y_all = np.concatenate(y_all)
            race_dist_all = np.concatenate(race_dist_all)
            rel_dist_all = np.concatenate(rel_dist_all)
            lap_numbers = np.concatenate(lap_numbers)
            tyre_compounds = np.concatenate(tyre_compounds)
            speed_all = np.concatenate(speed_all)
            gear_all = np.concatenate(gear_all)
            drs_all = np.concatenate(drs_all)

            order = np.argsort(t_all)
            t_all = t_all[order]
            x_all = x_all[order]
            y_all = y_all[order]
            race_dist_all = race_dist_all[order]
            rel_dist_all = rel_dist_all[order]
            lap_numbers = lap_numbers[order]
            tyre_compounds = tyre_compounds[order]
            speed_all = speed_all[order]
            gear_all = gear_all[order]
            drs_all = drs_all[order]

            driver_data[code] = {
                "t": t_all,
                "x": x_all,
                "y": y_all,
                "dist": race_dist_all,
                "rel_dist": rel_dist_all,
                "lap": lap_numbers,
                "tyre": tyre_compounds,
                "speed": speed_all,
                "gear": gear_all,
                "drs": drs_all,
            }

            # Update global time window
            t_min = t_all.min()
            t_max = t_all.max()
            global_t_min = t_min if global_t_min is None else min(global_t_min, t_min)
            global_t_max = t_max if global_t_max is None else max(global_t_max, t_max)

        # --------------------------
        #  RESAMPLING PHASE
        # --------------------------
        timeline = np.arange(global_t_min, global_t_max, self.DT) - global_t_min

        resampled = {}

        for code, d in driver_data.items():
            t = d["t"] - global_t_min
            order = np.argsort(t)

            def interp(key):
                return np.interp(timeline, t[order], d[key][order])

            resampled[code] = {
                "t": timeline,
                "x": interp("x"),
                "y": interp("y"),
                "dist": interp("dist"),
                "rel_dist": interp("rel_dist"),
                "lap": interp("lap"),
                "tyre": interp("tyre"),
                "speed": interp("speed"),
                "gear": interp("gear"),
                "drs": interp("drs"),
            }

        # --------------------------
        #  TRACK STATUS PARSING
        # --------------------------
        track_status = self.session.track_status
        formatted_status = []

        for status in track_status.to_dict("records"):
            seconds = timedelta.total_seconds(status["Time"])
            start_time = seconds - global_t_min

            if formatted_status:
                formatted_status[-1]["end_time"] = start_time

            formatted_status.append({
                "status": status["Status"],
                "start_time": start_time,
                "end_time": None,
            })

        # --------------------------
        #  BUILD FRAMES
        # --------------------------
        frames = []

        for i, t in enumerate(timeline):
            snapshot = [
                {
                    "code": code,
                    "dist": float(d["dist"][i]),
                    "x": float(d["x"][i]),
                    "y": float(d["y"][i]),
                    "lap": int(round(d["lap"][i])),
                    "rel_dist": float(d["rel_dist"][i]),
                    "tyre": d["tyre"][i],
                    "speed": d["speed"][i],
                    "gear": int(d["gear"][i]),
                    "drs": int(d["drs"][i]),
                }
                for code, d in resampled.items()
            ]

            if not snapshot:
                continue

            snapshot.sort(key=lambda r: r["dist"], reverse=True)
            leader = snapshot[0]

            frame_data = {
                car["code"]: {
                    "x": car["x"],
                    "y": car["y"],
                    "dist": car["dist"],
                    "lap": car["lap"],
                    "rel_dist": round(car["rel_dist"], 6),
                    "tyre": car["tyre"],
                    "position": idx + 1,
                    "speed": car["speed"],
                    "gear": car["gear"],
                    "drs": car["drs"],
                }
                for idx, car in enumerate(snapshot)
            }

            frames.append({
                "t": float(t),
                "lap": leader["lap"],
                "drivers": frame_data,
            })

        # Save output
        if not os.path.exists(self.output_dir):
            os.makedirs(self.output_dir)

        out = {
            "frames": frames,
            "driver_colors": self.get_driver_colors(self.session),
            "track_statuses": formatted_status,
        }

        with open(f"{self.output_dir}/{self.event_name}_race_telemetry.json", "w") as f:
            json.dump(out, f, indent=2)

        print("Telemetry saved.")
        return out

    def get_track_layout_path(self):
        return f"{self.output_dir}/{self.event_name}_track_layout.json"
    
    def get_telemetry_path(self):
        return f"{self.output_dir}/{self.event_name}_race_telemetry.json"
    
    def check_track_layout_exists(self):
        return os.path.exists(self.get_track_layout_path())
    
    def check_telemetry_exists(self):
        return os.path.exists(self.get_telemetry_path())

    # --------------------------
    #  DRIVER COLORS
    # --------------------------
    def get_driver_colors(self, session):
        color_mapping = fastf1.plotting.get_driver_color_mapping(session)
        rgb_colors = {}

        for driver, hex_color in color_mapping.items():
            hex_color = hex_color.lstrip("#")
            rgb_colors[driver] = tuple(
                int(hex_color[i:i + 2], 16) for i in (0, 2, 4)
            )

        return rgb_colors