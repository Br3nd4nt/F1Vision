# Realistic F1 Race Data Generator

This generator creates realistic F1 race data using **real telemetry data** from FastF1, ensuring proper continuity between snapshots and realistic race progression.

## 🚀 Key Improvements Over Old Generator

### **Old Generator Problems:**
- ❌ **Random tyre changes** between snapshots
- ❌ **Unrealistic driver position jumps**
- ❌ **No continuity** between race snapshots
- ❌ **Fake telemetry data**

### **New Generator Features:**
- ✅ **Real F1 telemetry data** from FastF1
- ✅ **Proper tyre strategy continuity** (soft → medium → hard)
- ✅ **Realistic driver progression** along track
- ✅ **Consistent lap progression** and timing
- ✅ **Real driver information** and team colors
- ✅ **Proper sector calculations** based on track position

## 📋 Requirements

```bash
pip install -r requirements_realistic.txt
```

Required packages:
- `fastf1>=3.3.0` - F1 data access
- `pandas>=1.5.0` - Data manipulation
- `numpy>=1.21.0` - Numerical operations

## 🎯 Usage

### **Basic Usage**

```bash
# Generate Monza 2024 race data with 100 snapshots
python realistic_race_generator.py --track monza --year 2024 --snapshots 100

# Generate Monaco 2024 race data with 50 snapshots
python realistic_race_generator.py --track monaco --year 2024 --snapshots 50

# Generate Spa 2023 race data with custom output
python realistic_race_generator.py --track spa --year 2023 --snapshots 75 --output custom_race.json
```

### **Command Line Arguments**

- `--year`: F1 season year (default: 2024)
- `--track`: Track name (default: monza)
- `--snapshots`: Number of snapshots to generate (default: 100)
- `--output`: Output file path (default: `raceData/{track}_{year}_race_data.json`)

### **Available Tracks**

The generator works with any track available in FastF1. Common tracks include:
- `monza` - Italian Grand Prix
- `monaco` - Monaco Grand Prix
- `spa` - Belgian Grand Prix
- `silverstone` - British Grand Prix
- `baku` - Azerbaijan Grand Prix
- `jeddah` - Saudi Arabian Grand Prix

## 🔧 How It Works

### **1. Data Loading**
- Loads real F1 session data from FastF1
- Extracts driver information and team colors
- Loads telemetry data for each driver

### **2. Realistic Tyre Strategy**
```python
# Monza (high-speed track)
if lap <= 15:
    compound = "medium"      # Start on medium
    age = lap
elif lap <= 35:
    compound = "hard"        # Switch to hard
    age = lap - 15
else:
    compound = "soft"        # Final stint on soft
    age = lap - 35
```

### **3. Driver Position Calculation**
- Uses real telemetry data to calculate positions
- Interpolates between known track points
- Maintains realistic progression along track

### **4. Continuity Between Snapshots**
- Each snapshot builds on the previous one
- Lap numbers progress realistically
- Tyre age increases consistently
- Driver positions move logically

## 📊 Output Format

The generator creates data in the same format as your iOS app expects:

```json
{
  "raceId": "monza_2024",
  "trackName": "monza",
  "year": 2024,
  "totalSnapshots": 100,
  "totalDrivers": 20,
  "generatedAt": "2025-08-25T10:30:00",
  "raceSnapshots": [
    {
      "timestamp": "2024-08-23T14:00:00",
      "lap": 1,
      "driverStates": [
        {
          "driverId": {
            "id": "VER33",
            "name": "Max Verstappen",
            "code": "VER",
            "number": 33,
            "team": "Red Bull Racing",
            "teamColorHex": "#0600EF",
            "country": "NED"
          },
          "lap": 1,
          "position": 1,
          "distance": 62.59,
          "speed": 269.1,
          "sector": 1,
          "intervalToLeader": null,
          "intervalToAhead": null,
          "pitStatus": false,
          "drsActive": false,
          "tyre": {
            "compound": "medium",
            "age": 1,
            "fresh": true
          }
        }
      ]
    }
  ]
}
```

## 🧪 Testing

Run the test script to verify the generator works:

```bash
python test_realistic_generator.py
```

This will:
- Generate a small test dataset (20 snapshots)
- Display sample data
- Save to `raceData/test_monza_2024_race_data.json`

## 🔄 Integration with iOS App

1. **Generate realistic data:**
   ```bash
   python realistic_race_generator.py --track monza --year 2024 --snapshots 100
   ```

2. **Copy to iOS project:**
   ```bash
   python copy_to_xcode.py
   ```

3. **The data will now show:**
   - **Realistic tyre progression** (medium → hard → soft)
   - **Consistent driver positions** along track
   - **Proper lap progression** and timing
   - **Real driver information** and team colors

## 🎨 Customization

### **Adding New Tracks**
The generator automatically works with any track available in FastF1. Just specify the track name:

```bash
python realistic_race_generator.py --track silverstone --year 2024
```

### **Custom Tyre Strategies**
Modify the `_calculate_tyre_strategy` method in `RealisticRaceGenerator` to add custom strategies for specific tracks.

### **Driver Ordering**
The current implementation uses a simple position calculation. You can enhance this by implementing more sophisticated race simulation logic.

## 🚨 Troubleshooting

### **FastF1 Cache Issues**
If you encounter FastF1 loading problems:
```bash
rm -rf .fastf1_cache
python realistic_race_generator.py
```

### **Memory Issues with Large Datasets**
For very large datasets, reduce the number of snapshots or use a smaller year range.

### **Track Not Found**
Ensure the track name matches FastF1's naming convention. Check available tracks:
```python
import fastf1
print(fastf1.get_event_schedule(2024))
```

## 📈 Performance

- **Small dataset (50 snapshots)**: ~30 seconds
- **Medium dataset (100 snapshots)**: ~1 minute
- **Large dataset (200 snapshots)**: ~2-3 minutes

The generator caches FastF1 data, so subsequent runs are much faster.

## 🔮 Future Enhancements

- **Pit stop simulation** with realistic timing
- **Weather effects** on tyre wear and performance
- **Incident simulation** (DNFs, penalties)
- **Multi-lap telemetry** for more accurate positioning
- **Real qualifying results** for starting grid

---

**Note**: This generator requires an internet connection to download F1 data from FastF1 on first run. Data is cached locally for subsequent runs.

