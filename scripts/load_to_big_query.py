from google.cloud import bigquery

client = bigquery.Client()

def load_csv_to_bq(uri, table_id):
    job_config = bigquery.LoadJobConfig(
        source_format=bigquery.SourceFormat.CSV,
        skip_leading_rows=1,
        autodetect=True,
        write_disposition="WRITE_TRUNCATE"
    )

    load_job = client.load_table_from_uri(
        uri,
        table_id,
        job_config=job_config
    )

    print(f"Starting job {load_job.job_id} to load {uri} → {table_id}")
    load_job.result()
    print(f"Loaded {load_job.output_rows} rows into {table_id}")

def main():
    bucket = "gs://gss-raw-data"

    files = {
        "orders": f"{bucket}/orders.csv",
        "returns": f"{bucket}/returns.csv"
    }

    dataset = "raw"

    for table, uri in files.items():
        load_csv_to_bq(uri, f"{dataset}.{table}")

if __name__ == "__main__":
    main()
