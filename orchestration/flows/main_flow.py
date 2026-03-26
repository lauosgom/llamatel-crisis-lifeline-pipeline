import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from prefect import flow, get_run_logger
from orchestration.tasks.extract_task import extract_task
from orchestration.tasks.upload_task import upload_task
from orchestration.tasks.load_task import load_task
from orchestration.tasks.dbt_task import dbt_task
from ingestion.scraper import scrape
from datetime import datetime, date
from calendar import monthrange


def get_last_month_range() -> tuple[str, str]:
    today = date.today()
    first_of_this_month = today.replace(day=1)
    last_month = (first_of_this_month - __import__('datetime').timedelta(days=1))
    year = last_month.year
    month = last_month.month
    last_day = monthrange(year, month)[1]
    return f"01/{month:02d}/{year}", f"{last_day}/{month:02d}/{year}"


@flow(name="llamatel-pipeline")
def main_flow(
    start_date: str = None,
    end_date: str = None,
):
    logger = get_run_logger()

    # if no dates provided, default to last month (used by scheduled runs)
    _start, _end = start_date, end_date
    if not _start or not _end:
        _start, _end = get_last_month_range()

    logger.info(f"Running pipeline for {_start} to {_end}")

    def handle_record(pdf_path: str) -> None:
        logger.info(f"Processing {pdf_path}")
        df = extract_task(pdf_path)
        upload_task(pdf_path)
        load_task(df)

    scrape(on_record=handle_record, start_date=_start, end_date=_end)
    dbt_task()


if __name__ == "__main__":
    main_flow(start_date="01/01/2025", end_date="31/01/2025")