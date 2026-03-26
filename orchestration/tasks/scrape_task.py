from prefect import task
from ingestion.scraper import scrape

@task(name="scrape-pdfs", retries=2, retry_delay_seconds=60)
def scrape_task(on_record=None):
    scrape(on_record=on_record)