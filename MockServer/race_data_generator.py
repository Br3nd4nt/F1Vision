#!/usr/bin/env python3
import numpy as np
import json
import fastf1
import pandas as pd
from datetime import datetime, timedelta
import math
import argparse
import os
import random
from typing import List, Dict, Any

# Setup FastF1
fastf1.Cache.enable_cache(".fastf1_cache")
fastf1.set_log_level("ERROR")

# Default driver information (you can expand this)
DEFAULT_DRIVERS = [
    {"id": "HAM44", "name": "Lewis Hamilton", "code": "HAM", "number": 44, "team": "Mercedes", "teamColorHex": "#00D2BE", "country": "GBR"},
    {"id": "VER33", "name": "Max Verstappen", "code": "VER", "number": 33, "team": "Red Bull Racing", "teamColorHex": "#0600EF", "country": "NED"},
    {"id": "LEC16", "name": "Charles Leclerc", "code": "LEC", "number": 16, "team": "Ferrari", "teamColorHex": "#DC0000", "country": "MON"},
    {"id": "SAI55", "name": "Carlos Sainz", "code": "SAI", "number": 55, "team": "Ferrari", "teamColorHex": "#DC0000", "country": "ESP"},
    {"id": "NOR4", "name": "Lando Norris", "code": "NOR", "number": 4, "team": "McLaren", "teamColorHex": "#FF8700", "country": "GBR"},
    {"id": "PIA81", "name": "Oscar Piastri", "code": "PIA", "number": 81, "team": "McLaren", "teamColorHex": "#FF8700", "country": "AUS"},
    {"id": "RUS63", "name": "George Russell", "code": "RUS", "number": 63, "team": "Mercedes", "teamColorHex": "#00D2BE", "country": "GBR"},
    {"id": "ALO14", "name": "Fernando Alonso", "code": "ALO", "number": 14, "team": "Aston Martin", "teamColorHex": "#006F62", "country": "ESP"},
    {"id": "STR18", "name": "Lance Stroll", "code": "STR", "number": 18, "team": "Aston Martin", "teamColorHex": "#006F62", "country": "CAN"},
    {"id": "GAS10", "name": "Pierre Gasly", "code": "GAS", "number": 10, "team": "Alpine", "teamColorHex": "#0090FF", "country": "FRA"},
    {"id": "OCO31", "name": "Esteban Ocon", "code": "OCO", "number": 31, "team": "Alpine", "teamColorHex": "#0090FF", "country": "FRA"},
    {"id": "ALB23", "name": "Alexander Albon", "code": "ALB", "number": 23, "team": "Williams", "teamColorHex": "#005AFF", "country": "THA"},
    {"id": "SAR2", "name": "Logan Sargeant", "code": "SAR", "number": 2, "team": "Williams", "teamColorHex": "#005AFF", "country": "USA"},
    {"id": "BOT77", "name": "Valtteri Bottas", "code": "BOT", "number": 77, "team": "Kick Sauber", "teamColorHex": "#52E252", "country": "FIN"},
    {"id": "ZHO24", "name": "Zhou Guanyu", "code": "ZHO", "number": 24, "team": "Kick Sauber", "teamColorHex": "#52E252", "country": "CHN"},
    {"id": "HUL27", "name": "Nico Hulkenberg", "code": "HUL", "number": 27, "team": "Haas F1 Team", "teamColorHex": "#FFFFFF", "country": "GER"},
    {"id": "MAG20", "name": "Kevin Magnussen", "code": "MAG", "number": 20, "team": "Haas F1 Team", "teamColorHex": "#FFFFFF", "country": "DEN"},
    {"id": "TSU22", "name": "Yuki Tsunoda", "code": "TSU", "number": 22, "team": "RB", "teamColorHex": "#1E41FF", "country": "JPN"},
    {"id": "RIC3", "name": "Daniel Ricciardo", "code": "RIC", "number": 3, "team": "RB", "teamColorHex": "#1E41FF", "country": "AUS"},
    {"id": "PER11", "name": "Sergio Perez", "code": "PER", "number": 11, "team": "Red Bull Racing", "teamColorHex": "#0600EF", "country": "MEX"}
]

