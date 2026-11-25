"""LexGuard Configuration"""
import os
from pathlib import Path
from dotenv import load_dotenv

# Load .env from the backend directory
_env_path = Path(__file__).parent / ".env"
load_dotenv(_env_path)

# Application version (kept in sync with backend/main.py and pyproject.toml)
APP_VERSION = "1.0.2"

# Google Cloud Settings
GCP_PROJECT_ID = os.getenv("GOOGLE_CLOUD_PROJECT", "")
GCP_LOCATION = os.getenv("GOOGLE_CLOUD_LOCATION", "us-central1")
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")
GCS_BUCKET_NAME = os.getenv("GCS_BUCKET_NAME", "lexguard-uploads")

# Model Settings
# Models are tried in order: if one is retired or overloaded, the next is used.
# Override with GEMINI_MODELS as a comma-separated list.
GEMINI_MODELS = [
    m.strip()
    for m in os.getenv("GEMINI_MODELS", "gemini-2.5-flash,gemini-3.5-flash,gemini-3.8-flash").split(",")
    if m.strip()
]
GEMINI_PRO_MODEL = GEMINI_MODELS[0]
GEMINI_FLASH_MODEL = GEMINI_MODELS[0]

# Risk Thresholds
CRITICAL_RISK_THRESHOLD = 8
WARNING_RISK_THRESHOLD = 5

# Document AI Processor (set after creating processor in GCP)
DOCUMENT_AI_PROCESSOR_ID = os.getenv("DOCUMENT_AI_PROCESSOR_ID", "")
