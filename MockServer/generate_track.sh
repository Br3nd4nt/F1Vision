#!/bin/bash

# F1 Track Data Generator - Simple wrapper script
# Usage: ./generate_track.sh "Track Name" [year]

if [ $# -eq 0 ]; then
    echo "🏁 F1 Track Data Generator"
    echo "Usage: $0 \"Track Name\" [year]"
    echo ""
    echo "Examples:"
    echo "  $0 \"Abu Dhabi\""
    echo "  $0 Monaco 2023"
    echo "  $0 Silverstone 2024"
    exit 1
fi

TRACK_NAME="$1"
YEAR="${2:-2024}"

echo "🏁 Generating track data for: $TRACK_NAME (Year: $YEAR)"
python3 track_data_generator.py "$TRACK_NAME" --year "$YEAR"
