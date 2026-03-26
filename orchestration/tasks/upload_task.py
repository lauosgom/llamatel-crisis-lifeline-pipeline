from prefect import task
from ingestion.uploader import upload

@task(name="upload-pdf", retries=2, retry_delay_seconds=30)
def upload_task(pdf_path: str) -> str:
    return upload(pdf_path)