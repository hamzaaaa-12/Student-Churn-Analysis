# import os
#
# from dotenv import load_dotenv
# from sqlalchemy import create_engine
#
# # Load variables from .env
# load_dotenv()
#
# DATABASE_URL = os.getenv("DATABASE_URL")
#
# print("Connection String:")
# print(DATABASE_URL)
#
# engine = create_engine(DATABASE_URL)
#
# with engine.connect() as conn:
#     print("Connected successfully to SQL Server!")
# from pathlib import Path
# import os
#
# from dotenv import load_dotenv
#
# print("Current Working Directory:")
# print(Path.cwd())
#
# print("\nLooking for .env here:")
# print(Path.cwd() / ".env")
#
# loaded = load_dotenv()
#
# print("\nDid load_dotenv find a file?")
# print(loaded)
#
# print("\nDATABASE_URL:")
# print(os.getenv("DATABASE_URL"))
from pathlib import Path
import os
from dotenv import load_dotenv

# # Project root
# BASE_DIR = Path(__file__).resolve().parent.parent
#
# # Path to .env
# ENV_PATH = BASE_DIR / ".env"
#
# # Load .env
# load_dotenv(dotenv_path=ENV_PATH)
#
# DATABASE_URL = os.getenv("DATABASE_URL")
#
# print(DATABASE_URL)
# from pathlib import Path
# import os
#
# import pandas as pd
# from dotenv import load_dotenv
# from sqlalchemy import create_engine
#
# # ----------------------------
# # Load .env
# # ----------------------------
# BASE_DIR = Path(__file__).resolve().parent.parent
# load_dotenv(BASE_DIR / ".env")
#
# DATABASE_URL = os.getenv("DATABASE_URL")
#
# # ----------------------------
# # Create SQL Server connection
# # ----------------------------
# engine = create_engine(DATABASE_URL)
#
# # ----------------------------
# # Read CSV
# # ----------------------------
# csv_path = BASE_DIR / "data" / "raw" / "studentInfo.csv"
#
# print(f"Reading: {csv_path}")
#
# df = pd.read_csv(csv_path)
#
# print(df.head())
# print(f"\nRows: {len(df)}")
#
# # ----------------------------
# # Load into SQL Server
# # ----------------------------
# df.to_sql(
#     name="studentInfo",
#     con=engine,
#     schema="engagement_raw",
#     if_exists="append",
#     index=False
# )
#
# print("\nstudentInfo loaded successfully!")

from pathlib import Path
import os

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

# ======================================================
# Configuration
# ======================================================

BASE_DIR = Path(__file__).resolve().parent.parent

load_dotenv(BASE_DIR / ".env")

DATABASE_URL = os.getenv("DATABASE_URL")

engine = create_engine(DATABASE_URL)

RAW_DATA_FOLDER = BASE_DIR / "data" / "raw"

# ======================================================
# CSV -> SQL Table Mapping
# ======================================================

TABLES = {
    "studentInfo.csv": "studentInfo",
    "studentRegistration.csv": "studentRegistration",
    "studentVle.csv": "studentVle",
    "studentAssessment.csv": "studentAssessment",
    "assessments.csv": "assessments",
    "vle.csv": "vle",
    "courses.csv": "courses",
}

# ======================================================
# Load each table
# ======================================================

for csv_file, table_name in TABLES.items():

    print("=" * 60)
    print(f"Loading {csv_file}")

    csv_path = RAW_DATA_FOLDER / csv_file

    df = pd.read_csv(csv_path)

    print(f"Rows: {len(df):,}")

    with engine.begin() as conn:
        conn.execute(
            text(f"TRUNCATE TABLE engagement_raw.{table_name}")
        )

    df.to_sql(
        name=table_name,
        schema="engagement_raw",
        con=engine,
        if_exists="append",
        index=False,
        chunksize=1000,
    )

    print(f"{table_name} loaded successfully.")

print("\nAll Bronze tables loaded successfully.")