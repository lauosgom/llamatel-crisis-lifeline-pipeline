import sys
from pathlib import Path
PROJECT_ROOT = Path.home() / "data-engineering-zoomcamp-final-project"
sys.path.insert(0, str(PROJECT_ROOT))
from orchestration.flows.main_flow import main_flow

if __name__ == "__main__":
    main_flow.from_source(
        source="https://github.com/lauosgom/llamatel-crisis-lifeline-pipeline.git",
        entrypoint="orchestration/flows/main_flow.py:main_flow"
    ).deploy(
        name="llamatel-monthly",
        work_pool_name="my-work-pool",
        cron="0 8 1 * *",
        tags=["llamatel", "monthly"]
    )
