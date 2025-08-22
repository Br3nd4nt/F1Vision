# F1 Track Data Generator Makefile
# Simple commands for generating track data

.PHONY: help abu-dhabi monaco silverstone monza spa

help:
	@echo "🏁 F1 Track Data Generator - Available commands:"
	@echo ""
	@echo "Quick track generation:"
	@echo "  make abu-dhabi     - Generate Abu Dhabi track data"
	@echo "  make monaco        - Generate Monaco track data"
	@echo "  make silverstone   - Generate Silverstone track data"
	@echo "  make monza         - Generate Monza track data"
	@echo "  make spa           - Generate Spa track data"
	@echo ""
	@echo "Custom track generation:"
	@echo "  make track TRACK=\"Track Name\" YEAR=2024"
	@echo ""
	@echo "Examples:"
	@echo "  make track TRACK=\"Red Bull Ring\" YEAR=2023"
	@echo "  make track TRACK=\"Hungaroring\""

abu-dhabi:
	@echo "🏁 Generating Abu Dhabi track data..."
	@python3 track_data_generator.py "Abu Dhabi"

monaco:
	@echo "🏁 Generating Monaco track data..."
	@python3 track_data_generator.py "Monaco"

silverstone:
	@echo "🏁 Generating Silverstone track data..."
	@python3 track_data_generator.py "Silverstone"

monza:
	@echo "🏁 Generating Monza track data..."
	@python3 track_data_generator.py "Monza"

spa:
	@echo "🏁 Generating Spa track data..."
	@python3 track_data_generator.py "Spa"

YEAR ?= 2024

track:
	@if [ -z "$(TRACK)" ]; then \
		echo "❌ Error: Please specify a track name"; \
		echo "Usage: make track TRACK=\"Track Name\" YEAR=2024"; \
		exit 1; \
	fi
	@echo "🏁 Generating $(TRACK) track data..."
	@python3 track_data_generator.py "$(TRACK)" --year "$(YEAR)"
