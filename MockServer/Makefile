# F1 Data Generator Makefile
# Commands for generating track and race data

.PHONY: help track race realistic-race full-race smart-race auto-tracks azerbaijan clean

help:
	@echo "🏁 F1 Data Generator - Available commands:"
	@echo ""
	@echo "📊 Track Data Generation (Standalone):"
	@echo "  make track track=TrackName year=2024"
	@echo ""
	@echo "🏎️  Race Data Generation (Old Generator):"
	@echo "  make race track=TrackName year=2024 drivers=20 snapshots=50"
	@echo ""
	@echo "🏎️  Race Data Generation (Realistic - RECOMMENDED):"
	@echo "  make realistic-race track=TrackName year=2024 snapshots=100"
	@echo ""
	@echo "🚀 Full Race Generation (Track + Race - RECOMMENDED):"
	@echo "  make full-race track=TrackName year=2024 snapshots=100"
	@echo ""
	@echo "🧠 Smart Race Generation (Auto-detect track data):"
	@echo "  make smart-race track=TrackName year=2024 snapshots=100"
	@echo ""
	@echo "🎯 Auto Track Generation (Multiple tracks):"
	@echo "  make auto-tracks tracks='monaco spa monza' year=2024"
	@echo "  make auto-tracks-popular year=2024"
	@echo ""
	@echo "🇦🇿 Azerbaijan Quick Generation:"
	@echo "  make azerbaijan year=2024 snapshots=100"
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
	@echo "  make realistic-race track=silverstone year=2024 snapshots=100"
	@echo "  make full-race track=monza year=2024 snapshots=150"
	@echo "  make smart-race track=spa year=2024 snapshots=120"
	@echo "  make auto-tracks tracks='monaco spa monza' year=2024"
	@echo "  make azerbaijan year=2024 snapshots=120"

year ?= 2024
drivers ?= 20
snapshots ?= 100

track:
	@if [ -z "$(track)" ]; then \
		echo "❌ Error: Please specify a track name"; \
		echo "Usage: make track track=suzuka year=2024"; \
		exit 1; \
	fi
	@echo "🏁 Generating $(track) track data..."
	@python3 track_data_generator.py "$(track)" --year "$(year)"
	@echo "📁 Copying track data to Xcode project..."
	@python3 copy_to_xcode.py --type track
	@echo "✅ Track data generation complete!"

race:
	@if [ -z "$(track)" ]; then \
		echo "❌ Error: Please specify a track name"; \
		echo "Usage: make race track=suzuka year=2024 drivers=20 snapshots=50"; \
		exit 1; \
	fi
	@echo "🏁 Generating $(track) race data (Old Generator)..."
	@python3 race_data_generator.py "$(track)" --year "$(year)" --drivers "$(drivers)" --snapshots "$(snapshots)"
	@echo "📁 Copying race data to Xcode project..."
	@python3 copy_to_xcode.py --type race
	@echo "✅ Race data generation complete!"

realistic-race:
	@if [ -z "$(track)" ]; then \
		echo "❌ Error: Please specify a track name"; \
		echo "Usage: make realistic-race track=suzuka year=2024 snapshots=100"; \
		exit 1; \
	fi
	@echo "🏁 Generating $(track) realistic race data..."
	@python3 realistic_race_generator.py --track "$(track)" --year "$(year)" --snapshots "$(snapshots)"
	@echo "📁 Copying race data to Xcode project..."
	@python3 copy_to_xcode.py --type race
	@echo "✅ Realistic race data generation complete!"

full-race:
	@if [ -z "$(track)" ]; then \
		echo "❌ Error: Please specify a track name"; \
		echo "Usage: make full-race track=suzuka year=2024 snapshots=100"; \
		exit 1; \
	fi
	@echo "🚀 Generating complete $(track) race package (Track + Race)..."
	@echo "🏁 Step 1: Generating $(track) track data..."
	@python3 track_data_generator.py "$(track)" --year "$(year)"
	@echo "🏎️  Step 2: Generating $(track) realistic race data..."
	@python3 realistic_race_generator.py --track "$(track)" --year "$(year)" --snapshots "$(snapshots)"
	@echo "📁 Step 3: Copying all data to Xcode project..."
	@python3 copy_to_xcode.py
	@echo "✅ Complete $(track) race package generated successfully!"
	@echo "📱 You can now run the app with $(track) data!"

smart-race:
	@if [ -z "$(track)" ]; then \
		echo "❌ Error: Please specify a track name"; \
		echo "Usage: make smart-race track=suzuka year=2024 snapshots=100"; \
		exit 1; \
	fi
	@echo "🧠 Smart generation for $(track) - checking existing data..."
	@if [ -f "./trackData/$(track)_track_layout.json" ]; then \
		echo "✅ Track data found - generating race data only..."; \
		echo "🏎️  Generating $(track) realistic race data..."; \
		python3 realistic_race_generator.py --track "$(track)" --year "$(year)" --snapshots "$(snapshots)"; \
		echo "📁 Copying race data to Xcode project..."; \
		python3 copy_to_xcode.py --type race; \
		echo "✅ Race data generation complete!"; \
	else \
		echo "⚠️  Track data not found - generating complete package..."; \
		echo "🏁 Step 1: Generating $(track) track data..."; \
		python3 track_data_generator.py "$(track)" --year "$(year)"; \
		echo "🏎️  Step 2: Generating $(track) realistic race data..."; \
		python3 realistic_race_generator.py --track "$(track)" --year "$(year)" --snapshots "$(snapshots)"; \
		echo "📁 Step 3: Copying all data to Xcode project..."; \
		python3 copy_to_xcode.py; \
		echo "✅ Complete $(track) race package generated successfully!"; \
	fi
	@echo "📱 You can now run the app with $(track) data!"

auto-tracks:
	@if [ -z "$(tracks)" ]; then \
		echo "❌ Error: Please specify tracks to generate"; \
		echo "Usage: make auto-tracks tracks='monaco spa monza' year=2024"; \
		exit 1; \
	fi
	@echo "🎯 Auto-generating track data for: $(tracks)"
	@python3 auto_track_generator.py --tracks $(tracks) --year "$(year)"

auto-tracks-popular:
	@echo "🎯 Auto-generating track data for all popular F1 tracks..."
	@python3 auto_track_generator.py --popular --year "$(year)"

azerbaijan:
	@echo "🇦🇿 Generating Azerbaijan (Baku) data..."
	@echo "🏁 Generating Baku track data..."
	@python3 track_data_generator.py "baku" --year "$(year)"
	@echo "🏎️  Generating Baku realistic race data..."
	@python3 realistic_race_generator.py --track "baku" --year "$(year)" --snapshots "$(snapshots)"
	@echo "📁 Copying all data to Xcode project..."
	@python3 copy_to_xcode.py
	@echo "✅ Azerbaijan data generation complete!"

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

