import os
import argparse
from src.f1_data import RaceTelemetryProcessor
import src.redis_client as redis_client

def parse_args():
    parser = argparse.ArgumentParser(description="F1 telemetry generator + Redis streamer")

    parser.add_argument(
        "--year",
        type=int,
        default=2025,
        help="Race year (default: 2025)"
    )

    parser.add_argument(
        "--round",
        type=int,
        default=12,
        help="Race round number (default: 12)"
    )

    parser.add_argument(
        "--generate-only",
        action="store_true",
        help="Just generate data"
    )

    return parser.parse_args()

def generate_data(processor):
    print("Checking track layout...")
    if not processor.check_track_layout_exists():
        print(f"No track layout found at {processor.get_track_layout_path()}")
        print("Generating track layout...")
        processor.generate_track_layout()
    else:
        print("Track layout already exists.")

    print("Checking telemetry...")
    if not processor.check_telemetry_exists():
        print(f"No telemetry data found at {processor.get_telemetry_path()}")
        print("Generating race telemetry...")
        processor.get_race_telemetry()
    else:
        print("Race telemetry already exists.")


def main():
    args = parse_args()

    race_year = int(os.getenv("RACE_YEAR", args.year))
    race_round = int(os.getenv("RACE_ROUND", args.round))

    print(f"Starting Telemetry Generator for {race_year} Round {race_round}")

    processor = RaceTelemetryProcessor(race_year, race_round)
    processor.load_race_session()
    generate_data(processor)
    if args.generate_only:
        return
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
