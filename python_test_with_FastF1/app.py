from flask import Flask
from flask_socketio import SocketIO
from peewee import *
from playhouse.postgres_ext import *
import os
import numpy as np
import warnings
warnings.filterwarnings('ignore')

db = PostgresqlDatabase(
    'f1Vision',  # Required by Peewee.
    user='user',  # Will be passed directly to psycopg2.
    password='password',  # Ditto.
    host='127.0.0.1')  # Ditto.

class BaseModel(Model):
    class Meta:
        database = db

class Track(BaseModel):
    name = CharField(unique=True)
    track_sectors = ArrayField(ArrayField(IntegerField))

class Driver(BaseModel):
    driverInitials = TextField()
    driverNumber = IntegerField()

class Race(BaseModel):
    timestamp = TimestampField(unique=True)
    driver = ForeignKeyField(Driver, backref="driver")
    driverPosition = IntegerField()
    xPosition = FloatField()
    yPosition = FloatField()
    zPosition = FloatField()



def setup_database(db_path: str):
    db.create_tables([Track, Driver, Race])

def create_track_data(db_path: str, trackName: str):
    import fastf1
    fastf1.Cache.enable_cache('f1_cache')  # Enable the cache
    # fastf1.set_log_level('WARNING')

    print(f"getting session data for {trackName}")
    session = fastf1.get_session(2023, trackName, 'r')
    session.load()
    print(f"getting telemetry for {trackName}")
    telemetry = session.laps.pick_fastest().get_telemetry().add_distance()
    x = np.array(telemetry["X"].values)
    y = np.array(telemetry["Y"].values)

    return np.array((x, y)).T

def main():
    db.connect()
    race = "baku"
    print("started")

def test_connection():
    db.connect()
    db.close()

if __name__ == "__main__":
    test_connection()