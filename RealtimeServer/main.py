import os
import json
import asyncio
import redis.asyncio as redis
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from contextlib import asynccontextmanager

redis_host = os.getenv("REDIS_HOST", "localhost")
redis_port = int(os.getenv("REDIS_PORT", 6379))

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
    track_json = await redis_client.get("track_layout")

    if track_json:
        await websocket.send_text(track_json)
    else:
        await websocket.send_json({
            "type": "error",
            "message": "Track layout not found"
        })
        await websocket.close()
        return