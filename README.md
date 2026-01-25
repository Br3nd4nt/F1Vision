# 🏎️ F1Vision
<!-- ## Project Structure
```
└── F1Vision
    ├── Core
    ├── Elements
    └── Features

``` -->
<!-- - F1Vision - main Swift app
- DataGeneration - Python server using `fastf1` to generate race telemetry data and publish in to `Redis` database

Main telemetry generation code is heavily based (copied tbh) on [f1-race-replay](https://github.com/IAmTomShaw/f1-race-replay), which is insanely good and you should check out!!!

- RealtimeServer - uses `fastapi` with `websockets` to transalte telemetry data from `Redis` to users -->

## Running the project
<!-- Just run the `docker-compose.yml` file and you should be good to go. 

For the `F1Vision` project itself, you might want to specify the server ip address that docker containers fun on. 

To do that, just open the `F1Vision/App/Configuration.swift` file. -->
### 1. Backend
Project is configured to communicate with [f1-dash](https://github.com/slowlydev/f1-dash) backend. It uses Rust, so you will need to have `cargo` installed.

I recommend checking [this fork](https://github.com/AbsentData/f1-dash/). It provides data generation logic.
```bash
# this will prompt you to create a new file with data 
cargo r -p generator
```
> [!CAUTION]
> Data models provided with these generatoed files are kinda unstable, so I highly advice you to create **2025 mexico race**, otherwise there probably will be problems parsing server messsages.

After the data was created using fork provided above, or other ways described in the original repo, just start simulator to simulate the F1 SignalR server and start live server to start the actual backend up!

```bash
cargo r -p simulator 2025-mexico-race.data.txt # simulator
cargo r -p live # live server
```

after that you should be good to go!


### 2.  App
Just open the project in XCode and it should run just fine! 

To Change some settings, like Server IP and other stuff, open `F1Vision/App/Configuration.swift`