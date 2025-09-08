#!/usr/bin/env python3
"""
Test script for the realistic race generator
"""

import sys
import os

# Add current directory to path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from realistic_race_generator import RealisticRaceGenerator

def test_generator():
    """Test the realistic race generator"""
    print("Testing Realistic Race Generator...")
    
    try:
        # Test with Monza 2024
        generator = RealisticRaceGenerator(2024, "monza")
        
        # Generate a small dataset for testing
        race_data = generator.generate_race_data(num_snapshots=20)
        
        print(f"\nGenerated race data:")
        print(f"Track: {race_data['trackName']}")
        print(f"Year: {race_data['year']}")
        print(f"Snapshots: {race_data['totalSnapshots']}")
        print(f"Drivers: {race_data['totalDrivers']}")
        
        # Show first snapshot
        first_snapshot = race_data['raceSnapshots'][0]
        print(f"\nFirst snapshot (Lap {first_snapshot['lap']}):")
        print(f"Timestamp: {first_snapshot['timestamp']}")
        print(f"Drivers: {len(first_snapshot['driverStates'])}")
        
        # Show first driver details
        first_driver = first_snapshot['driverStates'][0]
        print(f"\nFirst driver:")
        print(f"Name: {first_driver['driverId']['name']}")
        print(f"Position: {first_driver['position']}")
        print(f"Distance: {first_driver['distance']}m")
        print(f"Speed: {first_driver['speed']} km/h")
        print(f"Sector: {first_driver['sector']}")
        print(f"Tyre: {first_driver['tyre']['compound']} (age: {first_driver['tyre']['age']})")
        
        # Save test data
        output_file = "raceData/test_monza_2024_race_data.json"
        generator.save_race_data(race_data, output_file)
        
        print(f"\nTest completed successfully!")
        print(f"Data saved to: {output_file}")
        
    except Exception as e:
        print(f"Test failed: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    test_generator()

