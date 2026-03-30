import subprocess
from pathlib import Path
from prefect import task

DBT_BIN = Path.home() / "data-engineering-zoomcamp-final-project" / "transform" / ".venv" / "bin" / "dbt"
DBT_PROJECT_DIR = Path.home() / "data-engineering-zoomcamp-final-project" / "transform"

@task(name="run-dbt", retries=1, retry_delay_seconds=60)
def dbt_task() -> None:
    import os
    import json
    
    # build env for dbt subprocess
    env = os.environ.copy()
    
    # parse GCS credentials and extract individual fields for dbt
    gcs_creds = json.loads(env.get("GCS_CREDENTIALS_JSON", "{}"))
    env["BQ_PRIVATE_KEY_ID"] = gcs_creds.get("private_key_id", "")
    env["BQ_PRIVATE_KEY"] = gcs_creds.get("private_key", "")
    env["BQ_CLIENT_EMAIL"] = gcs_creds.get("client_email", "")
    env["BQ_CLIENT_ID"] = gcs_creds.get("client_id", "")

    # run seeds first
    result_seed = subprocess.run(
        [str(DBT_BIN), "seed"],
        cwd=str(DBT_PROJECT_DIR),
        capture_output=True,
        text=True,
        env=env
    )
    print("SEED STDOUT:", result_seed.stdout)
    print("SEED STDERR:", result_seed.stderr)
    
    result = subprocess.run(
        [str(DBT_BIN), "run"],
        cwd=str(DBT_PROJECT_DIR),
        capture_output=True,
        text=True,
        env=env
    )
    print("STDOUT:", result.stdout)
    print("STDERR:", result.stderr)
    if result.returncode != 0:
        raise Exception(result.stdout + result.stderr)
