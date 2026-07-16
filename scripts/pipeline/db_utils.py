from pathlib import Path

from dotenv import load_dotenv
from sqlalchemy import create_engine, text
import os

# ---------------------------------------------------
# Load Environment Variables
# ---------------------------------------------------

BASE_DIR = Path(__file__).resolve().parents[2]

load_dotenv(BASE_DIR / ".env")

DATABASE_URL = os.getenv("DATABASE_URL")

if not DATABASE_URL:
    raise ValueError("DATABASE_URL not found in .env")

# ---------------------------------------------------
# SQLAlchemy Engine
# ---------------------------------------------------

engine = create_engine(
    DATABASE_URL,
    fast_executemany=True
)

# ---------------------------------------------------
# Helper Functions
# ---------------------------------------------------

def get_engine():
    """Return SQLAlchemy engine."""
    return engine


def execute_sql(sql: str):
    """Execute raw SQL."""
    with engine.begin() as conn:
        conn.execute(text(sql))


def execute_sql_file(file_path):
    """Execute a SQL script file."""

    with open(file_path, "r", encoding="utf-8") as f:
        sql = f.read()

    batches = [
        batch.strip()
        for batch in sql.split("GO")
        if batch.strip()
    ]

    with engine.begin() as conn:
        for batch in batches:
            conn.execute(text(batch))