# Use an official lightweight Python image
FROM python:3.9-slim AS builder

# Set environment variables for security
ENV PYTHONUNBUFFERED=1 \
    PYTHONFAULTHANDLER=1 \
    PYTHONHASHSEED=random \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_DEFAULT_TIMEOUT=100

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc libffi-dev libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install dependencies
COPY ./app/requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && pip install --no-cache-dir -r requirements.txt

# Create a non-root user
RUN useradd --no-create-home flaskuser
USER flaskuser

# Copy application code
COPY --chown=flaskuser:flaskuser ./app/app.py .

# Expose the application port
EXPOSE 5000

# Use Gunicorn for production
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "app:app"]
