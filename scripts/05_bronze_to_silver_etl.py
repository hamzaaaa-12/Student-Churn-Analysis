from pathlib import Path
import logging
import os

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

# ==========================================================
# Configuration
# ==========================================================

BASE_DIR = Path(__file__).resolve().parent.parent

load_dotenv(BASE_DIR / ".env")

DATABASE_URL = os.getenv("DATABASE_URL")

engine = create_engine(DATABASE_URL)

# ==========================================================
# Logging
# ==========================================================

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s"
)

logger = logging.getLogger(__name__)
etl_report = []
# ==========================================================
# Table Configuration
# ==========================================================

TABLE_CONFIG = {

    "studentInfo": {

        "text_columns": [
            "code_module",
            "code_presentation",
            "gender",
            "region",
            "highest_education",
            "imd_band",
            "age_band",
            "disability",
            "final_result"
        ],

        "validation": lambda df: (
            (df["studied_credits"] > 0)
            &
            (df["num_of_prev_attempts"] >= 0)
        )

    },

    "studentRegistration": {

        "text_columns": [
            "code_module",
            "code_presentation"
        ],

        "validation": lambda df: (
            (df["date_unregistration"].isna())
            |
            (df["date_registration"] <= df["date_unregistration"])
        )

    },

    "studentVle": {

        "text_columns": [
            "code_module",
            "code_presentation"
        ],

        "validation": lambda df: (
            df["sum_click"] >= 0
        )

    },

    "studentAssessment": {

        "text_columns": [],

        "validation": lambda df: (
            df["score"].between(0, 100)
            &
            df["is_banked"].isin([0, 1])
        )

    },

    "assessments": {

        "text_columns": [
            "code_module",
            "code_presentation",
            "assessment_type"
        ],

        "validation": lambda df: (
            df["weight"].between(0, 100)
        )

    },

    "vle": {

        "text_columns": [
            "code_module",
            "code_presentation",
            "activity_type"
        ],

        "validation": lambda df: (
            df["week_from"] <= df["week_to"]
        )

    },

    "courses": {

        "text_columns": [
            "code_module",
            "code_presentation"
        ],

        "validation": lambda df: (
            df["module_presentation_length"] > 0
        )

    }

}

# ==========================================================
# Generic ETL Function
# ==========================================================

def process_table(table_name, config):

    logger.info(f"Processing {table_name}")

    # ---------------------------------------------
    # Read Bronze
    # ---------------------------------------------

    df = pd.read_sql(
        f"SELECT * FROM engagement_raw.{table_name}",
        engine
    )

    rows_before = len(df)

    # ---------------------------------------------
    # Remove duplicates
    # ---------------------------------------------

    df = df.drop_duplicates()

    duplicates_removed = rows_before - len(df)

    logger.info(f"Duplicates removed: {duplicates_removed}")

    # ---------------------------------------------
    # Trim text columns
    # ---------------------------------------------

    for column in config["text_columns"]:

        df[column] = df[column].str.strip()

    # ---------------------------------------------
    # Standardize final_result
    # ---------------------------------------------

    if "final_result" in df.columns:

        df["final_result"] = df["final_result"].str.title()

    # ---------------------------------------------
    # Apply validation rules
    # ---------------------------------------------

    # ---------------------------------------------
    # Apply validation rules
    # ---------------------------------------------

    valid_mask = config["validation"](df)

    valid_rows = df[valid_mask].copy()

    invalid_rows = df[~valid_mask].copy()

    logger.info(f"Valid rows: {len(valid_rows)}")
    logger.info(f"Invalid rows: {len(invalid_rows)}")

    # ---------------------------------------------
    # Load Quarantine
    # ---------------------------------------------

    with engine.begin() as conn:

        conn.execute(
            text(
                f"TRUNCATE TABLE engagement_quarantine.{table_name}"
            )
        )

    if not invalid_rows.empty:

        invalid_rows["quarantine_reason"] = "Business Rule Violation"

        invalid_rows["source_table"] = table_name

        invalid_rows.to_sql(
            table_name,
            con=engine,
            schema="engagement_quarantine",
            if_exists="append",
            index=False
        )

        logger.warning(
            f"{len(invalid_rows)} rows moved to Quarantine."
        )

    # ---------------------------------------------
    # Load Silver
    # ---------------------------------------------

    with engine.begin() as conn:

        conn.execute(
            text(
                f"TRUNCATE TABLE engagement_clean.{table_name}"
            )
        )

    valid_rows.to_sql(
        table_name,
        con=engine,
        schema="engagement_clean",
        if_exists="append",
        index=False
    )

    logger.info(
        f"{len(valid_rows)} rows loaded into Silver."
    )
    etl_report.append({

        "Table": table_name,

        "Bronze Rows": rows_before,

        "Silver Rows": len(valid_rows),

        "Quarantine Rows": len(invalid_rows),

        "Duplicates Removed": duplicates_removed,

        "Status": "PASS" if len(invalid_rows) == 0 else "WARNING"

    })



# ==========================================================
# Main
# ==========================================================

def main():

    for table_name, config in TABLE_CONFIG.items():

        process_table(table_name, config)

    report_df = pd.DataFrame(etl_report)

    report_path = BASE_DIR / "reports" / "etl_execution_report.csv"

    report_df.to_csv(
        report_path,
        index=False
    )

    logger.info(f"ETL report saved to: {report_path}")

if __name__ == "__main__":
    main()