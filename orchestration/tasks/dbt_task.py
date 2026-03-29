import subprocess
from pathlib import Path
from prefect import task

DBT_BIN = Path.home() / "data-engineering-zoomcamp-final-project" / "transform" / ".venv" / "bin" / "dbt"
DBT_PROJECT_DIR = Path.home() / "data-engineering-zoomcamp-final-project" / "transform"

@task(name="run-dbt", retries=1, retry_delay_seconds=60)
def dbt_task() -> None:
    result = subprocess.run(
        [str(DBT_BIN), "run"],
        cwd=str(DBT_PROJECT_DIR),
        capture_output=True,
        text=True
    )
    print("STDOUT:", result.stdout)
    print("STDERR:", result.stderr)
    print("Return code:", result.returncode)
    if result.returncode != 0:
        raise Exception(result.stdout + result.stderr)
