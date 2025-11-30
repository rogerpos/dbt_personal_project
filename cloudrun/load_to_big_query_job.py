from flask import Flask
from google.cloud import bigquery

app = Flask(__name__)

def get_orders_schema():
    return [
        bigquery.SchemaField("row_id", "INTEGER"),
        bigquery.SchemaField("order_id", "STRING"),
        bigquery.SchemaField("order_date", "STRING"),
        bigquery.SchemaField("ship_date", "STRING"),
        bigquery.SchemaField("ship_mode", "STRING"),
        bigquery.SchemaField("customer_id", "STRING"),
        bigquery.SchemaField("customer_name", "STRING"),
        bigquery.SchemaField("segment", "STRING"),
        bigquery.SchemaField("country_region", "STRING"),
        bigquery.SchemaField("city", "STRING"),
        bigquery.SchemaField("state_province", "STRING"),
        bigquery.SchemaField("postal_code", "STRING"),
        bigquery.SchemaField("region", "STRING"),
        bigquery.SchemaField("product_id", "STRING"),
        bigquery.SchemaField("category", "STRING"),
        bigquery.SchemaField("sub_category", "STRING"),
        bigquery.SchemaField("product_name", "STRING"),
        bigquery.SchemaField("sales", "FLOAT64"),
        bigquery.SchemaField("quantity", "INTEGER"),
        bigquery.SchemaField("discount", "FLOAT64"),
        bigquery.SchemaField("profit", "FLOAT64"),
    ]


def get_returns_schema():
    return [
        bigquery.SchemaField("returned", "STRING"),
        bigquery.SchemaField("order_id", "STRING"),
    ]


def load_csv_to_bq(uri, table_id, schema=None):
    print(f"[INFO] Starting load for: {uri} → {table_id}")

    client = bigquery.Client(project="data-gss")

    job_config = bigquery.LoadJobConfig(
        source_format=bigquery.SourceFormat.CSV,
        skip_leading_rows=1,
        write_disposition="WRITE_TRUNCATE",
    )

    if schema:
        job_config.schema = schema
    else:
        job_config.autodetect = True
        job_config.column_name_character_map = "V2"

    load_job = client.load_table_from_uri(uri, table_id, job_config=job_config)

    print(f"[INFO] BigQuery job started: {load_job.job_id}")
    load_job.result()
    print(f"[SUCCESS] Loaded {load_job.output_rows} rows into {table_id}")


def run_ingestion():
    print("[INFO] Ingestion job started")

    bucket = "gs://gss-raw-data"
    dataset = "raw"

    orders_uri = f"{bucket}/orders.csv"
    load_csv_to_bq(orders_uri, f"{dataset}.orders", schema=get_orders_schema())

    returns_uri = f"{bucket}/returns.csv"
    load_csv_to_bq(returns_uri, f"{dataset}.returns", schema=get_returns_schema())

    print("[SUCCESS] Ingestion job completed successfully")
    return "Ingestion job completed successfully"


@app.route("/", methods=["GET"])
def trigger():
    return run_ingestion(), 200


if __name__ == "__main__":
    print("[DEBUG] Running locally on port 8080")
    app.run(host="0.0.0.0", port=8080)
