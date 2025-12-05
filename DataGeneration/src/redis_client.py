import redis
import json
import time

class RedisClient:
    def __init__(self, 
                 track_layout_path: str, 
                 telemetry_path: str, 
                 host='localhost', 
                 port=6379, 
                 data_frequency=25, 
                 track_layout_key='track_layout', 
                 telemetry_channel='telemetry_channel',
                 driver_colors_key='driver_colors'):
        self.host = host
        self.port = port
        self.client = redis.Redis(host=self.host, port=self.port, decode_responses=True, db=0)
        
        if not self.check_connection():
            raise ConnectionError(f"Could not connect to Redis at {self.host}:{self.port}")

        self.track_layout_path = track_layout_path
        self.telemetry_path = telemetry_path

        self._track_layout_key = track_layout_key
        self._telemetry_channel = telemetry_channel
        self._driver_colors_key = driver_colors_key

        self.telemetry = None

        self._sleep_time = 1 / data_frequency

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
    
    def save_driver_colors(self):
        if not self.telemetry:
            self.load_telemetry_data()
        color_info = self.telemetry['driver_colors']
        self.client.set(self._driver_colors_key, json.dumps(color_info))
        print(f"Driver colors saved to Redis under key: {self._driver_colors_key}")

    def load_driver_colors(self):
        data = self.client.get(self._driver_colors_key)
        if data:
            return json.loads(data)
        else:
            print(f"No driver colors found in Redis for key: {self._driver_colors_key}")
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

    def check_driver_colors_exists(self):
        return self.check_key_exists(self._driver_colors_key)
    
    # telemetry pub sub stuff
    def publish(self, channel: str, message: dict):
        self.client.publish(channel, json.dumps(message))

    def publish_telemetry_data(self):
        print("Starting telemetry data publishing...")
        if not self.telemetry:
            self.load_telemetry_data()
        for _, data_point in enumerate(self.telemetry['frames']):
            self.publish(self._telemetry_channel, data_point)
            if _ % 5000 == 0:
                print(f"Published {_} telemetry frames...")
            time.sleep(self._sleep_time)
        print("Done.")

    def load_telemetry_data(self):
        with open(self.telemetry_path, 'r') as file:
            print("Loading telemetry data...")
            self.telemetry = json.load(file)
            print("Loaded.")