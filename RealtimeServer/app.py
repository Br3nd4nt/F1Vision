import os
import json
import time
from datetime import datetime
from typing import Any, Dict, Optional

from flask import Flask
from flask_socketio import SocketIO, emit
from pymongo import MongoClient


MONGO_URL = os.getenv("MONGO_URL", "mongodb://mongo:27017/f1vision")
STREAM_DELAY_MS = int(os.getenv("STREAM_DELAY_MS", "100"))  # interval between snapshots to simulate realtime
RACE_ID = os.getenv("RACE_ID", "")  # optional: force a specific raceId


def get_db():
    client = MongoClient(MONGO_URL)
    return client.get_default_database(), client


def find_latest_race_id(db) -> Optional[str]:
    doc = db["races"].find().sort("generatedAt", -1).limit(1)
    items = list(doc)
    if not items:
        return None
    return items[0].get("raceId")


def load_track_for_race(db, race_id: str) -> Optional[Dict[str, Any]]:
    race = db["races"].find_one({"raceId": race_id})
    if not race:
        return None
    track_name = race.get("trackName")
    year = race.get("year")
    # Our track id convention used in generator: f"{track.lower()}_{year}"
    if track_name and year:
        track_id = f"{str(track_name).lower()}_{int(year)}"
        track = db["tracks"].find_one({"id": track_id})
        return track
    return None


def stream_snapshots(db, race_id: str):
    # stream ordered by timestamp ascending
    cursor = db["race_snapshots"].find({"raceId": race_id}).sort("timestamp", 1)
    delay = STREAM_DELAY_MS / 1000.0
    for snap in cursor:
        # Remove Mongo _id for clean payload
        snap.pop("_id", None)
        emit("race_snapshot", snap)
        time.sleep(delay)


def create_app():
    app = Flask(__name__)
    app.config["SECRET_KEY"] = os.getenv("SECRET_KEY", "dev")
    socketio = SocketIO(app, cors_allowed_origins="*")

    @socketio.on("connect")
    def on_connect():
        db, client = get_db()
        try:
            race_id = RACE_ID or find_latest_race_id(db)
            if not race_id:
                emit("error", {"message": "No race found in database"})
                return

            # Send track layout first
            track = load_track_for_race(db, race_id)
            if track:
                track.pop("_id", None)
                emit("track", track)
            else:
                emit("error", {"message": f"Track not found for raceId {race_id}"})

            # Then stream snapshots
            stream_snapshots(db, race_id)
            emit("complete", {"raceId": race_id, "completedAt": datetime.utcnow().isoformat()})
        finally:
            client.close()

    @app.get("/health")
    def health():
        return {"status": "ok"}

    return app, socketio


if __name__ == "__main__":
    app, socketio = create_app()
    port = int(os.getenv("PORT", "5001"))
    # Use eventlet or gevent in production; default werkzeug for simplicity
    socketio.run(app, host="0.0.0.0", port=port, allow_unsafe_werkzeug=True)


