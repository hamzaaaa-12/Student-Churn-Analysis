from pathlib import Path
import os

from dotenv import load_dotenv
from sqlalchemy import create_engine, text

# =====================================================
# Configuration
# =====================================================

BASE_DIR = Path(__file__).resolve().parent.parent

load_dotenv(BASE_DIR / ".env")

DATABASE_URL = os.getenv("DATABASE_URL")

engine = create_engine(DATABASE_URL)

TABLES = [
    "studentInfo",
    "studentRegistration",
    "studentVle",
    "studentAssessment",
    "assessments",
    "vle",
    "courses"
]

print("=" * 60)
print("Creating Quarantine Tables")
print("=" * 60)

with engine.begin() as conn:

    for table in TABLES:

        print(f"Creating {table}...")

        conn.execute(text(f"""
        IF OBJECT_ID('engagement_quarantine.{table}', 'U') IS NOT NULL
            DROP TABLE engagement_quarantine.{table};

        SELECT TOP 0 *
        INTO engagement_quarantine.{table}
        FROM engagement_clean.{table};
        """))

        conn.execute(text(f"""
        ALTER TABLE engagement_quarantine.{table}

        ADD

        quarantine_reason NVARCHAR(255),

        quarantine_timestamp DATETIME2 DEFAULT GETDATE(),

        source_table NVARCHAR(100);
        """))

print("\nAll quarantine tables created successfully.")