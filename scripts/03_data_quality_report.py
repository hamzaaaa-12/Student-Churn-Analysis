# from pathlib import Path
# import os
#
# import pandas as pd
# from dotenv import load_dotenv
# from sqlalchemy import create_engine
#
# # ======================================================
# # Configuration
# # ======================================================
#
# BASE_DIR = Path(__file__).resolve().parent.parent
#
# load_dotenv(BASE_DIR / ".env")
#
# DATABASE_URL = os.getenv("DATABASE_URL")
#
# engine = create_engine(DATABASE_URL)
#
# REPORT_FOLDER = BASE_DIR / "reports"
# REPORT_FOLDER.mkdir(exist_ok=True)
#
# # ======================================================
# # Tables to check
# # ======================================================
#
# TABLES = [
#     "studentInfo",
#     "studentRegistration",
#     "studentVle",
#     "studentAssessment",
#     "assessments",
#     "vle",
#     "courses"
# ]
#
# summary = []
#
# # ======================================================
# # Data Quality Checks
# # ======================================================
#
# for table in TABLES:
#
#     print(f"Checking {table}...")
#
#     query = f"""
#     SELECT *
#     FROM engagement_raw.{table}
#     """
#
#     df = pd.read_sql(query, engine)
#
#     row_count = len(df)
#
#     duplicate_rows = df.duplicated().sum()
#
#     total_nulls = df.isnull().sum().sum()
#
#     summary.append({
#         "Table": table,
#         "Rows": row_count,
#         "Duplicate Rows": duplicate_rows,
#         "Total Null Values": total_nulls,
#         "Status": "PASS"
#     })
#
# # ======================================================
# # Save Report
# # ======================================================
#
# report = pd.DataFrame(summary)
#
# output_file = REPORT_FOLDER / "data_quality_report.csv"
#
# report.to_csv(output_file, index=False)
#
# print("\nReport created successfully!\n")
#
# print(report)
#
# print(f"\nSaved to:\n{output_file}")
from pathlib import Path
import os

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine

# ==========================================================
# Configuration
# ==========================================================

BASE_DIR = Path(__file__).resolve().parent.parent

load_dotenv(BASE_DIR / ".env")

DATABASE_URL = os.getenv("DATABASE_URL")

engine = create_engine(DATABASE_URL)

REPORT_FOLDER = BASE_DIR / "reports"
REPORT_FOLDER.mkdir(exist_ok=True)

TABLES = [
    "studentInfo",
    "studentRegistration",
    "studentVle",
    "studentAssessment",
    "assessments",
    "vle",
    "courses"
]

table_summary = []
column_profile = []
validation_report = []

print("=" * 70)
print("Generating Data Quality Report")
print("=" * 70)

# ==========================================================
# Analyze Every Table
# ==========================================================

for table in TABLES:

    print(f"\nAnalyzing {table}...")

    df = pd.read_sql(
        f"SELECT * FROM engagement_raw.{table}",
        engine
    )

    # ------------------------------------------------------
    # Table Summary
    # ------------------------------------------------------

    table_summary.append({

        "Table": table,

        "Rows": len(df),

        "Columns": len(df.columns),

        "Duplicate Rows": int(df.duplicated().sum()),

        "Total Null Values": int(df.isnull().sum().sum()),

        "Status": "PASS"

    })

    # ------------------------------------------------------
    # Column Profile
    # ------------------------------------------------------

    for column in df.columns:

        null_count = int(df[column].isna().sum())

        null_percent = round(
            (null_count / len(df)) * 100,
            2
        )

        distinct_values = int(df[column].nunique(dropna=True))

        dtype = str(df[column].dtype)

        try:
            minimum = df[column].min()
            maximum = df[column].max()
        except Exception:
            minimum = None
            maximum = None

        column_profile.append({

            "Table": table,

            "Column": column,

            "Data Type": dtype,

            "Rows": len(df),

            "Null Count": null_count,

            "Null %": null_percent,

            "Distinct Values": distinct_values,

            "Min": minimum,

            "Max": maximum

        })

# ==========================================================
# Business Validation Rules
# ==========================================================

# studentAssessment
assessment = pd.read_sql(
    "SELECT score FROM engagement_raw.studentAssessment",
    engine
)

validation_report.append({

    "Rule": "Score between 0 and 100",

    "Table": "studentAssessment",

    "Result":
        "PASS"
        if assessment["score"].dropna().between(0, 100).all()
        else "FAIL"

})

# assessments

assessments = pd.read_sql(
    "SELECT weight FROM engagement_raw.assessments",
    engine
)

validation_report.append({

    "Rule": "Weight between 0 and 100",

    "Table": "assessments",

    "Result":
        "PASS"
        if assessments["weight"].dropna().between(0, 100).all()
        else "FAIL"

})

# studentInfo

student_info = pd.read_sql(
    "SELECT studied_credits FROM engagement_raw.studentInfo",
    engine
)

validation_report.append({

    "Rule": "Studied credits > 0",

    "Table": "studentInfo",

    "Result":
        "PASS"
        if (student_info["studied_credits"] > 0).all()
        else "FAIL"

})

# studentRegistration

registration = pd.read_sql(
    """
    SELECT
        date_registration,
        date_unregistration
    FROM engagement_raw.studentRegistration
    """,
    engine
)

valid_dates = registration[
    registration["date_unregistration"].isna()
    |
    (
        registration["date_registration"]
        <=
        registration["date_unregistration"]
    )
]

validation_report.append({

    "Rule":
        "Registration date <= Unregistration date",

    "Table":
        "studentRegistration",

    "Result":
        "PASS"
        if len(valid_dates) == len(registration)
        else "FAIL"

})

# ==========================================================
# Save Reports
# ==========================================================

table_summary_df = pd.DataFrame(table_summary)

column_profile_df = pd.DataFrame(column_profile)

validation_df = pd.DataFrame(validation_report)

table_summary_df.to_csv(

    REPORT_FOLDER / "table_quality_summary.csv",

    index=False

)

column_profile_df.to_csv(

    REPORT_FOLDER / "column_quality_profile.csv",

    index=False

)

validation_df.to_csv(

    REPORT_FOLDER / "validation_report.csv",

    index=False

)

print("\n")
print("=" * 70)
print("Data Quality Reports Generated Successfully")
print("=" * 70)

print("\nReports saved in:")

print(REPORT_FOLDER)