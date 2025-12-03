FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt ./

RUN pip install --no-cache-dir -r requirements.txt

COPY main.py .

ENV PYTHONPATH=/app/src

ENV REDIS_HOST=localhost
ENV REDIS_PORT=6379

#uvicorn main:app --host 0.0.0.0
CMD ["uvicorn", "main:app", "--host", "0.0.0.0"]