# Tyre compounds
TYRE_COMPOUNDS = ["soft", "medium", "hard", "intermediate", "wet"]

def get_real_telemetry_data(track_name: str, year: int = 2024) -> Dict[str, Any]:
    """
    Get real telemetry data from FastF1 for a specific track and year
    """
    try:
        print(f"Loading {track_name} {year} race session...")
        session = fastf1.get_session(year, track_name, "R")
        session.load(telemetry=True)
        
        # Get all laps data
        all_laps = session.laps
        
        # Get fastest lap telemetry for reference
        fastest_lap = all_laps.pick_fastest()
        fastest_telemetry = fastest_lap.get_telemetry().add_distance()
        
        # Get some sample laps for different drivers
        sample_laps = []
        drivers = session.drivers[:10]  # Take first 10 drivers
        
        for driver in drivers:
            try:
                driver_laps = all_laps.pick_driver(driver)
                if not driver_laps.empty:
                    # Get a random lap from this driver
                    random_lap = driver_laps.sample(1).iloc[0]
                    telemetry = random_lap.get_telemetry().add_distance()
                    sample_laps.append({
                        'driver': driver,
                        'telemetry': telemetry,
                        'lap_time': random_lap['LapTime'].total_seconds(),
                        'sector1': random_lap['Sector1Time'].total_seconds() if pd.notna(random_lap['Sector1Time']) else None,
                        'sector2': random_lap['Sector2Time'].total_seconds() if pd.notna(random_lap['Sector2Time']) else None,
                        'sector3': random_lap['Sector3Time'].total_seconds() if pd.notna(random_lap['Sector3Time']) else None
                    })
            except Exception as e:
                print(f"Error getting data for driver {driver}: {e}")
                continue
        
        return {
            'fastest_telemetry': fastest_telemetry,
            'sample_laps': sample_laps,
            'track_length': float(fastest_telemetry['Distance'].max()),
            'session_info': {
                'track_name': track_name,
                'year': year,
                'total_laps': len(all_laps),
                'drivers': drivers
            }
        }
        
    except Exception as e:
        print(f"Error loading session data: {e}")
        return None

