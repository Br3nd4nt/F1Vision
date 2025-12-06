FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt ./

RUN pip install --no-cache-dir -r requirements.txt

COPY main.py .

ENV PYTHONPATH=/app/src

ENV PYTHONUNBUFFERED=1

ENV REDIS_HOST=localhost
ENV REDIS_PORT=6379

ENV TRACK_LAYOUT_KEY=track_layout
ENV DRIVER_COLORS_KEY=driver_colors
ENV TELEMETRY_CHANNEL=telemetry_channel

ENV DATA_FREQUENCY=25

#uvicorn main:app --host 0.0.0.0
CMD ["uvicorn", "main:app", "--host", "0.0.0.0"]
