import numpy as np
import pandas as pd
import fastf1
from pymongo import MongoClient
from time import sleep
fastf1.Cache.enable_cache(".fastf1_cache")
fastf1.set_log_level("ERROR")

def dp(message: str):
    # just for printing cool way
    print(f"[ ∞ DEBUG ∞ ]: {message}")

class DataInitializer:
    def __init__(self, mongo_client: MongoClient, track_db_name = "track_metadata", 
                telemetry_db_name = "telemetry", session_year = 2024, 
                session_place = "Miami", data_frequency = 10):
        self.mdb_client = mongo_client
        self.place = session_place
        self.year = session_year
        self.track_db_name = track_db_name
        self.telemetry_db_name = telemetry_db_name
        self.gp_name = f"{self.year} {self.place} race"
        self.data_frequencty = data_frequency
        self.time_delta = pd.Timedelta(seconds=(1/self.data_frequencty))
        self.data_created_flag = False

        dp(f"getting session data for {self.year} {self.place} race")
        self.session = fastf1.get_session(self.year, self.place, "R")
        self.session.load(telemetry=True)
        self.drivers = self.session.drivers
        dp("data collected")

    def create_track_data(self): 
        dp("getting track points")
        self.track_points_telemetry = self.session.laps.pick_fastest().get_telemetry().add_distance()
        x = np.array(self.track_points_telemetry['X'].values)
        y = np.array(self.track_points_telemetry['Y'].values)
        points = np.vstack((x, y)).T
        self.points = [(int(i[0]), int(i[1])) for i in points]
        dp(f'points created, size: {len(self.points)}')
        self.data_created_flag = True

    def save_track_metadata(self):
        if not self.data_created_flag:
            self.create_track_data()
        
        metadata = {
            'track_name': self.gp_name,
            'grand_prix_name': self.gp_name,
            'track_points': self.points,
            'track_points_count': len(self.points),
        }

        self.mdb_client[self.track_db_name][self.track_db_name].insert_one(metadata)

    def create_telemetry(self):
        if not self.data_created_flag:
            self.save_track_metadata()
        
        drivers_telemetry = {driver : self.session.laps.pick_drivers(driver).get_telemetry().add_driver_ahead(drop_existing=True)
                            for driver in self.drivers}
        drivers_indicies = {driver : 1
                            for driver in self.drivers}

        timestamp = pd.Timedelta(seconds=0)
        
        stop_flag = False

        dp("Starting to create data")

        while not stop_flag:
            if timestamp.total_seconds() % 600 == 0:
                dp(f"Current time: {str(timestamp).split()[-1]}")
                sleep(3)
                

            for driver in self.drivers:
                length = len(drivers_telemetry[driver])

                while drivers_telemetry[driver].iloc[drivers_indicies[driver]]["SessionTime"] < timestamp:
                    drivers_indicies[driver] += 1

                    if drivers_indicies[driver] == length:
                        stop_flag = True
                        break
                
                suitable_df = drivers_telemetry[driver].iloc[drivers_indicies[driver] - 1]

                data_record = {
                    "Driver": str(driver),
                    "Date" : str((suitable_df["Date"] - pd.Timestamp("1970-01-01")) // pd.Timedelta('1s')),
                    'DriverAhead' : str(suitable_df['DriverAhead']),
                    "DistanceToDriverAhead" : str(suitable_df["DistanceToDriverAhead"]),
                    "SessionTime" : str(suitable_df["SessionTime"].total_seconds()),
                    "RPM" : str(suitable_df["RPM"]), 
                    "Speed" : str(suitable_df["Speed"]),
                    "nGear" : str(suitable_df["nGear"]) ,
                    "Throttle" : str(suitable_df["Throttle"]),
                    "Brake" : str(suitable_df["Brake"]),
                    "DRS" : str(suitable_df["DRS"]),
                    "Status" : str(suitable_df["Status"]),
                    "X" : str(suitable_df["X"]),
                    "Y" : str(suitable_df["Y"]), 
                }
                name_length = 5
                name = f"{int(timestamp.total_seconds() * 10)}"
                name = f"{'0'*(name_length - len(name))}{name}"
                self.mdb_client[self.telemetry_db_name][f"{name}"].insert_one(data_record)
            sleep(.03)
            
            timestamp += self.time_delta