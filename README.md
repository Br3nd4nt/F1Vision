Dockerized Mock Data + MongoDB
==============================

Quick start
-----------

1) Build and run services:

```
docker compose up -d --build
```

This starts:
- MongoDB at localhost:27017
- Data generator (FastF1) which outputs JSONs and can persist into MongoDB using frequency-based snapshots from real race data
- Realtime server on ws(s)://localhost:5000 using Socket.IO

2) Generated output

JSON and cache are stored in a named volume mounted at `/data` inside the container:
- `/data/trackData`
- `/data/raceData`
- `/data/.fastf1_cache`

To inspect files on host:

```
docker compose run --rm mock-data ls -la /data/trackData
docker compose run --rm mock-data ls -la /data/raceData
```

Configuration
-------------

Edit `docker-compose.yml` env for the generator:
- `MODE`: `track` | `race` | `both`
- `TRACK`: e.g. `Monaco`, `Silverstone`
- `YEAR`: e.g. `2024`
- `FREQ`: e.g. `200ms`, `500ms`, `1s` (sampling frequency for snapshots)
- `MONGO_URL`: set to write data into MongoDB (default wired to the compose mongo service)

Realtime server
---------------

- Connect via Socket.IO to `http://localhost:5000`
- Events:
  - `track`: emitted first after connect, contains the `TrackLayoutModel`
  - `race_snapshot`: emitted repeatedly with ordered snapshots for the latest race
  - `complete`: emitted after the final snapshot
  - `error`: error messages


Notes
-----

- FastF1 downloads and caches telemetry; first run may take time.
- Currently data is written to JSON files. Next step is writing into MongoDB.