def generate_race_snapshots(telemetry_data: Dict[str, Any], num_drivers: int = 20, num_snapshots: int = 50) -> List[Dict[str, Any]]:
    """
    Generate race snapshots - each snapshot contains all driver states at a specific timestamp
    """
    if not telemetry_data:
        return generate_fallback_race_snapshots(num_drivers, num_snapshots)
    
    race_snapshots = []
    fastest_telemetry = telemetry_data['fastest_telemetry']
    track_length = telemetry_data['track_length']
    
    # Create starting positions (random but realistic)
    starting_positions = list(range(1, num_drivers + 1))
    random.shuffle(starting_positions)
    
    # Select drivers for this race
    race_drivers = random.sample(DEFAULT_DRIVERS, num_drivers)
    
    # Base timestamp for race start (e.g., 14:00:00)
    base_timestamp = datetime.now().replace(hour=14, minute=0, second=0, microsecond=0)
    
    # Generate snapshots at regular intervals (every 2-5 seconds)
    snapshot_interval = random.uniform(2, 5)
    
    for snapshot_idx in range(num_snapshots):
        # Calculate timestamp for this snapshot
        snapshot_timestamp = base_timestamp + timedelta(seconds=snapshot_idx * snapshot_interval)
        
        # Calculate current lap based on time elapsed
        elapsed_seconds = snapshot_idx * snapshot_interval
        current_lap = int(elapsed_seconds / 100) + 1  # Assume ~100 seconds per lap
        
        # Generate driver states for this snapshot
        driver_states = []
        
        for driver_idx, driver_info in enumerate(race_drivers):
            # Generate realistic position changes over time
            base_position = starting_positions[driver_idx]
            time_factor = snapshot_idx / num_snapshots  # Progress through race
            position_variation = int(random.uniform(-3, 3) * time_factor)
            current_position = max(1, min(num_drivers, base_position + position_variation))
            
            # Generate realistic distance based on time and position
            base_distance = (current_lap - 1) * track_length
            position_offset = (current_position - 1) * 50  # 50m gap between positions
            time_progress = (elapsed_seconds % 100) / 100  # Progress within current lap
            distance = base_distance + (track_length * time_progress) + position_offset + random.uniform(0, 100)
            
            # Generate realistic speed based on telemetry
            if not fastest_telemetry.empty:
                # Get a random speed from the telemetry
                speed_sample = fastest_telemetry['Speed'].sample(1).iloc[0]
                speed = speed_sample + random.uniform(-20, 20)  # Add some variation
                speed = max(50, min(350, speed))  # Keep within realistic bounds
            else:
                speed = random.uniform(150, 300)
            
            # Determine sector based on distance
            sector = 1
            if distance > track_length * 0.33:
                sector = 2
            if distance > track_length * 0.66:
                sector = 3
            
            # Generate intervals
            interval_to_leader = None
            interval_to_ahead = None
            if current_position > 1:
                interval_to_leader = random.uniform(5, 60)  # 5-60 seconds behind leader
                interval_to_ahead = random.uniform(0.5, 10)  # 0.5-10 seconds behind car ahead
            
            # Generate tyre state
            tyre_age = random.randint(1, 20)
            tyre_compound = random.choice(TYRE_COMPOUNDS)
            fresh_tyres = tyre_age <= 2
            
            # Generate pit status and DRS
            pit_status = random.random() < 0.05  # 5% chance of being in pits
            drs_active = random.random() < 0.3 and current_position > 1  # 30% chance if not leading
            
            driver_state = {
                "driverId": driver_info,
                "lap": current_lap,
                "position": current_position,
                "distance": round(distance, 2),
                "speed": round(speed, 1),
                "sector": sector,
                "intervalToLeader": round(interval_to_leader, 1) if interval_to_leader else None,
                "intervalToAhead": round(interval_to_ahead, 1) if interval_to_ahead else None,
                "pitStatus": pit_status,
                "drsActive": drs_active,
                "tyre": {
                    "compound": tyre_compound,
                    "age": tyre_age,
                    "fresh": fresh_tyres
                }
            }
            
            driver_states.append(driver_state)
        
        # Sort by position for this snapshot
        driver_states.sort(key=lambda x: x['position'])
        
        # Create race snapshot
        race_snapshot = {
            "timestamp": snapshot_timestamp.isoformat(),
            "lap": current_lap,
            "driverStates": driver_states
        }
        
        race_snapshots.append(race_snapshot)
    
    return race_snapshots

def generate_fallback_race_snapshots(num_drivers: int = 20, num_snapshots: int = 50) -> List[Dict[str, Any]]:
    """
    Generate fallback race snapshots when FastF1 data is not available
    """
    race_snapshots = []
    track_length = 5000  # Default track length
    
    # Create starting positions
    starting_positions = list(range(1, num_drivers + 1))
    random.shuffle(starting_positions)
    
    # Select drivers for this race
    race_drivers = random.sample(DEFAULT_DRIVERS, num_drivers)
    
    # Base timestamp for race start (e.g., 14:00:00)
    base_timestamp = datetime.now().replace(hour=14, minute=0, second=0, microsecond=0)
    
    # Generate snapshots at regular intervals (every 2-5 seconds)
    snapshot_interval = random.uniform(2, 5)
    
    for snapshot_idx in range(num_snapshots):
        # Calculate timestamp for this snapshot
        snapshot_timestamp = base_timestamp + timedelta(seconds=snapshot_idx * snapshot_interval)
        
        # Calculate current lap based on time elapsed
        elapsed_seconds = snapshot_idx * snapshot_interval
        current_lap = int(elapsed_seconds / 100) + 1  # Assume ~100 seconds per lap
        
        # Generate driver states for this snapshot
        driver_states = []
        
        for driver_idx, driver_info in enumerate(race_drivers):
            # Generate realistic position changes over time
            base_position = starting_positions[driver_idx]
            time_factor = snapshot_idx / num_snapshots  # Progress through race
            position_variation = int(random.uniform(-3, 3) * time_factor)
            current_position = max(1, min(num_drivers, base_position + position_variation))
            
            # Generate realistic distance based on time and position
            base_distance = (current_lap - 1) * track_length
            position_offset = (current_position - 1) * 50
            time_progress = (elapsed_seconds % 100) / 100  # Progress within current lap
            distance = base_distance + (track_length * time_progress) + position_offset + random.uniform(0, 100)
            
            # Generate realistic speed
            speed = random.uniform(150, 300)
            
            # Determine sector
            sector = 1
            if distance > track_length * 0.33:
                sector = 2
            if distance > track_length * 0.66:
                sector = 3
            
            # Generate intervals
            interval_to_leader = None
            interval_to_ahead = None
            if current_position > 1:
                interval_to_leader = random.uniform(5, 60)
                interval_to_ahead = random.uniform(0.5, 10)
            
            # Generate tyre state
            tyre_age = random.randint(1, 20)
            tyre_compound = random.choice(TYRE_COMPOUNDS)
            fresh_tyres = tyre_age <= 2
            
            # Generate pit status and DRS
            pit_status = random.random() < 0.05
            drs_active = random.random() < 0.3 and current_position > 1
            
            driver_state = {
                "driverId": driver_info,
                "lap": current_lap,
                "position": current_position,
                "distance": round(distance, 2),
                "speed": round(speed, 1),
                "sector": sector,
                "intervalToLeader": round(interval_to_leader, 1) if interval_to_leader else None,
                "intervalToAhead": round(interval_to_ahead, 1) if interval_to_ahead else None,
                "pitStatus": pit_status,
                "drsActive": drs_active,
                "tyre": {
                    "compound": tyre_compound,
                    "age": tyre_age,
                    "fresh": fresh_tyres
                }
            }
            
            driver_states.append(driver_state)
        
        # Sort by position for this snapshot
        driver_states.sort(key=lambda x: x['position'])
        
        # Create race snapshot
        race_snapshot = {
            "timestamp": snapshot_timestamp.isoformat(),
            "lap": current_lap,
            "driverStates": driver_states
        }
        
        race_snapshots.append(race_snapshot)
    
    return race_snapshots

