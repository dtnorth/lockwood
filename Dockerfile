# Usage:

# docker build --no-cache -t flask-app:1.0.0 .
# docker run -d -p 5000:5000 --name flask-container flask-app:1.0.0

# Alternately github workflow ./github/workflows/deploy.yml will perform the build and ECR upload

# Use a slim Python image as the base
FROM python:3.9-slim AS builder

# Set a working directory inside the container
WORKDIR /app

# Copy only the necessary requirements file first
COPY ./app/requirements.txt .

# Install dependencies in a virtual environment and reduce layer count
RUN python -m venv /app/venv && \
    /app/venv/bin/pip install --no-cache-dir --upgrade pip && \
    /app/venv/bin/pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application files (ensure all files are copied in a single layer)
COPY ./app /app

# Final minimal image
FROM python:3.9-slim

# Set a working directory in the final image
WORKDIR /app

# Copy only the necessary files from the builder image
COPY --from=builder /app /app

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app \
    FLASK_APP=app.py \
    APP_VERSION="1.0.0" \
    PORT=5000

# Expose the required port
EXPOSE 5000

# Create a non-root user and set ownership
RUN groupadd -r appuser && useradd --no-log-init -r -g appuser appuser && \
    chown -R appuser:appuser /app

USER appuser

# Command to run the application using Gunicorn for production
CMD ["./venv/bin/gunicorn", "-b", "0.0.0.0:5000", "app:app"]
