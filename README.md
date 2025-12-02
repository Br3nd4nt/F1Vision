# F1Vision
### Watch F1 race telemetry in real time


## Runnning the project 
Firstly, you need to create test data. After clonging the project, go to `DataGenerator` and run the data generation script:
```bash
uv run race_data_builder.py
```
You can use `uv` or any other package manager of your preference.

After that there will be track and race data generated:
```
DataGenerator
├── race_data_builder.py
└── race_output
    ├── race_data.json
    └── track_layout.json
```

Head over to Xcode and copy `race_data.json` and `track_layout.json` into the project (preferably into `Resources` folder).

After that you are good to go!