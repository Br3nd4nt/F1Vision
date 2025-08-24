# F1 Data Generator Makefile
# Commands for generating track and race data

.PHONY: help track race clean

help:
	@echo "🏁 F1 Data Generator - Available commands:"
	@echo ""
	@echo "📊 Track Data Generation:"
	@echo "  make track track=TrackName year=2024"
	@echo ""
	@echo "🏎️  Race Data Generation:"
	@echo "  make race track=TrackName year=2024 drivers=20 snapshots=50"
	@echo ""
	@echo "🧹 Maintenance:"
	@echo "  make clean         - Clean generated data files"
	@echo "  make copy-race     - Copy race data to Xcode"
	@echo "  make copy-track    - Copy track data to Xcode"
	@echo "  make copy-all      - Copy all data to Xcode"
	@echo ""
	@echo "📝 Examples:"
	@echo "  make track track=suzuka year=2024"
	@echo "  make track track=monaco year=2023"
	@echo "  make race track=silverstone year=2024 drivers=15 snapshots=100"
	@echo "  make race track=monza year=2024 drivers=20 snapshots=200"

year ?= 2024
drivers ?= 20
snapshots ?= 50

track:
	@if [ -z "$(track)" ]; then \
		echo "❌ Error: Please specify a track name"; \
		echo "Usage: make track track=suzuka year=2024"; \
		exit 1; \
	fi
	@echo "🏁 Generating $(track) track data..."
	@python3 track_data_generator.py "$(track)" --year "$(year)"

race:
	@if [ -z "$(track)" ]; then \
		echo "❌ Error: Please specify a track name"; \
		echo "Usage: make race track=suzuka year=2024 drivers=20 snapshots=50"; \
		exit 1; \
	fi
	@echo "🏁 Generating $(track) race data..."
	@python3 race_data_generator.py "$(track)" --year "$(year)" --drivers "$(drivers)" --snapshots "$(snapshots)"

clean:
	@echo "🧹 Cleaning generated data files..."
	@rm -rf ./trackData/*.json
	@rm -rf ./raceData/*.json
	@echo "✅ Cleaned track and race data files"

copy-race:
	@echo "📁 Copying race data to Xcode project..."
	@python3 copy_to_xcode.py --type race

copy-track:
	@echo "📁 Copying track data to Xcode project..."
	@python3 copy_to_xcode.py --type track

copy-all:
	@echo "📁 Copying all data to Xcode project..."
	@python3 copy_to_xcode.py --type all

