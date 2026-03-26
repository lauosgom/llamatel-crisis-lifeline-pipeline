# ingestion/uploader.py
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

from google.cloud import storage
from google.oauth2 import service_account
from config.settings import GCS_BUCKET_NAME, GCS_PDF_PREFIX, GCS_CREDENTIALS_JSON
from datetime import datetime
import os
import json


def _get_client() -> storage.Client:
    credentials_info = json.loads(GCS_CREDENTIALS_JSON)
    credentials = service_account.Credentials.from_service_account_info(credentials_info)
    return storage.Client(credentials=credentials)


def upload(pdf_path: str) -> str:
    client = _get_client()
    bucket = client.bucket(GCS_BUCKET_NAME)

    date_folder = datetime.today().strftime("%Y_%m_%d")
    filename = os.path.basename(pdf_path)
    blob_name = f"{GCS_PDF_PREFIX}/{date_folder}/{filename}"

    blob = bucket.blob(blob_name)
    blob.upload_from_filename(pdf_path)
    os.remove(pdf_path)  # delete after upload
    print(f"Uploaded and removed {filename}")

    gcs_uri = f"gs://{GCS_BUCKET_NAME}/{blob_name}"
    print(f"Uploaded {filename} to {gcs_uri}")
    return gcs_uri


if __name__ == "__main__":
    import os

    dir_path = '/tmp/llamatel/'
    entries = os.listdir(dir_path)

    for entry in entries:
        if entry.endswith('.pdf'):
            pdf_path = os.path.join(dir_path, entry)
            upload(pdf_path)