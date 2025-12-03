from fastapi import FastAPI, Query, HTTPException
from fastapi.responses import StreamingResponse, HTMLResponse
from google.cloud import bigquery
import csv
import os
from datetime import datetime
from io import StringIO

app = FastAPI(title="Sales Back Office", description="Export sales reports to CSV")

# HTML template for the UI
HTML_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
    <title>Sales Back Office</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            background-color: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            border-bottom: 2px solid #4CAF50;
            padding-bottom: 10px;
        }
        form {
            margin-top: 20px;
        }
        label {
            display: block;
            margin-top: 15px;
            font-weight: bold;
            color: #555;
        }
        input[type="number"] {
            width: 200px;
            padding: 10px;
            margin-top: 5px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 16px;
        }
        button {
            margin-top: 20px;
            padding: 12px 30px;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
        }
        button:hover {
            background-color: #45a049;
        }
        .info {
            margin-top: 20px;
            padding: 15px;
            background-color: #e7f3fe;
            border-left: 4px solid #2196F3;
            border-radius: 4px;
        }
        .error {
            margin-top: 20px;
            padding: 15px;
            background-color: #ffebee;
            border-left: 4px solid #f44336;
            border-radius: 4px;
            color: #c62828;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>📊 Sales Back Office</h1>
        <p>Generate a CSV report of top-selling states and regions for a specific year.</p>
        
        <form action="/export" method="get">
            <label for="year">Select Year:</label>
            <input type="number" id="year" name="year" min="2000" max="2030" 
                   value="{{ current_year }}" required>
            
            <div>
                <button type="submit">Download CSV Report</button>
            </div>
        </form>
        
        <div class="info">
            <strong>Report includes:</strong>
            <ul>
                <li>Country</li>
                <li>Region</li>
                <li>State/Province</li>
                <li>Regional Manager</li>
                <li>Total Sales</li>
            </ul>
        </div>
    </div>
</body>
</html>
"""


def get_top_selling_states_query(year):
    """
    Generate the SQL query for top selling states and regions for a given year.
    Based on the dbt model: top_selling_states_regions_2019
    """
    return f"""
    WITH orders_year AS (
        SELECT
            state_province,
            sales,
            region,
            country_region
        FROM `data-gss.raw.orders`
        WHERE EXTRACT(YEAR FROM PARSE_DATE('%d/%m/%Y', order_date)) = {year}
    ),

    enriched AS (
        SELECT
            o.state_province,
            o.region,
            o.country_region,
            p.`Regional Manager` as regional_manager,
            o.sales
        FROM orders_year AS o
        LEFT JOIN `data-gss.raw.people` AS p
            ON o.region = p.`Region`
    )

    SELECT
        country_region,
        region,
        state_province,
        regional_manager,
        SUM(sales) AS total_sales
    FROM enriched
    GROUP BY 1, 2, 3, 4
    ORDER BY total_sales DESC
    """


@app.get("/", response_class=HTMLResponse)
async def index():
    """Home page with the form to select year"""
    current_year = datetime.now().year - 1  # Default to last year
    html_content = HTML_TEMPLATE.replace("{{ current_year }}", str(current_year))
    return HTMLResponse(content=html_content)


@app.get("/export")
async def export_csv(year: int = Query(..., ge=2000, le=2030, description="Year to query")):
    """Export query results to CSV"""
    
    try:
        # Initialize BigQuery client
        client = bigquery.Client(project="data-gss")
        
        # Get the query
        query = get_top_selling_states_query(year)
        
        print(f"[INFO] Executing query for year: {year}")
        
        # Execute query
        query_job = client.query(query)
        results = query_job.result()
        
        # Create CSV in memory
        output = StringIO()
        writer = csv.writer(output)
        
        # Write header
        writer.writerow([
            'country_region',
            'region',
            'state_province',
            'regional_manager',
            'total_sales'
        ])
        
        # Write data rows
        row_count = 0
        for row in results:
            writer.writerow([
                row.country_region,
                row.region,
                row.state_province,
                row.regional_manager,
                round(row.total_sales, 2)
            ])
            row_count += 1
        
        print(f"[SUCCESS] Exported {row_count} rows for year {year}")
        
        # Prepare the file for download
        output.seek(0)
        
        # Create filename
        filename = f"top_selling_states_regions_{year}.csv"
        
        # Return CSV as streaming response
        return StreamingResponse(
            iter([output.getvalue()]),
            media_type="text/csv",
            headers={
                "Content-Disposition": f"attachment; filename={filename}"
            }
        )
        
    except Exception as e:
        print(f"[ERROR] Failed to export CSV: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/health")
async def health():
    """Health check endpoint"""
    return {"status": "healthy", "service": "backoffice"}


if __name__ == "__main__":
    import uvicorn
    port = int(os.environ.get("PORT", 8080))
    print(f"[INFO] Starting Back Office application on port {port}")
    uvicorn.run(app, host="0.0.0.0", port=port)
