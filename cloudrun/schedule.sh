#!/bin/bash

set -e

PROJECT="data-gss"
CLOUDRUN_REGION="europe-north2"
SCHEDULER_REGION="europe-west1"
SERVICE_NAME="load-to-bigquery"
JOB_NAME="daily-load-to-bq"
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --region $CLOUDRUN_REGION --project $PROJECT --format="value(status.url)")

echo "Creating Cloud Scheduler Job..."
gcloud scheduler jobs create http $JOB_NAME \
  --schedule="0 6 * * *" \
  --uri="$SERVICE_URL" \
  --http-method=GET \
  --location=$SCHEDULER_REGION \
  --project=$PROJECT

echo "Scheduler created! Will run daily at 06:00 UTC"
