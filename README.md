# 🏎️ F1Vision
## Project Structure
```
├── F1Vision
│   ├── Core
│   ├── Elements
│   └── Features
├── DataGeneration
└── RealtimeServer
```
- F1Vision - main Swift app
- DataGeneration - Python server using `fastf1` to generate race telemetry data and publish in to `Redis` database

Main telemetry generation code is heavily based (copied tbh) on [f1-race-replay](https://github.com/IAmTomShaw/f1-race-replay), which is insanely good and you should check out!!!

- RealtimeServer - uses `fastapi` with `websockets` to transalte telemetry data from `Redis` to users

## Running the project
Just run the `docker-compose.yml` file and you should be good to go. 

For the `F1Vision` project itself, you might want to specify the server ip address that docker containers fun on. 

To do that, just open the `F1Vision/App/Configuration.swift` file.