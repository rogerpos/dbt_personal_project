# this is a scheduler for the cloud run service that loads data from gcs to bigquery
# considering a manual approach

#!/bin/bash

set -e

PROJECT="data-gss"
CLOUDRUN_REGION="europe-north2"
SCHEDULER_REGION="europe-west1"
SERVICE_NAME="load-to-bigquery"
JOB_NAME="monthly-load-to-bq"
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --region $CLOUDRUN_REGION --project $PROJECT --format="value(status.url)")

echo "Creating Cloud Scheduler Job..."
# pass schedule as a variable or anyway as sth you can configure
gcloud scheduler jobs create http $JOB_NAME \
  --schedule="0 6 1 * *" \
  --uri="$SERVICE_URL" \
  --http-method=GET \
  --location=$SCHEDULER_REGION \
  --project=$PROJECT

echo "Scheduler created! Will run monthly on the 1st at 06:00 UTC"
  