FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

# System deps for building numpy/pandas and FastF1 requirements
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        git \
    && rm -rf /var/lib/apt/lists/*

# Copy dependency definitions
COPY pyproject.toml uv.lock /app/

# Install uv (fast Python package installer) if not present in base
RUN pip install --no-cache-dir uv==0.4.24

# Create a virtualenv to isolate deps (optional but clean)
RUN python -m venv /opt/venv && . /opt/venv/bin/activate && \
    uv pip install --system -r uv.lock || uv pip install --system .

# Copy source
COPY . /app

# Make entrypoint executable
RUN chmod +x /app/entrypoint.sh

# Default output/cache directories (can be mounted as volumes)
ENV FASTF1_CACHE_DIR=/app/.fastf1_cache \
    OUTPUT_TRACK_DIR=/app/trackData \
    OUTPUT_RACE_DIR=/app/raceData

VOLUME [ "/app/.fastf1_cache", "/app/trackData", "/app/raceData" ]

# Environment-driven execution
# MODE: track | race | both
# TRACK: e.g. Monaco, Silverstone
# YEAR: e.g. 2024
# DRIVERS: int (for race generator)
# SNAPSHOTS: int (for race generator)
ENV MODE=track TRACK=Monaco YEAR=2024 DRIVERS=20 SNAPSHOTS=50

ENTRYPOINT ["/app/entrypoint.sh"]

