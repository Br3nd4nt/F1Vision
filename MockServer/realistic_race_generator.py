#!/usr/bin/env python3
"""
Realistic F1 Race Data Generator
Uses real FastF1 telemetry data to create realistic race snapshots with proper continuity
Skips boring race start and focuses on exciting mid-race action
"""

import numpy as np
import json
import fastf1
import pandas as pd
from datetime import datetime, timedelta
import math
import argparse
import os
from typing import List, Dict, Any, Tuple
from dataclasses import dataclass

# Setup FastF1
fastf1.Cache.enable_cache(".fastf1_cache")
fastf1.set_log_level("ERROR")

@dataclass
class DriverInfo:
    id: str
    name: str
    code: str
    number: int
    team: str
    teamColorHex: str
    country: str

@dataclass
class TyreData:
    compound: str
    age: int
    fresh: bool

@dataclass
class DriverState:
    driverId: DriverInfo
    lap: int
    position: int
    distance: float
    speed: float
    sector: int
    intervalToLeader: float
    intervalToAhead: float
    pitStatus: bool
    drsActive: bool
    tyre: TyreData

class RealisticRaceGenerator:
    def __init__(self, year: int = 2024, track_name: str = "monza"):
        self.year = year
        self.track_name = track_name
        self.session = None
        self.track_length = 0
        self.drivers_info = []
        self.telemetry_data = {}
        
    def load_session_data(self):
        """Load real F1 session data"""
        print(f"Loading {self.track_name} {self.year} race session...")
        
        # Check if track data exists
        track_file = f"../F1Vision/Resources/MockData/Track/{self.track_name}_track_layout.json"
        if not os.path.exists(track_file):
            print(f"⚠️  Warning: Track data not found at {track_file}")
            print(f"💡 Tip: Run 'make track track={self.track_name} year={self.year}' first to generate track data")
            print(f"💡 Or use 'make full-race track={self.track_name} year={self.year}' to generate everything at once")
        
        try:
            self.session = fastf1.get_session(self.year, self.track_name, "R")
            self.session.load(telemetry=True)
            
            # Get track length from fastest lap
            fastest_lap = self.session.laps.pick_fastest()
            fastest_telemetry = fastest_lap.get_telemetry().add_distance()
            self.track_length = float(fastest_telemetry['Distance'].max())
            
            print(f"Track length: {self.track_length:.2f} meters")
            print(f"Total laps: {len(self.session.laps)}")
            
            # Get driver information
            self._extract_driver_info()
            
            # Load telemetry data for each driver
            self._load_driver_telemetry()
            
            return True
            
        except Exception as e:
            print(f"Error loading session: {e}")
            return False
    
    def _extract_driver_info(self):
        """Extract driver information from session"""
        drivers = self.session.drivers
        
        # Default team colors (you can expand this)
        team_colors = {
            "Red Bull Racing": "#0600EF",
            "Ferrari": "#DC0000", 
            "McLaren": "#FF8700",
            "Mercedes": "#00D2BE",
            "Aston Martin": "#006F62",
            "Alpine": "#0090FF",
            "Williams": "#005AFF",
            "Kick Sauber": "#52E252",
            "Haas F1 Team": "#FFFFFF",
            "RB": "#1E41FF"
        }
        
        for driver in drivers:
            try:
                driver_info = self.session.get_driver(driver)
                team = driver_info.TeamName
                
                self.drivers_info.append(DriverInfo(
                    id=f"{driver_info.Abbreviation}{driver_info.DriverNumber}",
                    name=driver_info.FullName,
                    code=driver_info.Abbreviation,
                    number=int(driver_info.DriverNumber),  # Ensure it's an integer
                    team=team,
                    teamColorHex=team_colors.get(team, "#000000"),
                    country=driver_info.CountryCode
                ))
            except Exception as e:
                print(f"Error getting driver info for {driver}: {e}")
                continue
        
        print(f"Loaded {len(self.drivers_info)} drivers")
    
    def _load_driver_telemetry(self):
        """Load telemetry data for each driver"""
        print("Loading driver telemetry data...")
        
        for driver_info in self.drivers_info:
            try:
                driver_code = driver_info.code
                driver_laps = self.session.laps.pick_drivers(driver_code)
                
                if not driver_laps.empty:
                    # Get telemetry for each lap
                    lap_telemetry = []
                    for _, lap in driver_laps.iterrows():
                        try:
                            telemetry = lap.get_telemetry().add_distance()
                            lap_telemetry.append({
                                'lap': lap['LapNumber'],
                                'telemetry': telemetry,
                                'lap_time': lap['LapTime'].total_seconds() if pd.notna(lap['LapTime']) else None,
                                'sector1': lap['Sector1Time'].total_seconds() if pd.notna(lap['Sector1Time']) else None,
                                'sector2': lap['Sector2Time'].total_seconds() if pd.notna(lap['Sector2Time']) else None,
                                'sector3': lap['Sector3Time'].total_seconds() if pd.notna(lap['Sector3Time']) else None
                            })
                        except Exception as e:
                            continue
                    
                    self.telemetry_data[driver_code] = lap_telemetry
                    print(f"  ✅ {driver_code}: {len(lap_telemetry)} laps with telemetry")
                    
            except Exception as e:
                print(f"Error loading telemetry for {driver_info.code}: {e}")
                continue
        
        print(f"Loaded telemetry for {len(self.telemetry_data)} drivers")
    
    def _calculate_tyre_strategy(self, driver_code: str, lap: int) -> TyreData:
        """Calculate realistic tyre strategy based on lap number"""
        # Realistic tyre strategies for different tracks
        if self.track_name.lower() == "baku":
            # Baku is street circuit, usually 1-2 stops
            if lap <= 20:
                compound = "medium"
                age = lap
            elif lap <= 40:
                compound = "hard"
                age = lap - 20
            else:
                compound = "soft"
                age = lap - 40
        elif self.track_name.lower() == "monza":
            # Monza is high-speed, usually 1-2 stops
            if lap <= 15:
                compound = "medium"
                age = lap
            elif lap <= 35:
                compound = "hard"
                age = lap - 15
            else:
                compound = "soft"
                age = lap - 15
        elif self.track_name.lower() == "monaco":
            # Monaco is low-speed, usually 1 stop
            if lap <= 25:
                compound = "medium"
                age = lap
            else:
                compound = "soft"
                age = lap - 25
        else:
            # Default strategy
            if lap <= 20:
                compound = "medium"
                age = lap
            elif lap <= 40:
                compound = "hard"
                age = lap - 20
            else:
                compound = "soft"
                age = lap - 20
        
        return TyreData(
            compound=compound,
            age=age,
            fresh=(age <= 2)
        )
    
    def _calculate_sector(self, distance: float) -> int:
        """Calculate sector based on distance along track"""
        sector_length = self.track_length / 3
        
        if distance < sector_length:
            return 1
        elif distance < sector_length * 2:
            return 2
        else:
            return 3
    
    def _interpolate_position(self, telemetry: pd.DataFrame, target_distance: float) -> Tuple[float, float]:
        """Interpolate driver position at specific distance"""
        # Find the closest distance points
        distances = telemetry['Distance'].values
        x_coords = telemetry['X'].values
        y_coords = telemetry['Y'].values
        
        # Find closest index
        idx = np.argmin(np.abs(distances - target_distance))
        
        # Simple interpolation
        if idx < len(distances) - 1:
            d1, d2 = distances[idx], distances[idx + 1]
            x1, x2 = x_coords[idx], x_coords[idx + 1]
            y1, y2 = y_coords[idx], y_coords[idx + 1]
            
            # Linear interpolation
            t = (target_distance - d1) / (d2 - d1)
            x = x1 + t * (x2 - x1)
            y = y1 + t * (y2 - y1)
            
            return float(x), float(y)
        else:
            return float(x_coords[idx]), float(y_coords[idx])
    
    def generate_race_snapshots(self, num_snapshots: int = 100) -> List[Dict[str, Any]]:
        """Generate realistic race snapshots with proper continuity"""
        print(f"Generating {num_snapshots} race snapshots...")
        
        snapshots = []
        total_laps = len(self.session.laps)
        
        # Skip the boring first third of the race and focus on exciting mid-race action
        # Start from lap 8-10 instead of lap 1 for more interesting racing
        start_lap = max(8, total_laps // 10)  # Start from lap 8 or 10% into race, whichever is later
        
        # Calculate snapshot intervals for the remaining laps
        remaining_laps = total_laps - start_lap + 1
        snapshot_interval = remaining_laps / num_snapshots
        
        print(f"Starting from lap {start_lap} (skipping boring race start)")
        print(f"Generating snapshots for {remaining_laps} laps of racing action")
        print(f"Available telemetry data for drivers: {list(self.telemetry_data.keys())}")
        
        for snapshot_idx in range(num_snapshots):
            # Calculate current lap (starting from start_lap)
            current_lap = start_lap + int(snapshot_idx * snapshot_interval)
            current_lap = min(current_lap, total_laps)
            
            # Calculate timestamp (more realistic mid-race timing)
            base_time = datetime(2024, 8, 23, 14, 0, 0)  # Race start time
            lap_time = timedelta(minutes=1, seconds=30)  # Average lap time
            timestamp = base_time + (current_lap - 1) * lap_time
            
            # Generate driver states for this snapshot
            driver_states = []
            
            for driver_info in self.drivers_info:
                driver_code = driver_info.code
                
                if driver_code in self.telemetry_data:
                    # Find telemetry for current lap - use closest available lap
                    lap_data = None
                    available_laps = [lt['lap'] for lt in self.telemetry_data[driver_code]]
                    
                    # Find the closest available lap to current_lap
                    if available_laps:
                        closest_lap = min(available_laps, key=lambda x: abs(x - current_lap))
                        for lap_telemetry in self.telemetry_data[driver_code]:
                            if lap_telemetry['lap'] == closest_lap:
                                lap_data = lap_telemetry
                                break
                    
                    if lap_data:
                        telemetry = lap_data['telemetry']
                        
                        # Calculate realistic distance based on lap progress
                        lap_progress = (snapshot_idx % int(snapshot_interval)) / snapshot_interval
                        distance = lap_progress * self.track_length
                        
                        # Interpolate position
                        x, y = self._interpolate_position(telemetry, distance)
                        
                        # Calculate speed (more realistic mid-race speeds)
                        # Mid-race speeds are typically higher than start/finish
                        base_speed = 220 + (np.random.normal(0, 25))  # Higher base speed for mid-race
                        speed = max(150, min(320, base_speed))  # Clamp between 150-320 km/h
                        
                        # Calculate sector
                        sector = self._calculate_sector(distance)
                        
                        # Calculate tyre data (more interesting mid-race strategies)
                        tyre = self._calculate_tyre_strategy(driver_code, current_lap)
                        
                        # Calculate position (more realistic mid-race positions)
                        # Add some randomness to make it more exciting
                        base_position = len(driver_states) + 1
                        position_variation = np.random.randint(-2, 3)  # ±2 position variation
                        position = max(1, min(20, base_position + position_variation))
                        
                        # Calculate intervals (more realistic mid-race gaps)
                        if position > 1:
                            # Mid-race gaps are typically smaller and more variable
                            gap_variation = np.random.uniform(0.8, 1.5)  # 20-50% variation
                            interval_to_leader = (position - 1) * 2.0 * gap_variation
                            interval_to_ahead = 2.0 * gap_variation
                        else:
                            interval_to_leader = None
                            interval_to_ahead = None
                        
                        driver_state = DriverState(
                            driverId=driver_info,
                            lap=current_lap,
                            position=position,
                            distance=distance,
                            speed=speed,
                            sector=sector,
                            intervalToLeader=interval_to_leader,
                            intervalToAhead=interval_to_ahead,
                            pitStatus=False,
                            drsActive=False,
                            tyre=tyre
                        )
                        
                        driver_states.append(driver_state)
                        
                        if snapshot_idx == 0:  # Debug first snapshot
                            print(f"✅ Added driver {driver_code} (lap {current_lap}, pos {position}, speed {speed:.1f})")
                    else:
                        if snapshot_idx == 0:  # Debug first snapshot
                            print(f"❌ No telemetry data found for {driver_code} around lap {current_lap}")
                else:
                    if snapshot_idx == 0:  # Debug first snapshot
                        print(f"❌ No telemetry data loaded for {driver_code}")
            
            # Sort by position to maintain race order
            driver_states.sort(key=lambda x: x.position)
            
            if snapshot_idx == 0:  # Debug first snapshot
                print(f"📊 Generated {len(driver_states)} driver states for snapshot 1")
            
            # Create snapshot
            snapshot = {
                "timestamp": timestamp.isoformat(),
                "lap": current_lap,
                "driverStates": [
                    {
                        "driverId": {
                            "id": ds.driverId.id,
                            "name": ds.driverId.name,
                            "code": ds.driverId.code,
                            "number": ds.driverId.number,  # This is now guaranteed to be an int
                            "team": ds.driverId.team,
                            "teamColorHex": ds.driverId.teamColorHex,
                            "country": ds.driverId.country
                        },
                        "lap": ds.lap,
                        "position": ds.position,
                        "distance": round(ds.distance, 2),
                        "speed": round(ds.speed, 1),
                        "sector": ds.sector,
                        "intervalToLeader": round(ds.intervalToLeader, 1) if ds.intervalToLeader else None,
                        "intervalToAhead": round(ds.intervalToAhead, 1) if ds.intervalToAhead else None,
                        "pitStatus": ds.pitStatus,
                        "drsActive": ds.drsActive,
                        "tyre": {
                            "compound": ds.tyre.compound,
                            "age": ds.tyre.age,
                            "fresh": ds.tyre.fresh
                        }
                    }
                    for ds in driver_states
                ]
            }
            
            snapshots.append(snapshot)
            
            if snapshot_idx % 10 == 0:
                print(f"Generated snapshot {snapshot_idx + 1}/{num_snapshots} (Lap {current_lap}) with {len(driver_states)} drivers")
        
        return snapshots
    
    def generate_race_data(self, num_snapshots: int = 100) -> Dict[str, Any]:
        """Generate complete race data"""
        if not self.load_session_data():
            raise Exception("Failed to load session data")
        
        snapshots = self.generate_race_snapshots(num_snapshots)
        
        race_data = {
            "raceId": f"{self.track_name}_{self.year}",
            "trackName": self.track_name,
            "year": self.year,
            "totalSnapshots": len(snapshots),
            "totalDrivers": len(self.drivers_info),
            "generatedAt": datetime.now().isoformat(),
            "raceSnapshots": snapshots
        }
        
        return race_data
    
    def save_race_data(self, race_data: Dict[str, Any], output_file: str):
        """Save race data to JSON file"""
        print(f"Saving race data to {output_file}...")
        
        with open(output_file, 'w') as f:
            json.dump(race_data, f, indent=2)
        
        print(f"Race data saved successfully!")

def main():
    parser = argparse.ArgumentParser(description="Generate realistic F1 race data")
    parser.add_argument("--year", type=int, default=2024, help="F1 season year")
    parser.add_argument("--track", type=str, default="monza", help="Track name")
    parser.add_argument("--snapshots", type=int, default=100, help="Number of snapshots to generate")
    parser.add_argument("--output", type=str, default=None, help="Output file path")
    
    args = parser.parse_args()
    
    # Generate output filename if not provided
    if args.output is None:
        args.output = f"raceData/{args.track}_{args.year}_race_data.json"
    
    # Create output directory if it doesn't exist
    os.makedirs(os.path.dirname(args.output), exist_ok=True)
    
    try:
        generator = RealisticRaceGenerator(args.year, args.track)
        race_data = generator.generate_race_data(args.snapshots)
        generator.save_race_data(race_data, args.output)
        
        print(f"\nSuccessfully generated realistic race data!")
        print(f"Track: {args.track}")
        print(f"Year: {args.year}")
        print(f"Snapshots: {args.snapshots}")
        print(f"Drivers: {race_data['totalDrivers']}")
        print(f"Output: {args.output}")
        
    except Exception as e:
        print(f"Error generating race data: {e}")
        return 1
    
    return 0

if __name__ == "__main__":
    exit(main())

