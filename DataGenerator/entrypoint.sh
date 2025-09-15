#!/usr/bin/env bash
set -euo pipefail

: "${MODE:=track}"
: "${TRACK:=Monaco}"
: "${YEAR:=2024}"
: "${FREQ:=200ms}"
: "${MONGO_URL:=}"

export MPLCONFIGDIR="${MPLCONFIGDIR:-/tmp/.mplconfig}"
mkdir -p "$FASTF1_CACHE_DIR" "$OUTPUT_TRACK_DIR" "$OUTPUT_RACE_DIR" "$MPLCONFIGDIR"

echo "MODE=$MODE TRACK=$TRACK YEAR=$YEAR FREQ=$FREQ MONGO_URL=${MONGO_URL:-<none>}"

export PATH="/opt/venv/bin:$PATH"

case "$MODE" in
  track)
    python3 track_data_generator.py "$TRACK" --year "$YEAR"
    ;;
  race)
    python3 race_data_builder.py --year "$YEAR" --track "$TRACK" --freq "$FREQ" --outdir "$OUTPUT_RACE_DIR"
    ;;
  both)
    python3 track_data_generator.py "$TRACK" --year "$YEAR"
    python3 race_data_builder.py --year "$YEAR" --track "$TRACK" --freq "$FREQ" --outdir "$OUTPUT_RACE_DIR"
    ;;
  *)
    echo "Unknown MODE: $MODE (expected: track|race|both)" >&2
    exit 1
    ;;
esac

echo "Done."

