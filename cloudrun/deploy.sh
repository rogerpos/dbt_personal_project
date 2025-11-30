#!/bin/bash

set -e

PROJECT="data-gss"
REGION="europe-north2"
REPO="cloud-run-source-deploy"
SERVICE="load-to-bigquery"

echo "Creating Artifact Registry repo (if not exists)..."
gcloud artifacts repositories create $REPO \
  --repository-format=docker \
  --location=$REGION \
  --project=$PROJECT \
  --quiet || true

echo "Deploying to Cloud Run in $REGION..."
gcloud run deploy $SERVICE \
  --source . \
  --region $REGION \
  --allow-unauthenticated \
  --project $PROJECT

echo "Deployment completed!"