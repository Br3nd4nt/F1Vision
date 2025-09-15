import pandas as pd
import numpy as np
from datetime import datetime, timezone
import fastf1
import fastf1.core
import numpy as np
import pandas as pd
from IPython.display import display
import json

fastf1.Cache.enable_cache('.fastf1_cache/')
year = 2025
track = "Monaco"
session = fastf1.get_session(year, track, "R")
session.load(telemetry=True)
drivers = session.drivers

def ensure_hex(color_str: str) -> str:
    if not isinstance(color_str, str):
        return "#000000"
    color = color_str.strip()
    if not color:
        return "#000000"
    if not color.startswith("#"):
        color = "#" + color
    if len(color) == 4:  # e.g. #abc -> #aabbcc
        color = "#" + "".join([c*2 for c in color[1:]])
    return color[:7]

def build_driver_catalog(session, drivers):
    catalog = {}
    for code in drivers:
        try:
            info = session.get_driver(code)
        except Exception:
            info = {}
        code_str = str(code)
        number = None
        try:
            number = int(info.get("DriverNumber") or info.get("Number") or
                         session.laps[session.laps["Driver"] == code_str]["DriverNumber"].dropna().iloc[0])
        except Exception:
            pass
        first = info.get("FirstName") or ""
        last = info.get("LastName") or info.get("LastNameUpper") or ""
        name = f"{first} {last}".strip() if (first or last) else info.get("FullName") or code_str
        team = info.get("TeamName") or info.get("Team") or ""
        team_color = ensure_hex(info.get("TeamColor") or "")
        country = (info.get("CountryCode") or info.get("Country") or "").upper()
        driver_id = f"{code_str}{number}" if number is not None else code_str
        catalog[code_str] = {
            "id": driver_id,
            "name": name,
            "code": code_str,
            "number": number,
            "team": team,
            "teamColorHex": team_color,
            "country": country
        }
    return catalog

