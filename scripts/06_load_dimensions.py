from pathlib import Path
import os

import pandas as pd
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

# ==========================================================
# Database Connection
# ==========================================================

BASE_DIR = Path(__file__).resolve().parent.parent

load_dotenv(BASE_DIR / ".env")

DATABASE_URL = os.getenv("DATABASE_URL")

engine = create_engine(DATABASE_URL)

# ==========================================================
# Dimension Configuration
# ==========================================================

DIMENSIONS = {

    "dim_student": {

        "source": "studentInfo",

        "column_mapping": {

            "id_student": "id_student",
            "gender": "gender",
            "region": "region",
            "highest_education": "highest_education",
            "age_band": "age_band",
            "disability": "disability",
            "imd_band": "imd_band",
            "final_result": "final_result"

        },

        "duplicates": [
            "id_student"
        ]

    },

    "dim_course": {

        "source": "courses",

        "column_mapping": {

            "code_module": "code_module",
            "code_presentation": "code_presentation",
            "module_presentation_length": "module_presentation_length"

        },

        "duplicates": [
            "code_module",
            "code_presentation"
        ]

    },

    "dim_assessment": {

        "source": "assessments",

        "column_mapping": {

            "id_assessment": "id_assessment",
            "assessment_type": "assessment_type",
            "weight": "weight",
            "date": "assessment_date"

        },

        "duplicates": [
            "id_assessment"
        ]

    },

    "dim_activity_type": {

        "source": "vle",

        "column_mapping": {

            "id_site": "id_site",
            "activity_type": "activity_type"

        },

        "duplicates": [
            "id_site"
        ]

    }

}
# ==========================================================
# Generic Dimension Loader
# ==========================================================

def load_dimension(dimension_name, config):

    print(f"\nLoading {dimension_name}...")

    source_table = config["source"]

    column_mapping = config["column_mapping"]

    duplicate_columns = config["duplicates"]

    # ------------------------------------
    # Read Source Table
    # ------------------------------------

    query = f"""
    SELECT *
    FROM engagement_clean.{source_table}
    """

    df = pd.read_sql(query, engine)

    # ------------------------------------
    # Keep Required Columns
    # ------------------------------------

    df = df[list(column_mapping.keys())]

    # ------------------------------------
    # Rename Columns
    # ------------------------------------

    df = df.rename(columns=column_mapping)

    # ------------------------------------
    # Remove Duplicates
    # ------------------------------------

    df = df.drop_duplicates(
        subset=duplicate_columns
    )

    # ------------------------------------
    # Truncate Dimension
    # ------------------------------------

    with engine.begin() as conn:

        conn.execute(

            text(

                f"TRUNCATE TABLE engagement_dw.{dimension_name}"

            )

        )

    # ------------------------------------
    # Load Dimension
    # ------------------------------------

    df.to_sql(

        name=dimension_name,

        con=engine,

        schema="engagement_dw",

        if_exists="append",

        index=False

    )

    print(f"Loaded {len(df):,} rows into {dimension_name}.")

## ==========================================================
# Load Date Dimension
# ==========================================================

def load_dim_date():

    print("\nLoading dim_date...")

    query = """
    SELECT date AS course_day
    FROM engagement_clean.studentVle

    UNION

    SELECT date AS course_day
    FROM engagement_clean.assessments

    UNION

    SELECT date_registration AS course_day
    FROM engagement_clean.studentRegistration

    UNION

    SELECT date_unregistration AS course_day
    FROM engagement_clean.studentRegistration
    WHERE date_unregistration IS NOT NULL
    """

    df = pd.read_sql(query, engine)

    # ----------------------------------------
    # Clean
    # ----------------------------------------

    df = (
        df
        .dropna()
        .drop_duplicates()
        .sort_values("course_day")
        .reset_index(drop=True)
    )

    # ----------------------------------------
    # Surrogate Key
    # ----------------------------------------

    df["date_key"] = range(1, len(df) + 1)

    # ----------------------------------------
    # Shift days for positive week numbers
    # ----------------------------------------

    min_day = df["course_day"].min()

    shifted_day = df["course_day"] - min_day

    df["course_week"] = (shifted_day // 7) + 1

    # ----------------------------------------
    # Course Phase
    # ----------------------------------------

    df["course_phase"] = "During Course"

    df.loc[df["course_day"] < 0, "course_phase"] = "Before Course"

    df.loc[df["course_day"] > 269, "course_phase"] = "After Course"

    # ----------------------------------------
    # Final Columns
    # ----------------------------------------

    df = df[
        [
            "date_key",
            "course_day",
            "course_week",
            "course_phase"
        ]
    ]

    # ----------------------------------------
    # Reload Dimension
    # ----------------------------------------

    with engine.begin() as conn:

        conn.execute(
            text(
                "TRUNCATE TABLE engagement_dw.dim_date"
            )
        )

    df.to_sql(
        "dim_date",
        con=engine,
        schema="engagement_dw",
        if_exists="append",
        index=False
    )

    print(f"Loaded {len(df):,} rows into dim_date.")
# ==========================================================
# Main
# ==========================================================

def main():

    for dimension_name, config in DIMENSIONS.items():

        load_dimension(
            dimension_name,
            config
        )

    load_dim_date()


if __name__ == "__main__":

    main()