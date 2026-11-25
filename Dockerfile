# LexGuard — single container: FastAPI backend that also serves the
# statically exported Next.js frontend. Works on Render, Cloud Run, etc.

# ---- Frontend build ----
FROM node:20-alpine AS frontend
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm ci
COPY frontend/ ./
# Empty API URL = call the API on the same origin the site is served from.
ENV NEXT_PUBLIC_API_URL=""
RUN npm run build

# ---- Python dependencies ----
FROM python:3.11-slim AS builder
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ---- Runtime ----
FROM python:3.11-slim
WORKDIR /app

COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

COPY backend/ ./backend/
COPY --from=frontend /app/frontend/out ./frontend/out

# Create non-root user for security
RUN useradd --create-home appuser
USER appuser

# The platform provides PORT; 8080 is the local default.
ENV PORT=8080
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD python -c "import os, urllib.request; urllib.request.urlopen(f'http://localhost:{os.environ.get(\"PORT\", \"8080\")}/api/health')" || exit 1

CMD ["sh", "-c", "uvicorn backend.main:app --host 0.0.0.0 --port ${PORT:-8080}"]
