import threading
import fastf1
import json
import numpy as np
from flask import Flask
from flask_socketio import SocketIO
import logging
from math import sin, cos, pi, radians

# Setup FastF1
fastf1.Cache.enable_cache('f1_cache')  # Enable the cache
fastf1.set_log_level('WARNING')

# Define the host and port for the server
HOST = '0.0.0.0'
TRACK_PORT = 6969

# Initialize Flask and Flask-SocketIO
app = Flask(__name__)
app.logger.setLevel(logging.ERROR)
socketio = SocketIO(app, cors_allowed_origins="*")

def create_track_data(session, target_ratio):
    print("getting telemetry")
    telemetry = session.laps.pick_fastest().get_telemetry().add_distance()
    print("telemetry collected")

    x = np.array(telemetry['X'].values)
    y = np.array(telemetry['Y'].values)

    points = np.array((x, y)).T.reshape(-1, 1, 2)

    segments = [(int(i[0][0]), int(i[0][1]), int(i[1][0]), int(i[1][1])) for i in np.concatenate([points[:-1], points[1:]], axis=1)]
    print(f"segmets created: {len(segments)} segments")
    angle = find_best_rotation_angle(segments, target_ratio)
    print(f"found best rotation angle: {angle}") 

    return rotateRelativeToZero(segments, angle) 

def rotateRelativeToZero(pointsArray, angle): 
    rotationMatrix = np.array([[cos(angle), -sin(angle)], [sin(angle), cos(angle)]]) 
    newSectors = []
    for sector in pointsArray:
        points1 = np.array([[sector[0]], [sector[1]]])
        points2 = np.array([[sector[2]], [sector[3]]])
        newPoints1 = rotationMatrix @ points1
        newPoints2 = rotationMatrix @ points2
        newSectors.append((round(newPoints1[0][0]), round(newPoints1[1][0]), round(newPoints2[0][0]), round(newPoints2[1][0])))
    return newSectors

def find_best_rotation_angle(sectors, target_ratio = 0):
    scale = 10
    angle = 0
    if target_ratio == 0:
        return 0
    best_boundaries = getBoundaries(sectors)
    for thetta in range(180 * scale):
        new_data = rotateRelativeToZero(sectors, radians(thetta / scale))
        boundaries = getBoundaries(new_data)
        if (abs(target_ratio- boundaries[2]) > abs(target_ratio - best_boundaries[2])):
            angle = thetta / scale
            print(f"found better angle!: angle: {angle / scale}\tratio:{boundaries[2]} delta: {abs(target_ratio- boundaries[2])}")
            best_boundaries = boundaries
    return angle 

@socketio.on('connect')
def handle_connect():
    print("Client connected")

@socketio.on('request_track_data')
def handle_request_track_data(param):
    # print(param)
    target_ratio = 0
    if len(param) == 0:
        param = "baku"
    print(f"got the param: {param}\t target ratio: {target_ratio}")
    print(f"loading session 2023 {param} race")
    session = fastf1.get_session(2023, param, "R")
    session.load()
    print(f"session data created")
    sectors = create_track_data(session, target_ratio)
    message = json.dumps(sectors)
    socketio.emit('track_data', message)
    print("track data sent")
    print(f"data: ``{message[:100]}``")

@socketio.on('disconnect')
def handle_disconnect():
    print("Client disconnected")

def getBoundaries(sectors):
    xmi = ymi = float('inf')
    xma = yma = -float('inf')
    for i in sectors:
        xmi = min(xmi, i[0])
        xma = max(xma, i[0])
        ymi = min(ymi, i[1])
        yma = max(yma, i[1])
    return (xmi, xma, ymi, yma), (xma - xmi, yma - ymi),  1 / ((yma - ymi) / (xma - xmi))

def test():
    session = fastf1.get_session(2023, 'monaco', 'r')
    session.load()
    sectors = create_track_data(session)
    print(getBoundaries(sectors))


if __name__ == "__main__":
    # test()
    socketio.run(app, host=HOST, port=TRACK_PORT)
