import os
import json
import asyncio
import redis.asyncio as redis
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from contextlib import asynccontextmanager

redis_host = os.getenv("REDIS_HOST", "localhost")
redis_port = int(os.getenv("REDIS_PORT", 6379))
track_layout_key = os.getenv("TRACK_LAYOUT_KEY", "track_layout")
driver_colors_key = os.getenv("DRIVER_COLOR_KEY", "driver_colors")
telemetry_channel = os.getenv("TELEMETRY_CHANNEL", "telemetry_channel")
frequency = int(os.getenv("DATA_FREQUENCY", 25))

app = FastAPI()

redis_client = None

@asynccontextmanager
async def lifespan(app: FastAPI):
    global redis_client
    url = f"redis://{redis_host}:{redis_port}"
    redis_client = redis.from_url(url, decode_responses=True)
    yield
    await redis_client.close()  # clean up on shutdown

app = FastAPI(lifespan=lifespan)


@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()

    # send track layoyur
    track_json = await redis_client.get(track_layout_key)

    if track_json:
        message = {
            "type": "trackLayout",
            "data": json.loads(track_json)
        }
        await websocket.send_text(json.dumps(message))
    else:
        await websocket.send_json({
            "type": "error",
            "data": "Track layout not found"
        })
        await websocket.close()
        return

    driver_colors = await redis_client.get(driver_colors_key)

    if driver_colors:
        message = {
            "type": "driverColors",
            "data": json.loads(driver_colors)
        }
        await websocket.send_text(json.dumps(message))
    else:
        await websocket.send_json({
            "type": "error",
            "data": "Driver colors not found"
        })
        await websocket.close()
        return

    # subscribe to telemetry channel
    pubsub = redis_client.pubsub()
    await pubsub.subscribe(telemetry_channel)
    print(f"Subscribed to {telemetry_channel}")
    try:
        async for raw_msg in pubsub.listen():
            if raw_msg["type"] != "message":
                continue  # ignore subscription messages

            # Redis returns data as a string
            data_str = raw_msg["data"]
            try:
                # Decode the inner telemetry JSON
                data_obj = json.loads(data_str)
            except json.JSONDecodeError:
                print("Failed to decode telemetry frame")
                continue

            # Wrap with WebSocket message type
            ws_message = {
                "type": "snapshot",
                "data": data_obj
            }

            await websocket.send_text(json.dumps(ws_message))

    except WebSocketDisconnect:
        await pubsub.unsubscribe(telemetry_channel)
        await pubsub.close()
    except Exception as e:
        await websocket.send_json({
            "type": "error",
            "data": str(e)
        })
        await pubsub.unsubscribe(telemetry_channel)
        await pubsub.close()
