# warehouse/loader.py
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

from datetime import datetime, timezone
import pandas as pd
from google.cloud import bigquery
from google.oauth2 import service_account
from config.settings import GCS_CREDENTIALS_JSON, GCP_PROJECT_ID, BQ_DATASET_RAW, BQ_TABLE_CALLS, GCS_BUCKET_NAME, GCS_PDF_PREFIX
import json


def _get_client() -> bigquery.Client:
    credentials_info = json.loads(GCS_CREDENTIALS_JSON)
    credentials = service_account.Credentials.from_service_account_info(
        credentials_info,
        scopes=["https://www.googleapis.com/auth/cloud-platform"]
    )
    return bigquery.Client(credentials=credentials, project=GCP_PROJECT_ID)


def _prepare_df(df: pd.DataFrame) -> pd.DataFrame:
    # Fields that are now STRING in BigQuery
    string_fields = [
        "medio_contacto", "codigo_letras",
        "llamante_sexo", "llamante_edad", "llamante_estado_civil", "llamante_convive",
        "llamante_asiduidad", "llamante_problema", "llamante_naturaleza", "llamante_inicio",
        "llamante_actitud_orientador", "llamante_presentacion", "llamante_paralenguaje",
        "llamante_procedencia", "llamante_peticion", "llamante_actitud_problema",
        "llamante_llamada_derivada", "tercero_sexo", "tercero_edad", "tercero_estado_civil",
        "tercero_convive", "tercero_relacion", "tercero_problema", "tercero_actitud_problema",
        "llamada_resultado", "llamada_duracion", "orientador_clave_numero", "orientador_nivel_ayuda",
        "orientador_sentimientos", "orientador_autoevaluacion", "orientador_actitudes_equivocadas",
        "orientador_satisfaccion_llamante",
    ]
    for col in string_fields:
        if col in df.columns:
            df[col] = df[col].astype(str).where(df[col].notna(), None)

    # Fields that stay INTEGER
    int_fields = ["num_pages", "codigo_numero", "total_llamadas"]
    for col in int_fields:
        if col in df.columns:
            df[col] = pd.to_numeric(df[col], errors="coerce").astype("Int64")

    # Date fields
    if "llamada_fecha" in df.columns:
        df["llamada_fecha"] = pd.to_datetime(df["llamada_fecha"], format="%d/%m/%Y", errors="coerce").dt.date
    if "entrevista_fecha" in df.columns:
        df["entrevista_fecha"] = pd.to_datetime(df["entrevista_fecha"], format="%d/%m/%Y", errors="coerce").dt.date

    # Time fields
    if "llamada_hora" in df.columns:
        df["llamada_hora"] = pd.to_datetime(df["llamada_hora"], format="%H:%M:%S", errors="coerce").dt.time
    if "entrevista_hora" in df.columns:
        df["entrevista_hora"] = pd.to_datetime(df["entrevista_hora"], format="%H:%M:%S", errors="coerce").dt.time

    return df


def load(df: pd.DataFrame) -> None:
    """
    Merges a single-row DataFrame into the raw BigQuery table.
    If a record with the same filename already exists, it will be skipped.
    """
    client = _get_client()
    table_id = f"{GCP_PROJECT_ID}.{BQ_DATASET_RAW}.{BQ_TABLE_CALLS}"

    df = _prepare_df(df)

    # add import datetime
    df["imported_at"] = datetime.now(timezone.utc)

    # Check if record already exists
    filename = df["filename"].iloc[0]
    query = f"SELECT COUNT(*) as count FROM `{table_id}` WHERE filename = '{filename}'"
    result = client.query(query).result()
    count = next(result)["count"]

    # pdf location in GCS - derive from filename
    filename_bucket = os.path.basename(df["filename"].iloc[0])
    date_folder = datetime.now(timezone.utc).strftime("%Y_%m_%d")
    df["gcs_path"] = f"gs://{GCS_BUCKET_NAME}/{GCS_PDF_PREFIX}/{date_folder}/{filename_bucket}"

    if count > 0:
        print(f"Skipping {filename}, already in BigQuery.")
        return

    job_config = bigquery.LoadJobConfig(
        write_disposition=bigquery.WriteDisposition.WRITE_APPEND,
        schema_update_options=[bigquery.SchemaUpdateOption.ALLOW_FIELD_RELAXATION],
    )

    job = client.load_table_from_dataframe(df, table_id, job_config=job_config)
    job.result()
    print(f"Loaded {filename} into {table_id}")


if __name__ == "__main__":
    from ingestion.extractor import extract
    import os
    files = os.listdir("/tmp/llamatel/")
    for file in files:
        df = extract(f"/tmp/llamatel/{file}")
        load(df)