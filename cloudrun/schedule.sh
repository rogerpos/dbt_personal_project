#!/bin/bash

set -e

PROJECT="data-gss"
REGION="europe-north2"
JOB_NAME="daily-load-to-bq"
SERVICE_URL=$(gcloud run services describe load-to-bigquery --region $REGION --project $PROJECT --format="value(status.url)")

echo "Creating Cloud Scheduler Job..."
gcloud scheduler jobs create http $JOB_NAME \
  --schedule="0 6 * * *" \
  --uri="$SERVICE_URL" \
  --http-method=GET \
  --location=$REGION \
  --project=$PROJECT

echo "Scheduler created! Will run daily at 06:00 UTC"
