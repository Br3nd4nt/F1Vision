#!/usr/bin/env python3
import argparse
import json
import sys
import time

import socketio


def main():
    parser = argparse.ArgumentParser(description="Test client for F1Vision realtime server")
    parser.add_argument("--url", default="http://localhost:5001", help="Socket.IO server URL")
    args = parser.parse_args()

    sio = socketio.Client()

    @sio.event
    def connect():
        print(f"Connected to {args.url}")

    @sio.on("track")
    def on_track(data):
        print("[track] received")
        # print small summary
        try:
            name = data.get("name")
            length = data.get("length")
            points = len(data.get("points", []))
            print(f"  name={name} length={length} points={points}")
        except Exception:
            print(json.dumps(data)[:500])

    @sio.on("race_snapshot")
    def on_snapshot(data):
        # print first few fields only
        ts = data.get("timestamp")
        lap = data.get("lap")
        dcount = len(data.get("driverStates", []))
        print(f"[snapshot] ts={ts} lap={lap} drivers={dcount}")

    @sio.on("complete")
    def on_complete(data):
        print("[complete]", data)
        sio.disconnect()

    @sio.on("error")
    def on_error(data):
        print("[error]", data, file=sys.stderr)

    try:
        sio.connect(args.url, transports=["websocket", "polling"], wait_timeout=10)
        sio.wait()
    except KeyboardInterrupt:
        pass
    except Exception as e:
        print(f"Connection error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()


