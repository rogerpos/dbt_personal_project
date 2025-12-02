#!/bin/bash

set -e

PROJECT="data-gss"
CLOUDRUN_REGION="europe-north2"
SCHEDULER_REGION="europe-west1"
SERVICE="upload-csv-to-gcs"
JOB_NAME="upload-csv-scheduler"
SCHEDULE="0 6 1 * *"  # Run at 6 AM on the 1st day of every month

echo "Creating Cloud Scheduler job for CSV upload..."

# Get the service URL
SERVICE_URL=$(gcloud run services describe $SERVICE \
  --region $CLOUDRUN_REGION \
  --project $PROJECT \
  --format 'value(status.url)')

echo "Service URL: $SERVICE_URL"
echo "Scheduler Region: $SCHEDULER_REGION (Cloud Scheduler not available in $CLOUDRUN_REGION)"

# Create or update the Cloud Scheduler job
gcloud scheduler jobs create http $JOB_NAME \
  --location=$SCHEDULER_REGION \
  --schedule="$SCHEDULE" \
  --uri="$SERVICE_URL" \
  --http-method=GET \
  --project=$PROJECT \
  --time-zone="Europe/Oslo" \
  --description="Automatically upload CSV files to GCS bucket" \
  --attempt-deadline=300s \
  || gcloud scheduler jobs update http $JOB_NAME \
      --location=$SCHEDULER_REGION \
      --schedule="$SCHEDULE" \
      --uri="$SERVICE_URL" \
      --project=$PROJECT

echo ""
echo "Cloud Scheduler job created/updated successfully!"
echo "Schedule: $SCHEDULE (Europe/Oslo timezone)"
echo ""
echo "To trigger manually:"
echo "  gcloud scheduler jobs run $JOB_NAME --location=$REGION --project=$PROJECT"
echo ""
echo "Or via HTTP:"
echo "  curl $SERVICE_URL"