def build_race_payload(session, race_id: str, track_name: str, year: int, freq: str = "100ms"):
    # Base laps; restrict to laps with valid timing
    laps = session.laps.copy()
    laps = laps[laps["LapTime"].notna()].copy()
    if laps.empty:
        raise ValueError("No valid laps with timing found in this session.")

    laps["LapEndTime"] = laps["LapStartTime"] + laps["LapTime"]

    # Drivers present
    drivers = sorted(laps["Driver"].dropna().astype(str).unique())
    driver_catalog = build_driver_catalog(session, drivers)

    # Compute per-lap gaps at S/F (exact at lap end) without groupby-apply
    laps_sorted = laps.sort_values(["LapNumber", "LapEndTime"]).copy()
    laps_sorted["IntervalToAhead"] = laps_sorted.groupby("LapNumber")["LapEndTime"].diff()
    min_end_per_lap = laps_sorted.groupby("LapNumber")["LapEndTime"].transform("min")
    laps_sorted["IntervalToLeader"] = laps_sorted["LapEndTime"] - min_end_per_lap
    lap_gaps = laps_sorted[["Driver", "LapNumber", "LapEndTime", "IntervalToAhead", "IntervalToLeader"]]

    # Build a global absolute-time timeline using telemetry Date
    # Prefer absolute 'Date' from telemetry (UTC timestamps)
    # Gather telemetry per driver first to detect min/max Date
    tel_min = []
    tel_max = []

    def build_driver_timeseries(driver_code: str) -> pd.DataFrame:
        # FastF1 drivers can be numeric (race number) or code; ensure correct type for picker
        id_for_pick = int(driver_code) if str(driver_code).isdigit() else driver_code
        tel = session.laps.pick_drivers(id_for_pick).get_telemetry()
        tel = tel.sort_values("SessionTime")
        keep = [c for c in ["SessionTime","Date","Speed","DRS","LapNumber","X","Y","Z"] if c in tel.columns]
        tel = tel[keep].copy()
        # LapNumber mapping if missing
        if "LapNumber" not in tel.columns:
            driver_laps = laps[laps["Driver"] == driver_code][["LapNumber","LapStartTime","LapEndTime"]].copy()
            tel = pd.merge_asof(
                tel.sort_values("SessionTime"),
                driver_laps.sort_values("LapStartTime"),
                left_on="SessionTime",
                right_on="LapStartTime",
                direction="backward",
                tolerance=pd.Timedelta("60s")
            )
            tel["LapNumber"] = tel["LapNumber"].ffill()

        if "Date" not in tel.columns or tel["Date"].isna().all():
            # Fallback: construct absolute time from session t0_date + SessionTime
            t0 = getattr(session, "t0_date", None)
            if t0 is None:
                # last resort: use today UTC
                t0 = pd.Timestamp(datetime.now(timezone.utc))
            tel["Date"] = pd.to_datetime(t0) + tel["SessionTime"]

        tel_min.append(tel["Date"].min())
        tel_max.append(tel["Date"].max())

        tel["Driver"] = driver_code

        # Attach lap meta for sectors/tyre/pit
        driver_laps = laps[laps["Driver"] == driver_code][[
            "LapNumber","LapStartTime","LapTime","Sector1Time","Sector2Time",
            "Compound","TyreLife","PitOutTime","PitInTime"
        ]].copy()

        tel = pd.merge_asof(
            tel.sort_values("SessionTime"),
            driver_laps.sort_values("LapStartTime"),
            left_on="SessionTime",
            right_on="LapStartTime",
            direction="backward",
            tolerance=pd.Timedelta("60s")
        )
        # Create boolean pit flags derived from timing columns (if present)
        if "PitOutTime" in tel.columns:
            tel["PitOut"] = tel["PitOutTime"].notna()
        else:
            tel["PitOut"] = False
        if "PitInTime" in tel.columns:
            tel["PitIn"] = tel["PitInTime"].notna()
        else:
            tel["PitIn"] = False
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

    per_driver = []
    for df in per_driver_raw:
        rd = resample_driver(df)
        per_driver.append(rd)
    ts = pd.concat(per_driver, ignore_index=True)
    ts = ts.sort_values(["Date","Driver"])

    # Sector inference prerequisites
    ts["LapTime"] = ts.get("LapTime", pd.NaT)
    ts["Sector1Time"] = ts.get("Sector1Time", pd.NaT)
    ts["Sector2Time"] = ts.get("Sector2Time", pd.NaT)
    ts["LapTime"] = ts["LapTime"].ffill()
    ts["Sector1Time"] = ts["Sector1Time"].ffill()
    ts["Sector2Time"] = ts["Sector2Time"].ffill()

    # Rebuild SessionTime from Date for elapsed/sector
    t0 = getattr(session, "t0_date", None)
    if t0 is not None:
        ts["SessionTime"] = (ts["Date"] - pd.to_datetime(t0))
        # Ensure LapNumber is stable after resampling
        if "LapNumber" in ts.columns:
            ts["LapNumber"] = ts.groupby("Driver")["LapNumber"].ffill().bfill()
        else:
            ts["LapNumber"] = 0
        # Derive per-lap start time from minimum SessionTime within each driver/lap
        ts["lapStartSessionTime"] = ts.groupby(["Driver","LapNumber"])['SessionTime'].transform('min')
        elapsed = ts["SessionTime"] - ts["lapStartSessionTime"]
        s1 = ts["Sector1Time"]
        s2 = ts["Sector2Time"]
        ts["sector"] = np.where(elapsed <= s1, 1,
                           np.where(elapsed <= (s1 + s2), 2, 3))
        ts["sector"] = ts["sector"].fillna(1).astype(int)
    else:
        ts["sector"] = 1

    # Attach discrete lap-end gaps (exact) and carry inside lap
    lap_gaps2 = lap_gaps.rename(columns={"LapEndTime":"SessionTime"}).copy()
    # Build absolute time for lap ends to align with Date
    if t0 is None:
        # approximate absolute time for lap ends from sampled points (nearest Date per driver+SessionTime)
        # Build a helper to map SessionTime->Date per driver from ts
        helper = ts.dropna(subset=["SessionTime"]).sort_values(["Driver","SessionTime"])[["Driver","SessionTime","Date"]]
        lap_gaps2 = pd.merge_asof(
            lap_gaps2.sort_values(["Driver","SessionTime"]),
            helper.sort_values(["Driver","SessionTime"]),
            by="Driver",
            on="SessionTime",
            direction="nearest",
            tolerance=pd.Timedelta("3s")
        )
        lap_gaps2 = lap_gaps2.rename(columns={"Date":"GapDate"})
    else:
        lap_gaps2["GapDate"] = pd.to_datetime(t0) + lap_gaps2["SessionTime"]

    # Normalize datetime tz and enforce group-sorted keys for asof join
    def _normalize_dt(series: pd.Series) -> pd.Series:
        try:
            if hasattr(series.dt, 'tz') and series.dt.tz is not None:
                return series.dt.tz_convert('UTC').dt.tz_localize(None)
            else:
                # ensure naive
                return series.dt.tz_localize(None)
        except Exception:
            return pd.to_datetime(series)

    ts['Date'] = _normalize_dt(ts['Date'])
    lap_gaps2['GapDate'] = _normalize_dt(lap_gaps2['GapDate'])

    left_df = ts.dropna(subset=["Date"]).copy()
    right_df = (lap_gaps2.dropna(subset=["GapDate"]).rename(columns={"GapDate":"Date"})
                [["Driver","Date","IntervalToAhead","IntervalToLeader"]].copy())

    def merge_asof_by(left: pd.DataFrame, right: pd.DataFrame, by_col: str, on_col: str,
                      direction: str = 'backward', tolerance: pd.Timedelta | None = None) -> pd.DataFrame:
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
        result = pd.concat(merged_frames, ignore_index=False)
        return result

    ts = merge_asof_by(left_df, right_df, by_col="Driver", on_col="Date", direction="backward", tolerance=pd.Timedelta("3s"))

    # Convert to seconds
    ts["intervalToLeader"] = ts["IntervalToLeader"].dt.total_seconds().fillna(0.0)
    ts["intervalToAhead"] = ts["IntervalToAhead"].dt.total_seconds()

    # Carry gaps within lap
    ts["intervalToLeader"] = ts.groupby(["Driver","LapNumber"])["intervalToLeader"].ffill().bfill()
    ts["intervalToAhead"] = ts.groupby(["Driver","LapNumber"])["intervalToAhead"].ffill()

    # Position: prefer positional data; fallback to ordering by intervalToLeader
    try:
        pos = session.get_pos_data()[["Date","Driver","Position"]].dropna()
        pos["Driver"] = pos["Driver"].astype(str)
        pos["Date"] = _normalize_dt(pos["Date"])  # normalize tz
        left_df2 = ts.dropna(subset=["Date"]).copy()
        right_df2 = pos.dropna(subset=["Date"]).copy()
        ts = merge_asof_by(left_df2, right_df2, by_col="Driver", on_col="Date", direction="nearest", tolerance=pd.Timedelta("400ms"))
    except Exception:
        pass

    if "Position" not in ts.columns or ts["Position"].isna().all():
        ts["Position"] = ts.groupby("Date")["intervalToLeader"].rank(method="first").astype(int)

    # Pit status, tyre
    ts["PitOut"] = ts["PitOut"].fillna(False)
    ts["PitIn"] = ts["PitIn"].fillna(False)
    ts["pitStatus"] = (ts["PitOut"] | ts["PitIn"]).astype(bool)

    ts["tyre_compound"] = ts["Compound"].fillna("UNKNOWN")
    ts["tyre_age"] = ts["TyreLife"].fillna(0).astype(int)

    # Distance along lap
    if {"X","Y"}.issubset(ts.columns):
        def lap_distance(g):
            g = g.sort_values("Date").copy()
            dx = g["X"].diff()
            dy = g["Y"].diff()
            step = np.sqrt((dx.fillna(0))**2 + (dy.fillna(0))**2)
            g["distance"] = step.cumsum()
            return g
        ts = ts.groupby(["Driver","LapNumber"], group_keys=False).apply(lap_distance)
    else:
        ts = ts.sort_values(["Driver","Date"])
        ts["dt"] = ts.groupby("Driver")["Date"].diff().dt.total_seconds().fillna(0.0)
        ts["speed_ms"] = ts["Speed"].fillna(0) / 3.6
        def integrate(g):
            g = g.sort_values("Date").copy()
            g["distance"] = (g["speed_ms"] * g["dt"]).cumsum()
            return g
        ts = ts.groupby(["Driver","LapNumber"], group_keys=False).apply(integrate)

    # Leader's lap at each timestamp to set snapshot lap
    leader_lap = (ts.sort_values(["Date","Position"])
                    .groupby("Date", as_index=False)
                    .first()[["Date","LapNumber"]]
                    .rename(columns={"LapNumber":"leaderLap"}))
    ts = pd.merge(ts, leader_lap, on="Date", how="left")

    # Build snapshots
    snapshots = []
    for dt, frame in ts.groupby("Date"):
        frame = frame.sort_values("Position")
        driver_states = []
        for _, r in frame.iterrows():
            code = str(r["Driver"])
            drv_info = driver_catalog.get(code, {
                "id": code, "name": code, "code": code,
                "number": None, "team": "", "teamColorHex": "#000000", "country": ""
            })
            driver_states.append({
                "driverId": drv_info,
                "lap": int(r["LapNumber"]) if pd.notna(r["LapNumber"]) else 0,
                "position": int(r["Position"]) if pd.notna(r["Position"]) else 0,
                "distance": float(r["distance"]) if pd.notna(r["distance"]) else 0.0,
                "speed": float(r["Speed"]) if pd.notna(r["Speed"]) else 0.0,
                "sector": int(r["sector"]) if pd.notna(r["sector"]) else 1,
                "intervalToLeader": float(r["intervalToLeader"]) if pd.notna(r["intervalToLeader"]) else None,
                "intervalToAhead": float(r["intervalToAhead"]) if pd.notna(r["intervalToAhead"]) else None,
                "pitStatus": bool(r["pitStatus"]),
                "drsActive": bool(r["DRS"]) if "DRS" in r and pd.notna(r["DRS"]) else False,
                "tyre": {
                    "compound": str(r["tyre_compound"]),
                    "ageLaps": int(r["tyre_age"])
                }
            })
        snapshots.append({
            "timestamp": pd.Timestamp(dt).isoformat(timespec="seconds"),
            "lap": int(frame["leaderLap"].iloc[0]) if not frame["leaderLap"].isna().all() else 0,
            "driverStates": driver_states
        })

    payload = {
        "raceId": race_id,
        "trackName": track_name,
        "year": int(year),
        "totalSnapshots": len(snapshots),
        "totalDrivers": len(drivers),
        "generatedAt": datetime.now(timezone.utc).isoformat(timespec="milliseconds"),
        "raceSnapshots": snapshots
    }
    return payload

# Example usage:
payload = build_race_payload(session, race_id="monaco_2025", track_name="monaco", year=2025, freq="200ms")
with open("output.json", "w") as f:
    json.dump(payload, f, indent=2)