def generate_race_data(track_name: str, year: int = 2024, num_drivers: int = 20, num_snapshots: int = 50) -> Dict[str, Any]:
    """
    Generate complete race data including race snapshots
    """
    print(f"Generating race data for {track_name} {year}...")
    
    # Try to get real telemetry data
    telemetry_data = get_real_telemetry_data(track_name, year)
    
    # Generate race snapshots
    race_snapshots = generate_race_snapshots(telemetry_data, num_drivers, num_snapshots)
    
    # Create race metadata
    race_data = {
        "raceId": f"{track_name.lower().replace(' ', '_')}_{year}",
        "trackName": track_name,
        "year": year,
        "totalSnapshots": num_snapshots,
        "totalDrivers": num_drivers,
        "generatedAt": datetime.now().isoformat(),
        "raceSnapshots": race_snapshots
    }
    
    return race_data

def save_race_data(race_data: Dict[str, Any], filename: str):
    """Save race data to JSON file"""
    os.makedirs("./raceData", exist_ok=True)
    
    filepath = os.path.join("./raceData", filename)
    
    with open(filepath, 'w') as f:
        json.dump(race_data, f, indent=2)
    
    print(f"Race data saved to {filepath}")

def main():
    parser = argparse.ArgumentParser(description='Generate F1 race data using FastF1')
    parser.add_argument('track', help='Track name (e.g., "Suzuka", "Monaco")')
    parser.add_argument('--year', type=int, default=2024, help='Year of the race (default: 2024)')
    parser.add_argument('--drivers', type=int, default=20, help='Number of drivers (default: 20)')
    parser.add_argument('--snapshots', type=int, default=50, help='Number of snapshots to generate (default: 50)')
    parser.add_argument('--output', help='Output filename (default: auto-generated)')
    
    args = parser.parse_args()
    
    # Generate race data
    race_data = generate_race_data(args.track, args.year, args.drivers, args.snapshots)
    
    # Generate output filename if not provided
    if not args.output:
        args.output = f"{args.track.lower().replace(' ', '_')}_{args.year}_race_data.json"
    
    # Save race data
    save_race_data(race_data, args.output)
    
    print(f"Generated {len(race_data['raceSnapshots'])} race snapshots")
    print(f"Race data covers {args.snapshots} snapshots with {args.drivers} drivers")

if __name__ == "__main__":
    main()
