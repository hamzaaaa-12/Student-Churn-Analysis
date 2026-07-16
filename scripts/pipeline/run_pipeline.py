from pathlib import Path
import subprocess
import sys
import time

from db_utils import execute_sql_file
from logger import logger

# ---------------------------------------------------
# Project Paths
# ---------------------------------------------------

BASE_DIR = Path(__file__).resolve().parents[2]

SCRIPTS_DIR = BASE_DIR / "scripts"
SQL_DIR = BASE_DIR / "sql"

# ---------------------------------------------------
# Pipeline Configuration
# ---------------------------------------------------

PYTHON_STEPS = [
    ("Load Raw Data", "02_load_raw_data.py"),
    ("Generate Data Quality Report", "03_data_quality_report.py"),
    ("Bronze to Silver ETL", "05_bronze_to_silver_etl.py"),
    ("Load Dimensions", "06_load_dimensions.py"),
]

SQL_STEPS = [
    ("Load Fact Engagement", "08_load_fact_engagement.sql"),
    ("Load Fact Assessment", "09_load_fact_assessment.sql"),
    ("Load Fact Churn", "10_load_fact_churn.sql"),
]


def run_python_script(step_name, script_name):

    logger.info("=" * 60)
    logger.info(f"START: {step_name}")

    start = time.perf_counter()

    try:

        subprocess.run(
            [sys.executable, str(SCRIPTS_DIR / script_name)],
            check=True
        )

        elapsed = time.perf_counter() - start

        logger.info(f"SUCCESS: {step_name}")
        logger.info(f"Execution Time: {elapsed:.2f} sec")

    except subprocess.CalledProcessError:

        elapsed = time.perf_counter() - start

        logger.exception(f"FAILED: {step_name}")
        logger.info(f"Execution Time: {elapsed:.2f} sec")

        raise


def run_sql_script(step_name, file_name):

    logger.info("=" * 60)
    logger.info(f"START: {step_name}")

    start = time.perf_counter()

    try:

        execute_sql_file(SQL_DIR / file_name)

        elapsed = time.perf_counter() - start

        logger.info(f"SUCCESS: {step_name}")
        logger.info(f"Execution Time: {elapsed:.2f} sec")

    except Exception:

        elapsed = time.perf_counter() - start

        logger.exception(f"FAILED: {step_name}")
        logger.info(f"Execution Time: {elapsed:.2f} sec")

        raise


def main():

    logger.info("")
    logger.info("=" * 70)
    logger.info("Student Churn Prediction Pipeline")
    logger.info("=" * 70)

    pipeline_start = time.perf_counter()

    # ------------------------------
    # Python ETL
    # ------------------------------

    for step_name, script in PYTHON_STEPS:
        run_python_script(step_name, script)

    # ------------------------------
    # SQL ELT
    # ------------------------------

    for step_name, sql_file in SQL_STEPS:
        run_sql_script(step_name, sql_file)

    total = time.perf_counter() - pipeline_start

    logger.info("")
    logger.info("=" * 70)
    logger.info("PIPELINE COMPLETED SUCCESSFULLY")
    logger.info(f"Total Execution Time: {total:.2f} sec")
    logger.info("=" * 70)


if __name__ == "__main__":
    main()