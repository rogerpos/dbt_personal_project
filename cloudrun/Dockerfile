FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY load_to_big_query_job.py .

ENV PORT=8080

CMD ["python", "load_to_big_query_job.py"]
