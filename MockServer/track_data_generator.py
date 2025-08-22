#!/usr/bin/env python3
import numpy as np
import json
import fastf1
from datetime import datetime
import math
import argparse
import os

# Setup FastF1
fastf1.Cache.enable_cache(".fastf1_cache")
fastf1.set_log_level("ERROR")

def calculate_distance_between_points(x1, y1, x2, y2):
    """Calculate distance between two points"""
    return math.sqrt((x2 - x1)**2 + (y2 - y1)**2)

def generate_track_layout_model(track_name, grand_prix_name, year=2024):
    """
    Generate TrackLayoutModel JSON file with real track points using FastF1
    """
    print(f"Loading {track_name} session data...")
    
    # Get session data
    session = fastf1.get_session(year, track_name, "R")
    session.load(telemetry=True)
    
    print("Getting track telemetry...")
    
    # Get telemetry from fastest lap
    track_points_telemetry = session.laps.pick_fastest().get_telemetry().add_distance()
    
    # Extract X and Y coordinates
    x = np.array(track_points_telemetry['X'].values)
    y = np.array(track_points_telemetry['Y'].values)
    
    # Calculate cumulative distance for each point
    distances = []
    cumulative_distance = 0.0
    
    for i in range(len(x)):
        if i > 0:
            # Calculate distance from previous point
            dist = calculate_distance_between_points(x[i-1], y[i-1], x[i], y[i])
            cumulative_distance += dist
        distances.append(cumulative_distance)
    
    # Create TrackPoint objects (matching Swift TrackPoint model)
    track_points = []
    for i in range(len(x)):
        track_point = {
            "x": float(x[i]),
            "y": float(y[i]),
            "distance": float(distances[i])
        }
        track_points.append(track_point)
    
    # Calculate bounding box (matching Swift BoundingBox model)
    min_x = float(np.min(x))
    min_y = float(np.min(y))
    max_x = float(np.max(x))
    max_y = float(np.max(y))
    
    bounding_box = {
        "minX": min_x,
        "minY": min_y,
        "maxX": max_x,
        "maxY": max_y
    }
    
    # Start/finish line is typically at distance 0 (matching Swift StartFinishLine model)
    start_finish_line = {
        "distance": 0.0
    }
    
    # Calculate total track length
    track_length = float(cumulative_distance)
    
    # Create TrackLayoutModel (matching Swift TrackLayoutModel)
    track_layout_model = {
        "id": f"{track_name.lower().replace(' ', '_')}_{year}",
        "name": f"{year} {track_name}",
        "length": track_length,
        "points": track_points,
        "boundingBox": bounding_box,
        "startFinishLine": start_finish_line
    }
    
    print(f"Generated {len(track_points)} track points")
    print(f"Track length: {track_length:.2f} meters")
    print(f"Bounding box: X({min_x:.2f}, {max_x:.2f}), Y({min_y:.2f}, {max_y:.2f})")
    
    return track_layout_model

def save_track_data(track_data, filename):
    """Save track data to JSON file"""
    # Create trackData directory if it doesn't exist
    os.makedirs("./trackData", exist_ok=True)
    
    filepath = os.path.join("./trackData", filename)
    with open(filepath, 'w') as f:
        json.dump(track_data, f, indent=2)
    print(f"Track data saved to {filepath}")

def get_track_info(track_name):
    """Get track information using FastF1's search functionality"""
    # Try to find the track using FastF1's search
    try:
        # FastF1 can search for tracks by name
        # We'll use the track name directly and let FastF1 handle the matching
        return {
            "name": track_name,
            "grand_prix": f"{track_name} Grand Prix"  # Generic fallback
        }
    except Exception:
        return None

def generate_track(track_name, year=2024):
    """Generate track layout for specified track"""
    print(f"🏁 Generating {track_name} track layout...")
    
    try:
        # Let FastF1 handle the track name matching
        track_data = generate_track_layout_model(track_name, f"{track_name} Grand Prix", year)
        
        # Create filename
        filename = f"{track_name.lower().replace(' ', '_')}_track_layout.json"
        save_track_data(track_data, filename)
        
        print(f"\n✅ Successfully generated {track_name} track layout!")
        return track_data
        
    except Exception as e:
        print(f"❌ Error generating {track_name} track data: {e}")
        print("💡 Try using the exact track name as it appears in FastF1.")
        print("   Common examples: 'Abu Dhabi', 'Monaco', 'Silverstone', 'Monza', 'Spa'")
        return None

def main():
    parser = argparse.ArgumentParser(
        description="🏁 F1 Track Data Generator - Generate track layout data for F1Vision app",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python track_data_generator.py "Abu Dhabi"
  python track_data_generator.py Monaco --year 2023
  python track_data_generator.py Silverstone --year 2024

The tool uses FastF1's built-in search, so track names are flexible.
Common track names: Abu Dhabi, Monaco, Silverstone, Monza, Spa, etc.
        """
    )
    
    parser.add_argument(
        "track_name",
        help="Name of the track to generate data for"
    )
    
    parser.add_argument(
        "--year",
        type=int,
        default=2024,
        help="Year of the race session (default: 2024)"
    )
    
    args = parser.parse_args()
    
    print("🏁 F1 Track Data Generator")
    print("=" * 40)
    
    generate_track(args.track_name, args.year)

if __name__ == "__main__":
    main()
