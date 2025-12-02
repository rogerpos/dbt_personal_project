#!/bin/bash

set -e

PROJECT="data-gss"
REGION="europe-north2"
SERVICE="load-to-bigquery"
BUCKET_NAME="gss-raw-data"
TRIGGER_NAME="gcs-load-to-bq-trigger"

echo "========================================="
echo "Setting up Eventarc trigger for GCS"
echo "========================================="
echo ""

# Get project number
PROJECT_NUMBER=$(gcloud projects describe $PROJECT --format='value(projectNumber)')
echo "Project Number: $PROJECT_NUMBER"
echo ""

# Get the Cloud Run service account
SERVICE_ACCOUNT=$(gcloud run services describe $SERVICE \
  --region=$REGION \
  --project=$PROJECT \
  --format="value(spec.template.spec.serviceAccount)" 2>/dev/null || echo "")

if [ -z "$SERVICE_ACCOUNT" ]; then
  echo "Using default compute service account..."
  SERVICE_ACCOUNT="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"
fi

echo "Service Account: $SERVICE_ACCOUNT"
echo ""

# Grant necessary permissions to the Cloud Run service account
echo "Step 1: Granting permissions to Cloud Run service account..."
echo "  - eventarc.eventReceiver"
gcloud projects add-iam-policy-binding $PROJECT \
  --member="serviceAccount:$SERVICE_ACCOUNT" \
  --role="roles/eventarc.eventReceiver" \
  --quiet 2>/dev/null || true

echo "  - run.invoker"
gcloud projects add-iam-policy-binding $PROJECT \
  --member="serviceAccount:$SERVICE_ACCOUNT" \
  --role="roles/run.invoker" \
  --quiet 2>/dev/null || true

echo ""
echo "Step 2: Granting permissions for Eventarc service accounts..."

# Eventarc service account needs storage access
EVENTARC_SA="service-${PROJECT_NUMBER}@gcp-sa-eventarc.iam.gserviceaccount.com"
echo "  - Granting storage.objectViewer to Eventarc SA on bucket..."
gsutil iam ch serviceAccount:${EVENTARC_SA}:roles/storage.objectViewer gs://${BUCKET_NAME} 2>/dev/null || true

# GCS service account needs to publish to Pub/Sub
GCS_SA="service-${PROJECT_NUMBER}@gs-project-accounts.iam.gserviceaccount.com"
echo "  - Granting pubsub.publisher to GCS SA..."
gcloud projects add-iam-policy-binding $PROJECT \
  --member="serviceAccount:${GCS_SA}" \
  --role="roles/pubsub.publisher" \
  --quiet 2>/dev/null || true

echo ""
echo "Step 3: Creating Eventarc trigger..."
echo "Trigger will activate when files are created/updated in gs://$BUCKET_NAME"
echo ""

# Create the Eventarc trigger
gcloud eventarc triggers create $TRIGGER_NAME \
  --location=$REGION \
  --destination-run-service=$SERVICE \
  --destination-run-region=$REGION \
  --event-filters="type=google.cloud.storage.object.v1.finalized" \
  --event-filters="bucket=$BUCKET_NAME" \
  --service-account=$SERVICE_ACCOUNT \
  --project=$PROJECT

echo ""
echo "========================================="
echo "Eventarc trigger created successfully!"
echo "========================================="
echo ""
echo "Trigger name: $TRIGGER_NAME"
echo "Event type: google.cloud.storage.object.v1.finalized"
echo "Bucket: gs://$BUCKET_NAME"
echo "Target service: $SERVICE"
echo ""
echo "The BigQuery load job will now automatically trigger when:"
echo "  - Files are uploaded to gs://$BUCKET_NAME"
echo "  - Files are updated in gs://$BUCKET_NAME"
echo ""
echo "To test the trigger:"
echo "  1. Upload a file to the bucket"
echo "  2. Check Cloud Run logs:"
echo "     gcloud logging read \"resource.type=cloud_run_revision AND resource.labels.service_name=$SERVICE\" \\"
echo "       --project $PROJECT --limit 20"
echo ""
echo "To list all triggers:"
echo "  gcloud eventarc triggers list --location=$REGION --project=$PROJECT"
echo ""
echo "To delete the trigger:"
echo "  gcloud eventarc triggers delete $TRIGGER_NAME --location=$REGION --project=$PROJECT"
