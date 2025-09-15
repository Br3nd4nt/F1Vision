#!/usr/bin/env python3
"""
Build RaceData and TrackLayoutModel JSON matching the provided Swift models.
Outputs:
 - track_layout.json (TrackLayoutModel)
 - race_data.json (RaceData)
"""

import json
import os
from dataclasses import dataclass, asdict
from typing import Any, Dict, List, Tuple
from datetime import datetime, timezone

import numpy as np
import pandas as pd
import fastf1

# FastF1 setup
fastf1.Cache.enable_cache(".fastf1_cache")
fastf1.set_log_level("ERROR")


def ensure_hex(color_str: str) -> str:
    if not isinstance(color_str, str):
        return "#000000"
    color = color_str.strip()
    if not color:
        return "#000000"
    if not color.startswith("#"):
        color = "#" + color
    if len(color) == 4:
        color = "#" + "".join([c * 2 for c in color[1:]])
    return color[:7]


def build_track_layout(session: fastf1.core.Session, track_id: str, track_name: str) -> Dict[str, Any]:
    fastest = session.laps.pick_fastest()
    tel = fastest.get_telemetry().add_distance()

    x = tel["X"].astype(float).to_numpy()
    y = tel["Y"].astype(float).to_numpy()
    d = tel["Distance"].astype(float).to_numpy() if "Distance" in tel.columns else np.linspace(0.0, 0.0, num=len(x))
    # Swift expects an array of objects with x, y, and distance
    points = [{"x": float(a), "y": float(b), "distance": float(c)} for a, b, c in zip(x, y, d)]

    min_x, max_x = float(np.nanmin(x)), float(np.nanmax(x))
    min_y, max_y = float(np.nanmin(y)), float(np.nanmax(y))
    length = float(np.nanmax(tel["Distance"])) if "Distance" in tel.columns else 0.0

    # Start/finish line at distance 0.0 as reference (consistent with Distance)
    start_finish_distance = 0.0

    model = {
        "id": track_id,
        "name": track_name,
        "length": length,
        "points": points,
        "boundingBox": {
            "minX": min_x,
            "minY": min_y,
            "maxX": max_x,
            "maxY": max_y,
        },
        "startFinishLine": {
            "distance": start_finish_distance,
        },
    }
    return model


def build_driver_catalog(session: fastf1.core.Session, drivers: List[str]) -> Dict[str, Dict[str, Any]]:
    catalog: Dict[str, Dict[str, Any]] = {}
    for code in drivers:
        try:
            info = session.get_driver(code)
        except Exception:
            info = {}
        code_str = str(code)

        # Number
        number = None
        try:
            number = int(
                info.get("DriverNumber")
                or info.get("Number")
                or session.laps[session.laps["Driver"] == code_str]["DriverNumber"].dropna().iloc[0]
            )
        except Exception:
            pass

        # Name/team/color
        first = info.get("FirstName") or ""
        last = info.get("LastName") or info.get("LastNameUpper") or ""
        name = f"{first} {last}".strip() or info.get("FullName") or code_str
        team = info.get("TeamName") or info.get("Team") or ""
        team_color = ensure_hex(info.get("TeamColor") or "")
        country = (info.get("CountryCode") or info.get("Country") or "").upper()

        driver_id = f"{code_str}{number}" if number is not None else code_str
        catalog[code_str] = {
            "id": driver_id,
            "name": name,
            "code": code_str,
            "number": int(number) if number is not None else 0,
            "team": team,
            "teamColorHex": team_color,
            "country": country,
        }
    return catalog


def normalize_dt(series: pd.Series) -> pd.Series:
    try:
        if hasattr(series.dt, "tz") and series.dt.tz is not None:
            return series.dt.tz_convert("UTC").dt.tz_localize(None)
        else:
            return series.dt.tz_localize(None)
    except Exception:
        return pd.to_datetime(series)


