#!/usr/bin/env python3
"""
Improved F1 Data Fetcher with Proper Session Timing
Handles session start time, absolute timestamps, and proper race timeline
"""

import numpy as np
import pandas as pd
import fastf1
from typing import Dict, List, Any, Optional
import json
from datetime import datetime, timezone
import os

# Enable caching and set log level
fastf1.Cache.enable_cache(".fastf1_cache")
fastf1.set_log_level("ERROR")


class ImprovedF1DataFetcher:
    """
    Improved F1 data fetcher with proper session timing and absolute timestamps
    """
    
    def __init__(self, year: int = 2024, location: str = "Monaco", session_type: str = "R"):
        self.year = year
        self.location = location
        self.session_type = session_type
        self.session = None
        self.drivers = []
        self.track_data = {}
        self.race_data = {}
        self.session_start_time = None
        
    def load_session(self) -> bool:
        """Load the F1 session data with telemetry"""
        try:
            print(f"Loading session data for {self.year} {self.location} {self.session_type}")
            self.session = fastf1.get_session(self.year, self.location, self.session_type)
            self.session.load(telemetry=True)
            self.drivers = self.session.drivers
            
            # Get session start time
            self.session_start_time = getattr(self.session, 't0_date', None)
            if self.session_start_time:
                print(f"Session start time: {self.session_start_time}")
            else:
                print("Warning: No session start time found")
            
            print(f"Successfully loaded data for {len(self.drivers)} drivers: {self.drivers}")
            return True
        except Exception as e:
            print(f"Error loading session: {e}")
            return False
    
    def get_session_timeline(self) -> Dict[str, Any]:
        """Get the complete session timeline with proper timing"""
        if not self.session:
            raise ValueError("Session not loaded. Call load_session() first.")
        
        print("Building session timeline...")
        
        # Get all telemetry data to find the actual race start and end
        all_telemetry = []
        min_time = None
        max_time = None
        min_date = None
        max_date = None
        
        for driver in self.drivers:
            try:
                driver_laps = self.session.laps.pick_drivers(driver)
                if not driver_laps.empty:
                    telemetry = driver_laps.get_telemetry()
                    if not telemetry.empty and 'SessionTime' in telemetry.columns:
                        session_times = telemetry['SessionTime'].dropna()
                        if not session_times.empty:
                            driver_min = session_times.min()
                            driver_max = session_times.max()
                            
                            if min_time is None or driver_min < min_time:
                                min_time = driver_min
                            if max_time is None or driver_max > max_time:
                                max_time = driver_max
                    
                    if 'Date' in telemetry.columns:
                        dates = telemetry['Date'].dropna()
                        if not dates.empty:
                            driver_min_date = dates.min()
                            driver_max_date = dates.max()
                            
                            if min_date is None or driver_min_date < min_date:
                                min_date = driver_min_date
                            if max_date is None or driver_max_date > max_date:
                                max_date = driver_max_date
                                
            except Exception as e:
                print(f"Error processing driver {driver}: {e}")
                continue
        
        timeline_info = {
            'session_start_time': self.session_start_time.isoformat() if self.session_start_time else None,
            'min_session_time': min_time.total_seconds() if min_time else None,
            'max_session_time': max_time.total_seconds() if max_time else None,
            'min_date': min_date.isoformat() if min_date else None,
            'max_date': max_date.isoformat() if max_date else None,
            'race_duration_minutes': (max_time - min_time).total_seconds() / 60 if min_time and max_time else None
        }
        
        print(f"Session timeline:")
        print(f"  Start time: {timeline_info['session_start_time']}")
        print(f"  Session time range: {timeline_info['min_session_time']:.1f}s - {timeline_info['max_session_time']:.1f}s")
        print(f"  Date range: {timeline_info['min_date']} - {timeline_info['max_date']}")
        print(f"  Race duration: {timeline_info['race_duration_minutes']:.1f} minutes")
        
        return timeline_info
    
    def get_race_telemetry_with_timing(self, frequency: int = 10) -> Dict[str, List[Dict[str, Any]]]:
        """
        Extract telemetry data with proper absolute timestamps and race timing
        """
        if not self.session:
            raise ValueError("Session not loaded. Call load_session() first.")
        
        print(f"Extracting race telemetry with proper timing at {frequency}Hz...")
        
        # Get timeline info
        timeline_info = self.get_session_timeline()
        
        # Create absolute timeline
        if self.session_start_time and timeline_info['min_session_time'] is not None:
            race_start = self.session_start_time + pd.Timedelta(seconds=timeline_info['min_session_time'])
            race_end = self.session_start_time + pd.Timedelta(seconds=timeline_info['max_session_time'])
            
            # Create resampled timeline
            time_delta = pd.Timedelta(seconds=(1/frequency))
            timeline = pd.date_range(start=race_start, end=race_end, freq=time_delta)
            
            print(f"Race timeline: {race_start} to {race_end}")
            print(f"Generated {len(timeline)} data points at {frequency}Hz")
        else:
            print("Warning: Using fallback timing method")
            # Fallback to the original method
            return self._get_telemetry_fallback(frequency)
        
        # Get telemetry for all drivers
        all_telemetry = {driver: [] for driver in self.drivers}
        
        for driver in self.drivers:
            print(f"Processing driver {driver}...")
            try:
                driver_laps = self.session.laps.pick_drivers(driver)
                if not driver_laps.empty:
                    # Get all telemetry for this driver
                    telemetry = driver_laps.get_telemetry().add_driver_ahead(drop_existing=True)
                    
                    if not telemetry.empty and 'Date' in telemetry.columns:
                        # Resample onto our timeline
                        telemetry_resampled = self._resample_telemetry_to_timeline(telemetry, timeline, driver)
                        all_telemetry[driver] = telemetry_resampled
                        print(f"  ✅ {driver}: {len(telemetry_resampled)} data points")
                    else:
                        print(f"  ❌ {driver}: No valid telemetry data")
                else:
                    print(f"  ❌ {driver}: No laps found")
            except Exception as e:
                print(f"  ❌ {driver}: Error - {e}")
        
        return all_telemetry
    
    def _resample_telemetry_to_timeline(self, telemetry: pd.DataFrame, timeline: pd.DatetimeIndex, driver: str) -> List[Dict[str, Any]]:
        """Resample driver telemetry to the absolute timeline"""
        if telemetry.empty or 'Date' not in telemetry.columns:
            return []
        
        # Set Date as index and sort
        telemetry_indexed = telemetry.set_index('Date').sort_index()
        
        # Resample to timeline using nearest neighbor
        resampled = telemetry_indexed.reindex(timeline, method='nearest', tolerance=pd.Timedelta('500ms'))
        
        # Convert to list of dictionaries
        result = []
        for i, (timestamp, row) in enumerate(resampled.iterrows()):
            if not row.isna().all():  # Skip rows where all data is NaN
                # Calculate session time from absolute timestamp
                if self.session_start_time:
                    session_time = (timestamp - self.session_start_time).total_seconds()
                else:
                    session_time = i / 10.0  # Fallback
                
                record = {
                    'driver': str(driver),
                    'timestamp': timestamp.isoformat(),
                    'session_time': session_time,
                    'race_time_minutes': session_time / 60.0,
                    'driver_ahead': str(row.get('DriverAhead', '')) if pd.notna(row.get('DriverAhead')) else None,
                    'distance_to_driver_ahead': float(row.get('DistanceToDriverAhead', 0)) if pd.notna(row.get('DistanceToDriverAhead')) else None,
                    'rpm': int(row.get('RPM', 0)) if pd.notna(row.get('RPM')) else None,
                    'speed': float(row.get('Speed', 0)) if pd.notna(row.get('Speed')) else None,
                    'gear': int(row.get('nGear', 1)) if pd.notna(row.get('nGear')) else None,
                    'throttle': float(row.get('Throttle', 0)) if pd.notna(row.get('Throttle')) else None,
                    'brake': float(row.get('Brake', 0)) if pd.notna(row.get('Brake')) else None,
                    'drs': bool(row.get('DRS', False)) if pd.notna(row.get('DRS')) else None,
                    'status': str(row.get('Status', 'OnTrack')) if pd.notna(row.get('Status')) else None,
                    'x': float(row.get('X', 0)) if pd.notna(row.get('X')) else None,
                    'y': float(row.get('Y', 0)) if pd.notna(row.get('Y')) else None,
                    'z': float(row.get('Z', 0)) if pd.notna(row.get('Z')) else None,
                }
                result.append(record)
        
        return result
    
    def _get_telemetry_fallback(self, frequency: int) -> Dict[str, List[Dict[str, Any]]]:
        """Fallback method for when absolute timing is not available"""
        print("Using fallback telemetry method...")
        
        # This is the original method from the first implementation
        drivers_telemetry = {}
        drivers_indices = {}
        
        for driver in self.drivers:
            try:
                driver_laps = self.session.laps.pick_drivers(driver)
                if not driver_laps.empty:
                    telemetry = driver_laps.get_telemetry().add_driver_ahead(drop_existing=True)
                    drivers_telemetry[driver] = telemetry
                    drivers_indices[driver] = 1
            except Exception as e:
                print(f"Error processing driver {driver}: {e}")
                drivers_telemetry[driver] = pd.DataFrame()
                drivers_indices[driver] = 1
        
        time_delta = pd.Timedelta(seconds=(1/frequency))
        timestamp = pd.Timedelta(seconds=0)
        
        all_telemetry = {driver: [] for driver in self.drivers}
        
        print("Starting fallback telemetry extraction...")
        stop_flag = False
        iteration = 0
        
        while not stop_flag:
            iteration += 1
            
            if iteration % (frequency * 60) == 0:
                print(f"Processing time: {str(timestamp).split()[-1]} (iteration {iteration})")
            
            for driver in self.drivers:
                if driver not in drivers_telemetry or drivers_telemetry[driver].empty:
                    continue
                
                telemetry_df = drivers_telemetry[driver]
                length = len(telemetry_df)
                
                while (drivers_indices[driver] < length and 
                       telemetry_df.iloc[drivers_indices[driver]]["SessionTime"] < timestamp):
                    drivers_indices[driver] += 1
                
                if drivers_indices[driver] >= length:
                    stop_flag = True
                    break
                
                if drivers_indices[driver] > 0:
                    data_point = telemetry_df.iloc[drivers_indices[driver] - 1]
                    
                    telemetry_record = {
                        'driver': str(driver),
                        'timestamp': timestamp.total_seconds(),
                        'session_time': data_point["SessionTime"].total_seconds(),
                        'race_time_minutes': data_point["SessionTime"].total_seconds() / 60.0,
                        'driver_ahead': str(data_point['DriverAhead']) if pd.notna(data_point['DriverAhead']) else None,
                        'distance_to_driver_ahead': float(data_point["DistanceToDriverAhead"]) if pd.notna(data_point["DistanceToDriverAhead"]) else None,
                        'rpm': int(data_point["RPM"]) if pd.notna(data_point["RPM"]) else None,
                        'speed': float(data_point["Speed"]) if pd.notna(data_point["Speed"]) else None,
                        'gear': int(data_point["nGear"]) if pd.notna(data_point["nGear"]) else None,
                        'throttle': float(data_point["Throttle"]) if pd.notna(data_point["Throttle"]) else None,
                        'brake': float(data_point["Brake"]) if pd.notna(data_point["Brake"]) else None,
                        'drs': bool(data_point["DRS"]) if pd.notna(data_point["DRS"]) else None,
                        'status': str(data_point["Status"]) if pd.notna(data_point["Status"]) else None,
                        'x': float(data_point["X"]) if pd.notna(data_point["X"]) else None,
                        'y': float(data_point["Y"]) if pd.notna(data_point["Y"]) else None,
                        'z': float(data_point["Z"]) if 'Z' in data_point and pd.notna(data_point["Z"]) else None,
                    }
                    
                    all_telemetry[driver].append(telemetry_record)
            
            timestamp += time_delta
            
            if timestamp.total_seconds() > 7200:  # 2 hours max
                print("Reached maximum time limit (2 hours), stopping extraction")
                break
        
        print(f"Fallback telemetry extraction completed. Total iterations: {iteration}")
        return all_telemetry
    
    def get_track_metadata(self) -> Dict[str, Any]:
        """Extract track metadata including track points and basic info"""
        if not self.session:
            raise ValueError("Session not loaded. Call load_session() first.")
        
        print("Extracting track metadata...")
        
        # Get track points from fastest lap
        track_telemetry = self.session.laps.pick_fastest().get_telemetry().add_distance()
        
        # Extract X, Y coordinates
        x_coords = np.array(track_telemetry['X'].values)
        y_coords = np.array(track_telemetry['Y'].values)
        track_points = [(int(x), int(y)) for x, y in zip(x_coords, y_coords)]
        
        # Get track info
        track_info = {
            'track_name': f"{self.year} {self.location}",
            'grand_prix_name': f"{self.year} {self.location} Grand Prix",
            'track_points': track_points,
            'track_points_count': len(track_points),
            'year': self.year,
            'location': self.location,
            'session_type': self.session_type,
            'session_start_time': self.session_start_time.isoformat() if self.session_start_time else None
        }
        
        self.track_data = track_info
        print(f"Track metadata extracted: {len(track_points)} track points")
        return track_info
    
    def save_data_to_files(self, telemetry_data: Dict[str, List[Dict[str, Any]]] = None, 
                          output_dir: str = "improved_f1_data"):
        """Save all extracted data to JSON files"""
        if not os.path.exists(output_dir):
            os.makedirs(output_dir)
        
        print(f"Saving data to {output_dir}/...")
        
        # Save track metadata
        if self.track_data:
            with open(f"{output_dir}/track_metadata.json", 'w') as f:
                json.dump(self.track_data, f, indent=2)
            print("Track metadata saved")
        
        # Save telemetry data
        if telemetry_data:
            print("Saving telemetry data...")
            for driver, data in telemetry_data.items():
                if data:
                    with open(f"{output_dir}/telemetry_driver_{driver}.json", 'w') as f:
                        json.dump(data, f, indent=2)
            print(f"Telemetry data saved for {len([d for d in telemetry_data.values() if d])} drivers")
        
        print("Data extraction and saving completed!")


def main():
    """Example usage of the ImprovedF1DataFetcher"""
    # Initialize fetcher
    fetcher = ImprovedF1DataFetcher(year=2024, location="Monaco", session_type="R")
    
    # Load session
    if not fetcher.load_session():
        print("Failed to load session")
        return
    
    # Extract track metadata
    print("\n=== Extracting Track Metadata ===")
    track_data = fetcher.get_track_metadata()
    
    # Extract telemetry with proper timing
    print("\n=== Extracting Telemetry with Proper Timing ===")
    telemetry_data = fetcher.get_race_telemetry_with_timing(frequency=10)
    
    # Save to files
    fetcher.save_data_to_files(telemetry_data=telemetry_data)
    
    print("\n=== Summary ===")
    print(f"Track points: {len(track_data['track_points'])}")
    print(f"Session start time: {track_data.get('session_start_time', 'Unknown')}")
    print(f"Telemetry data points per driver:")
    for driver, data in telemetry_data.items():
        if data:
            print(f"  Driver {driver}: {len(data)} points")
            if data:
                first_time = data[0]['timestamp']
                last_time = data[-1]['timestamp']
                print(f"    Time range: {first_time} to {last_time}")


if __name__ == "__main__":
    main()

