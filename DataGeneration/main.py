import os
import json
import asyncio
from src.f1_data import RaceTelemetryProcessor
import src.redis_client as redis_client

def main():
    print("Starting Redis telemetry generator...")
    proccessor = RaceTelemetryProcessor(2025, 12)
    session = proccessor.load_race_session()
    
    if not proccessor.check_track_layout_exists():
        print(f"No track layout found at {proccessor.get_track_layout_path()}")
        print("Generating track layout...")
        proccessor.generate_track_layout()
    if not proccessor.check_telemetry_exists():
        print(f"No telemetry data found at {proccessor.get_telemetry_path()}")
        print("Generating race telemetry...")
        proccessor.get_race_telemetry()


    redis_host = os.getenv("REDIS_HOST", "localhost")
    redis_port = int(os.getenv("REDIS_PORT", 6379))
    track_layout_key = os.getenv("TRACK_LAYOUT_KEY", "track_layout")
    driver_colors_key = os.getenv("DRIVER_COLOR_KEY", "driver_colors")
    telemetry_channel = os.getenv("TELEMETRY_CHANNEL", "telemetry_channel")
    frequency = int(os.getenv("DATA_FREQUENCY", 25))

    client = redis_client.RedisClient(
        track_layout_path=proccessor.get_track_layout_path(),
        telemetry_path=proccessor.get_telemetry_path(),
        host=redis_host,
        port=redis_port,
        track_layout_key=track_layout_key,
        telemetry_channel=telemetry_channel,
        data_frequency=frequency
    )

    if client.check_track_layout_exists():
        print("Track layout already exists in Redis.")
    else:
        client.save_track_layout()
    if client.check_driver_colors_exists():
        print("Driver colors already exist in Redis.")
    else:
        client.save_driver_colors()
    client.publish_telemetry_data()
    
main()

# if __name__ == "__main__":
#     asyncio.run(main())