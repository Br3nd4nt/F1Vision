import os
from DataInitialization import DataInitializer, dp
from pymongo import MongoClient
from pymongo.errors import ConnectionFailure
from flask import Flask
from flask_socketio import SocketIO
from time import sleep
import json

app = Flask(__name__)
socketio = SocketIO(app)
track_db_name = "track_metadata"
telemetry_db_name = "telemetry"
host = "0.0.0.0"
mdb_port = 27017
socketio_port = 8000
client = None

@socketio.on("connect")
def connected():
    dp("Client connected")

@socketio.on("disconnect")
def disconnected():
    dp("Client disconnected")

@socketio.on('get_track_info')
def handle_track_info():
    track_info = client[track_db_name][track_db_name].find_one({}, {'_id': 0})
    dp(f"track info from database: {str(track_info)[:100]}")
    socketio.emit('track_info', json.dumps(track_info))

@socketio.on('get_telemetry')
def handle_telemetry(data):
    # timestamp = data['timestamp']
    timestamp = data

    # we assume that the timestamp from the client is already in correct format "xxxxx" (x - digit)

    # TODO: need to add check for that

    telemetry = list(client[telemetry_db_name][timestamp].find({}, {'_id': 0}))
    socketio.emit("telemetry_data", json.dumps(telemetry))


if __name__ == '__main__':
    
    dp("App started.")

    try:
        mongo_uri = os.getenv('MONGO_URI', f'mongodb://{host}:{mdb_port}')
        client = MongoClient(mongo_uri)
        client.admin.command('ping')
        
        dp("Mongo DB connection successful.")
    except ConnectionFailure as e:
        dp(f"Error connecting Mongo DB: {e}")
        dp("Retry in 40 seconds")
        sleep(40) # mongo takes too long to start up
        try:
            client = MongoClient(mongo_uri)
            client.admin.command('ping')
            dp("Mongo DB connection successful on retry.")
        except ConnectionFailure as e:
            dp(f"Error connecting Mongo DB after retry: {e}")
            exit(1)



    if not (track_db_name in client.list_database_names() and telemetry_db_name in client.list_database_names()):
        dp("Database is empty.")
        dp("Creating telemetry.")

        di = DataInitializer(client, track_db_name = track_db_name, telemetry_db_name = telemetry_db_name)
        di.create_telemetry()


    dp(f"Starting socketio server on {host}:{socketio_port}")
    socketio.run(app, host=host, port=socketio_port, allow_unsafe_werkzeug=True)