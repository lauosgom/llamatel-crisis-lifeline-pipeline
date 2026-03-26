import subprocess
from pathlib import Path
from prefect import task

DBT_PROJECT_DIR = Path(__file__).parent.parent.parent / "transform"

@task(name="run-dbt", retries=1, retry_delay_seconds=60)
def dbt_task() -> None:
    result = subprocess.run(
        ["uv", "run", "dbt", "run"],
        cwd=DBT_PROJECT_DIR,
        capture_output=True,
        text=True
    )
    print(result.stdout)
    if result.returncode != 0:
        raise Exception(result.stderr)