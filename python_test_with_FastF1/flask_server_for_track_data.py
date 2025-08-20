import threading
import fastf1
import json
import numpy as np
from flask import Flask
from flask_socketio import SocketIO

# Setup FastF1
fastf1.Cache.enable_cache('f1_cache')  # Enable the cache
fastf1.set_log_level('WARNING')

# Define the host and port for the server
HOST = '0.0.0.0'
TRACK_PORT = 6969

# Initialize Flask and Flask-SocketIO
app = Flask(__name__)
socketio = SocketIO(app, cors_allowed_origins="*")

def create_track_data(session):
    # global session
    # global segments
    print("getting telemetry")
    telemetry = session.laps.pick_fastest().get_telemetry().add_distance()
    print("telemetry collected")

    x = np.array(telemetry['X'].values)
    y = np.array(telemetry['Y'].values)

    points = np.array((x, y)).T.reshape(-1, 1, 2)

    segments = [(int(i[0][0]), int(i[0][1]), int(i[1][0]), int(i[1][1])) for i in np.concatenate([points[:-1], points[1:]], axis=1)]
    print(f"segmets created: {len(segments)} segments")
    return segments

@socketio.on('connect')
def handle_connect():
    print("Client connected")

@socketio.on('request_track_data')
def handle_request_track_data(param):
    print(f"got the param: {param}")
    print(f"loading session 2023 {param} race")
    session = fastf1.get_session(2023, param, "R")
    session.load()
    print(f"session data created")
    sectors = create_track_data(session)
    message = json.dumps(sectors)
    socketio.emit('track_data', message)
    print("track data sent")
    print(f"data: ``{message[:100]}``")

@socketio.on('disconnect')
def handle_disconnect():
    print("Client disconnected")

if __name__ == "__main__":
    socketio.run(app, host=HOST, port=TRACK_PORT)
