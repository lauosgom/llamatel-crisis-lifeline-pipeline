from prefect import task
from warehouse.loader import load
import pandas as pd

@task(name="load-bq", retries=2, retry_delay_seconds=30)
def load_task(df: pd.DataFrame) -> None:
    load(df)