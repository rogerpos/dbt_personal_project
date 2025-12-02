#!/bin/bash

set -e

PROJECT="data-gss"
REGION="europe-north2"
REPO="cloud-run-source-deploy"
SERVICE="load-to-bigquery"
BUCKET_NAME="gss-raw-data"

echo "Checking if Artifact Registry repo exists..."
if ! gcloud artifacts repositories describe $REPO \
  --location=$REGION \
  --project=$PROJECT &>/dev/null; then
  echo "Creating Artifact Registry repo..."
  gcloud artifacts repositories create $REPO \
    --repository-format=docker \
    --location=$REGION \
    --project=$PROJECT \
    --quiet
else
  echo "Artifact Registry repo already exists."
fi

echo "Deploying to Cloud Run in $REGION..."
gcloud run deploy $SERVICE \
  --source . \
  --region $REGION \
  --no-allow-unauthenticated \
  --project $PROJECT

echo "Deployment completed!"
echo ""
echo "Service deployed: $SERVICE"
echo ""
echo "⚠️  IMPORTANT: Now set up the Eventarc trigger to listen for GCS changes."
echo "Run the setup_eventarc.sh script to create the trigger:"
echo "  ./setup_eventarc.sh"