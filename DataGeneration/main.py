import os

from src.f1_data import RaceTelemetryProcessor
import src.redis_client as redis_client


proccessor = RaceTelemetryProcessor(2025, 12)
session = proccessor.load_race_session()
proccessor.generate_track_layout()


redis_host = os.getenv("REDIS_HOST", "localhost")
redis_port = int(os.getenv("REDIS_PORT", 6379))
client = redis_client.RedisClient(
    track_layout_path=proccessor.get_track_layout_path(),
    telemetry_path=proccessor.get_telemetry_path(),
    host=redis_host,
    port=redis_port
)

if client.check_track_layout_exists():
    print("Track layout already exists in Redis.")
else:
    client.save_track_layout()


