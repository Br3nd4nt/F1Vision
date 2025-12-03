import redis
import json

class RedisClient:
    def __init__(self, track_layout_path: str, telemetry_path: str, host='localhost', port=6379):
        self.host = host
        self.port = port
        self.client = redis.Redis(host=self.host, port=self.port, decode_responses=True, db=0)
        if not self.check_connection():
            raise ConnectionError(f"Could not connect to Redis at {self.host}:{self.port}")

        self.track_layout_path = track_layout_path
        self.telemetry_path = telemetry_path

        self._track_layout_key = "track_layout"

    def save_track_layout(self):
        with open(self.track_layout_path, 'r') as file:
            data = json.load(file)
            self.client.set(self._track_layout_key, json.dumps(data))
        print(f"Track layout saved to Redis under key: {self._track_layout_key}")
    
    def get_track_layout(self):
        data = self.client.get(self._track_layout_key)
        if data:
            return json.loads(data)
        else:
            print(f"No track layout found in Redis for key: {self._track_layout_key}")
            return None
    
    def check_connection(self):
        try:
            self.client.ping()
            print("Connected to Redis successfully!")
            return True
        except redis.ConnectionError:
            print("Failed to connect to Redis.")
            return False
    
    def check_track_layout_exists(self):
        return self.check_key_exists(self._track_layout_key)

    def check_key_exists(self, key: str):
        return self.client.exists(key) == 1