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
- Mock data generator (FastF1) which outputs JSONs into a Docker volume using frequency-based snapshots from real race data

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

Notes
-----

- FastF1 downloads and caches telemetry; first run may take time.
- Currently data is written to JSON files. Next step is writing into MongoDB.
