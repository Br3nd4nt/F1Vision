# F1Vision 🏎️

## Data Generation

Generate F1 track and race data using FastF1.

### Usage

```bash
cd MockServer

# Generate track data
make track track=suzuka year=2024

# Generate race data  
make race track=monaco drivers=20 snapshots=100

# Copy data to Xcode project
make copy-race
make copy-track
make copy-all

# Show all commands
make help
```