def build_race_data(session: fastf1.core.Session, track_name: str, year: int, freq: str = "200ms") -> Dict[str, Any]:
    laps = session.laps.copy()
    laps = laps[laps["LapTime"].notna()].copy()
    if laps.empty:
        raise ValueError("No valid laps with timing found in this session.")

    laps["LapEndTime"] = laps["LapStartTime"] + laps["LapTime"]

    drivers = sorted(laps["Driver"].dropna().astype(str).unique())
    driver_catalog = build_driver_catalog(session, drivers)

    # Prepare per-driver telemetry with absolute Date
    tel_min: List[pd.Timestamp] = []
    tel_max: List[pd.Timestamp] = []

    def build_driver_timeseries(driver_code: str) -> pd.DataFrame:
        id_for_pick = int(driver_code) if driver_code.isdigit() else driver_code
        tel = session.laps.pick_drivers(id_for_pick).get_telemetry()
        tel = tel.sort_values("SessionTime")
        keep = [c for c in ["SessionTime", "Date", "Speed", "DRS", "LapNumber", "X", "Y", "Z"] if c in tel.columns]
        tel = tel[keep].copy()

        # Backfill LapNumber if missing
        if "LapNumber" not in tel.columns:
            driver_laps = laps[laps["Driver"] == driver_code][["LapNumber", "LapStartTime", "LapEndTime"]].copy()
            tel = pd.merge_asof(
                tel.sort_values("SessionTime"),
                driver_laps.sort_values("LapStartTime"),
                left_on="SessionTime",
                right_on="LapStartTime",
                direction="backward",
                tolerance=pd.Timedelta("60s"),
            )
            tel["LapNumber"] = tel["LapNumber"].ffill()

        # Absolute Date fallback from session.t0_date
        if "Date" not in tel.columns or tel["Date"].isna().all():
            t0 = getattr(session, "t0_date", None)
            if t0 is None:
                t0 = pd.Timestamp(datetime.now(timezone.utc))
            tel["Date"] = pd.to_datetime(t0) + tel["SessionTime"]

        tel_min.append(tel["Date"].min())
        tel_max.append(tel["Date"].max())

        tel["Driver"] = driver_code
        return tel

    per_driver_raw = [build_driver_timeseries(d) for d in drivers]
    abs_start = pd.Series(tel_min).min()
    abs_end = pd.Series(tel_max).max()
    timeline = pd.date_range(start=abs_start, end=abs_end, freq=freq)

    # Resample each driver onto the absolute timeline
    def resample_driver(df: pd.DataFrame) -> pd.DataFrame:
        df = df.set_index("Date").sort_index()
        df = df.reindex(timeline, method="nearest", tolerance=pd.Timedelta("300ms")).reset_index()
        df = df.rename(columns={"index": "Date"})
        return df

    per_driver = [resample_driver(df) for df in per_driver_raw]
    ts = pd.concat(per_driver, ignore_index=True)
    ts = ts.sort_values(["Date", "Driver"])  # global order

    # Attach lap info
    if "LapNumber" in ts.columns:
        ts["LapNumber"] = ts.groupby("Driver")["LapNumber"].ffill().bfill()
    else:
        ts["LapNumber"] = 0

    # Build positions from official pos data if available
    try:
        pos = session.get_pos_data()[["Date", "Driver", "Position"]].dropna()
        pos["Driver"] = pos["Driver"].astype(str)
        pos["Date"] = normalize_dt(pos["Date"])  # tz normalize
        ts["Date"] = normalize_dt(ts["Date"])    # tz normalize
        def merge_asof_by(left: pd.DataFrame, right: pd.DataFrame, by_col: str, on_col: str,
                          direction: str = "nearest", tolerance: pd.Timedelta | None = None) -> pd.DataFrame:
            merged_frames = []
            for key, ldf in left.groupby(by_col, sort=False):
                rdf = right[right[by_col] == key]
                if rdf.empty:
                    ldf2 = ldf.sort_values(on_col).copy()
                    ldf2[by_col] = key
                    merged_frames.append(ldf2)
                    continue
                ldf2 = ldf.sort_values(on_col)
                rdf2 = rdf.sort_values(on_col)
                merged = pd.merge_asof(ldf2, rdf2, on=on_col, direction=direction, tolerance=tolerance)
                merged[by_col] = key
                merged_frames.append(merged)
            return pd.concat(merged_frames, ignore_index=False)
        ts = merge_asof_by(ts, pos.rename(columns={"Date": "PosDate"}).rename(columns={"PosDate": "Date"}),
                           by_col="Driver", on_col="Date", direction="nearest", tolerance=pd.Timedelta("400ms"))
    except Exception:
        pass

    if "Position" not in ts.columns or ts["Position"].isna().all():
        # fallback order by speed descending at each timestamp to avoid ties
        ts["Position"] = (
            ts.sort_values(["Date", "Speed"], ascending=[True, False])
              .groupby("Date").cumcount() + 1
        )

    # Sector inference: split track into thirds by lap progress if available
    ts["sector"] = 1
    if "LapNumber" in ts.columns:
        # try using X,Y movement proxy to build distance along lap
        if {"X", "Y"}.issubset(ts.columns):
            def lap_distance(g: pd.DataFrame) -> pd.DataFrame:
                g = g.sort_values("Date").copy()
                dx = g["X"].diff()
                dy = g["Y"].diff()
                step = np.sqrt((dx.fillna(0)) ** 2 + (dy.fillna(0)) ** 2)
                g["distance"] = step.cumsum()
                return g
            ts = ts.groupby(["Driver", "LapNumber"], include_groups=False, group_keys=False).apply(lap_distance)
            # sector by thirds
            maxd = ts.groupby(["Driver", "LapNumber"])['distance'].transform('max').replace(0, np.nan)
            frac = ts['distance'] / maxd
            ts['sector'] = np.where(frac <= 1/3, 1, np.where(frac <= 2/3, 2, 3))
            ts['sector'] = ts['sector'].fillna(1).astype(int)

    # Build snapshots grouped by absolute Date
    snapshots: List[Dict[str, Any]] = []
    for dt, frame in ts.groupby("Date"):
        frame = frame.sort_values("Position")
        driver_states: List[Dict[str, Any]] = []
        for _, r in frame.iterrows():
            code = str(r["Driver"])
            info = driver_catalog.get(code, {
                "id": code, "name": code, "code": code,
                "number": 0, "team": "", "teamColorHex": "#000000", "country": ""
            })
            tyre_state = {
                "compound": "unknown",
                "age": 0,
                "fresh": False,
            }
            driver_states.append({
                "driverId": info,
                "lap": int(r["LapNumber"]) if pd.notna(r["LapNumber"]) else 0,
                "position": int(r["Position"]) if pd.notna(r["Position"]) else 0,
                "distance": float(r.get("distance", 0.0)) if pd.notna(r.get("distance", np.nan)) else 0.0,
                "speed": float(r.get("Speed", 0.0)) if pd.notna(r.get("Speed", np.nan)) else 0.0,
                "sector": int(r.get("sector", 1)) if pd.notna(r.get("sector", np.nan)) else 1,
                "intervalToLeader": None,  # can be filled from timing if desired
                "intervalToAhead": None,   # can be filled from timing if desired
                "pitStatus": False,
                "drsActive": bool(r.get("DRS", False)) if pd.notna(r.get("DRS", np.nan)) else False,
                "tyre": tyre_state,
            })
        snapshots.append({
            "timestamp": pd.Timestamp(dt).isoformat(timespec="seconds"),
            "lap": int(frame["LapNumber"].median()) if not frame["LapNumber"].isna().all() else 0,
            "driverStates": driver_states,
        })

    race_data = {
        "raceId": f"{track_name.lower()}_{year}",
        "trackName": track_name,
        "year": int(year),
        "totalSnapshots": len(snapshots),
        "totalDrivers": len(drivers),
        "generatedAt": datetime.now(timezone.utc).isoformat(timespec="milliseconds"),
        "raceSnapshots": snapshots,
    }
    return race_data


