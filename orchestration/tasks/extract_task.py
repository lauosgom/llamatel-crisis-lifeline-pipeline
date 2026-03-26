from prefect import task
from ingestion.extractor import extract
import pandas as pd

@task(name="extract-pdf", retries=1, retry_delay_seconds=30)
def extract_task(pdf_path: str) -> pd.DataFrame:
    return extract(pdf_path)