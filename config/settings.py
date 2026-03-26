# config/settings.py
from dotenv import load_dotenv
import os

load_dotenv()

# --- Credentials (from .env) ---
BOT_USERNAME = os.getenv("BOT_USERNAME")
BOT_PASSWORD = os.getenv("BOT_PASSWORD")

# --- GCS ---
GCS_CREDENTIALS_JSON = os.getenv("GCS_CREDENTIALS_JSON")
GCS_BUCKET_NAME = "singular-arbor-401018-calls-bucket"
GCS_PDF_PREFIX = "llamatel/pdfs"

# --- BigQuery ---
GCP_PROJECT_ID = "singular-arbor-401018"
BQ_DATASET_RAW = "raw"
BQ_DATASET_MARTS = "marts"
BQ_TABLE_CALLS = "llamatel-llamadas"

# --- Scraper ---
START_DATE = "01/01/2025"  # or make these parameters too DD/MM/YYYY
END_DATE   = "31/12/2025"
PDF_TMP_DIR = "/tmp/llamatel"

# --- URLs ---
BASE_URL = "https://llamatel.telefonodelaesperanza.org/index.php"