FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
    && rm -rf /var/lib/apt/lists/*

# Use uv for faster installs
RUN pip install --no-cache-dir uv==0.4.24

# Prefer uv with pyproject
COPY pyproject.toml README.md /app/
RUN uv pip install --system .

COPY app.py /app/

ENV MONGO_URL="mongodb://mongo:27017/f1vision" \
    STREAM_DELAY_MS=100 \
    PORT=5001

EXPOSE 5001

CMD ["python", "app.py"]


