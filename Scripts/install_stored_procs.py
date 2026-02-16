"""
Install all .sql stored procedure files located in the same directory
as this script into the database referenced by DATABASE_URL.

Usage:
    python Scripts/StoredProc/install_stored_procs.py
"""

import os
from pathlib import Path
from dotenv import load_dotenv
from sqlalchemy import create_engine, text


def get_database_url() -> str:
    load_dotenv()
    db_url = os.getenv("DATABASE_URL")
    if not db_url:
        raise RuntimeError("DATABASE_URL not set; aborting.")
    return db_url


def get_sql_files() -> list[Path]:
    base_dir = Path(__file__).resolve().parent
    sql_files = sorted(base_dir.glob("*.sql"))

    if not sql_files:
        raise RuntimeError(f"No .sql files found in {base_dir}")

    return sql_files


def install_stored_procs(engine):
    sql_files = get_sql_files()

    print(f"Found {len(sql_files)} SQL file(s).")

    with engine.begin() as conn:
        current_db = conn.execute(text("SELECT current_database();")).scalar()
        print(f"Connected to database: {current_db}")

        for sql_file in sql_files:
            print(f"Executing {sql_file.name}...")
            try:
                sql = sql_file.read_text(encoding="utf-8")
                conn.execute(text(sql))
                print(f"✔ {sql_file.name} executed successfully.")
            except Exception as e:
                print(f"✖ Error executing {sql_file.name}: {e}")
                raise  # Fail fast


def main():
    db_url = get_database_url()

    # Avoid printing credentials
    print("Connecting to database...")

    engine = create_engine(db_url)

    install_stored_procs(engine)

    print("All stored procedures installed successfully.")


if __name__ == "__main__":
    main()
