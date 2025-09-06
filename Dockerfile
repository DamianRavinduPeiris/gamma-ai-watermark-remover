# Use an official lightweight Python image
FROM python:3.11-slim

# Avoid Python writing .pyc files and enable unbuffered stdout/stderr
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Install system packages needed for building some wheels and common binary deps
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       gcc \
       build-essential \
       libffi-dev \
       libxml2-dev \
       libxslt1-dev \
       libfreetype6 \
       libjpeg62-turbo \
       zlib1g \
       libgl1 \
       libglib2.0-0 \
       libsm6 \
       libxrender1 \
       libxext6 \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt ./
RUN pip install --upgrade pip setuptools wheel \
    && pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . /app

# Create folders used by the app and set permissions; create a non-root user
RUN mkdir -p uploads outputs templates \
    && addgroup --system appgroup \
    && adduser --system --ingroup appgroup appuser \
    && chown -R appuser:appgroup /app

# Run as non-root
USER appuser

EXPOSE 8000

# Use Render's $PORT when provided. Default to 8000 otherwise.
# ENTRYPOINT + CMD form lets Render set PORT via env var.
ENTRYPOINT ["/bin/sh", "-c"]
CMD ["uvicorn app:app --host 0.0.0.0 --port ${PORT:-8000}"]