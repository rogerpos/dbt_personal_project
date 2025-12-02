from fastapi import FastAPI
from google.cloud import storage
import os

app = FastAPI(title="GCS Upload Job", description="Upload CSV files to Google Cloud Storage")

BUCKET_NAME = "gss-raw-data"
RAW_FILES_DIR = "raw_files"

def upload_file_to_gcs(local_file_path, bucket_name, destination_blob_name):
    """Upload a file to GCS bucket"""
    print(f"[INFO] Uploading {local_file_path} to gs://{bucket_name}/{destination_blob_name}")
    
    storage_client = storage.Client(project="data-gss")
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(destination_blob_name)
    
    blob.upload_from_filename(local_file_path)
    
    print(f"[SUCCESS] File {local_file_path} uploaded to {destination_blob_name}")


def upload_csv_files():
    """Upload orders.csv and returns.csv to GCS"""
    print("[INFO] Starting CSV upload job")
    
    files_to_upload = ["orders.csv", "returns.csv"]
    
    for filename in files_to_upload:
        local_path = os.path.join(RAW_FILES_DIR, filename)
        
        if not os.path.exists(local_path):
            print(f"[WARNING] File {local_path} not found, skipping")
            continue
        
        # Upload to GCS bucket with the same filename
        upload_file_to_gcs(local_path, BUCKET_NAME, filename)
    
    print("[SUCCESS] CSV upload job completed successfully")
    return "CSV upload job completed successfully"


@app.get("/")
async def trigger():
    """Trigger CSV upload to GCS"""
    message = upload_csv_files()
    return {"message": message, "status": "success"}


@app.get("/health")
async def health():
    """Health check endpoint"""
    return {"status": "healthy", "service": "gcs-upload"}


if __name__ == "__main__":
    import uvicorn
    print("[DEBUG] Running locally on port 8080")
    uvicorn.run(app, host="0.0.0.0", port=8080)
