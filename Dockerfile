# Usage:

# docker build --no-cache -t flask-app:1.0.0 .
# docker run -d -p 5000:5000 --name flask-container flask-app:1.0.0

# Alternately github workflow ./github/workflows/deploy.yml will perform the build and ECR upload

# Use a slim Python image as the base for building dependencies
FROM python:3.11-slim AS builder

# Set a working directory inside the container
WORKDIR /app

# Install system dependencies for building wheels (if needed)
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc libffi-dev && \
    rm -rf /var/lib/apt/lists/*

# Copy only the necessary requirements file first
COPY ./app/requirements.txt .

# flask==2.3.2
# gunicorn==22.0.0
# werkzeug==3.0.6

# Create a dedicated virtual environment
RUN python -m venv /opt/venv && \
    /opt/venv/bin/pip install --no-cache-dir --upgrade pip && \
    /opt/venv/bin/pip install --no-cache-dir --prefer-binary -r requirements.txt

# Copy the rest of the application files
COPY ./app /app

# Final minimal image
FROM python:3.11-slim

# Set a working directory
WORKDIR /app

# Copy only the necessary files from the builder image
COPY --from=builder /app /app
COPY --from=builder /opt/venv /opt/venv

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app \
    FLASK_APP=app.py \
    APP_VERSION="1.0.0" \
    PORT=5000 \
    PATH="/opt/venv/bin:$PATH"

# Expose the required port
EXPOSE 5000

# Create a non-root user and set ownership
RUN groupadd -r appuser && useradd --no-log-init -r -g appuser appuser && \
    chown -R appuser:appuser /app /opt/venv

USER appuser

# Command to run the application using Gunicorn for production
CMD ["gunicorn", "-b", "0.0.0.0:5000", "--workers=4", "--threads=2", "app:app"]
