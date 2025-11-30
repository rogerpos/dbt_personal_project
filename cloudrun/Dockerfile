FROM python:3.12-slim

# Install OS-level dependencies (optional but recommended)
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY load_to_big_query_job.py .

ENV PORT=8080

CMD ["python", "load_to_big_query_job.py"]
