#!/bin/bash

set -e

PROJECT="data-gss"
REGION="europe-north2"
REPO="cloud-run-source-deploy"
SERVICE="upload-csv-to-gcs"

# Navigate to project root to include raw_files in build context
cd "$(dirname "$0")/.."

echo "Checking if Artifact Registry repo exists..."
if ! gcloud artifacts repositories describe $REPO --location=$REGION --project=$PROJECT &>/dev/null; then
  echo "Creating Artifact Registry repo..."
  gcloud artifacts repositories create $REPO \
    --repository-format=docker \
    --location=$REGION \
    --project=$PROJECT \
    --quiet
else
  echo "Artifact Registry repo already exists."
fi

echo "Building and deploying with Cloud Build (no local Docker needed)..."
gcloud builds submit . \
  --config=cloudrun/cloudbuild_upload.yaml \
  --project=$PROJECT

echo "Deploying to Cloud Run in $REGION..."
gcloud run deploy $SERVICE \
  --image "$REGION-docker.pkg.dev/$PROJECT/$REPO/$SERVICE:latest" \
  --region $REGION \
  --allow-unauthenticated \
  --project $PROJECT \
  --max-instances 1

echo "Deployment completed!"
echo ""
echo "To trigger the upload manually, run:"
echo "  SERVICE_URL=\$(gcloud run services describe $SERVICE --region $REGION --project $PROJECT --format 'value(status.url)')"
echo "  curl -X POST \$SERVICE_URL -H \"Content-Type: application/json\" -d '{\"your\": \"payload\"}'"
echo "  # Add authentication headers if required, e.g. -H \"Authorization: Bearer \$TOKEN\""
