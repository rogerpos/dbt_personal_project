# 🚀 Quick Start Guide

## Setup (One-time)

1. Activate your virtual environment (if you have not already done so) and install project dependencies:
```bash
source .venv/bin/activate
pip install -r requirements.txt
```

2. Set up Google Cloud credentials:
```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/your/service-account-key.json"
```

## Run the Application

From the project root folder:
```bash
python backoffice/app.py
```
Or use uvicorn directly:
```bash
uvicorn app:app --reload --port 8080
```

The app will start on http://localhost:8080

## Access the Application

Once running, open your browser to:

- **Main Interface**: http://localhost:8080
- **API Documentation**: http://localhost:8080/docs
- **Alternative Docs**: http://localhost:8080/redoc

## Usage Example

1. Go to http://localhost:8080
2. Enter a year (e.g., 2019)
3. Click "Download CSV Report"
4. Your CSV file will download automatically

## Testing the API with curl

```bash
# Get CSV for 2019
curl "http://localhost:8080/export?year=2019" -o sales_2019.csv

# Check health
curl http://localhost:8080/health
```

## Stopping the Application

Press `Ctrl+C` in the terminal where the application is running.

## Restarting the Application

1. Stop it with `Ctrl+C`
2. Run `python backoffice/app.py` again