def main():
    import argparse
    parser = argparse.ArgumentParser(description="Build RaceData and TrackLayoutModel JSON")
    parser.add_argument("--year", type=int, default=2024)
    parser.add_argument("--track", type=str, default="Monaco")
    parser.add_argument("--freq", type=str, default="200ms", help="Snapshot frequency, e.g., 200ms, 500ms, 1s")
    parser.add_argument("--outdir", type=str, default="race_output")
    args = parser.parse_args()

    print(f"Loading session {args.year} {args.track} (Race)...")
    session = fastf1.get_session(args.year, args.track, "R")
    session.load(telemetry=True)

    os.makedirs(args.outdir, exist_ok=True)

    # Track layout
    track_id = f"{args.track.lower()}_{args.year}"
    track_model = build_track_layout(session, track_id=track_id, track_name=args.track)
    with open(os.path.join(args.outdir, "track_layout.json"), "w") as f:
        json.dump(track_model, f, indent=2)
    print(f"Saved {args.outdir}/track_layout.json")

    # Race data snapshots
    race_data = build_race_data(session, track_name=args.track, year=args.year, freq=args.freq)
    with open(os.path.join(args.outdir, "race_data.json"), "w") as f:
        json.dump(race_data, f, indent=2)
    print(f"Saved {args.outdir}/race_data.json")


if __name__ == "__main__":
    main()
