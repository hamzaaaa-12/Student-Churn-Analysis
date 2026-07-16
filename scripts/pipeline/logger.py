import logging
from pathlib import Path

# ---------------------------------------------------
# Create logs folder if it doesn't exist
# ---------------------------------------------------

BASE_DIR = Path(__file__).resolve().parents[2]

LOG_DIR = BASE_DIR / "logs"

LOG_DIR.mkdir(exist_ok=True)

LOG_FILE = LOG_DIR / "pipeline.log"

# ---------------------------------------------------
# Configure Logger
# ---------------------------------------------------

logger = logging.getLogger("StudentChurnPipeline")

logger.setLevel(logging.INFO)

# Avoid duplicate handlers if imported multiple times
if not logger.handlers:

    formatter = logging.Formatter(
        "%(asctime)s | %(levelname)s | %(message)s"
    )

    # Log to file
    file_handler = logging.FileHandler(LOG_FILE, encoding="utf-8")
    file_handler.setFormatter(formatter)

    # Log to console
    console_handler = logging.StreamHandler()
    console_handler.setFormatter(formatter)

    logger.addHandler(file_handler)
    logger.addHandler(console_handler)