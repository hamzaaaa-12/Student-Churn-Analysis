from sqlalchemy import create_engine, text

# Your setup: default instance, Windows Authentication, database = Student_Churn
DB_SERVER = "localhost"
DB_NAME = "Student_Churn"
DRIVER = "ODBC+Driver+17+for+SQL+Server"  # change to 18 if that's what you saw in Step 1

conn_str = f"mssql+pyodbc://@{DB_SERVER}/{DB_NAME}?driver={DRIVER}&trusted_connection=yes"

engine = create_engine(conn_str)

with engine.connect() as conn:
    result = conn.execute(text(
        "SELECT name FROM sys.schemas "
        "WHERE name IN ('engagement_raw', 'engagement_clean', 'engagement_dw')"
    ))
    schemas = [row[0] for row in result]
    print("Connected successfully. Found schemas:", schemas)
