# Use an official lightweight Python image as base
FROM python:3.9-slim

# Set a working directory inside the container
WORKDIR /app

# Copy only the necessary files first to leverage Docker caching
COPY ./app/requirements.txt .

# Install dependencies in a virtual environment for security
RUN python -m venv venv && \
    ./venv/bin/pip install --no-cache-dir --upgrade pip && \
    ./venv/bin/pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application files
COPY ./app/app.py .

# Set environment variables for security best practices
ENV PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app \
    FLASK_APP=app.py \
    APP_VERSION="1.0.0" \
    PORT=5000

# Expose the required port
EXPOSE 5000

# Use a non-root user for security
RUN groupadd -r appuser && useradd --no-log-init -r -g appuser appuser
USER appuser

# Command to run the application using Gunicorn for production
CMD ["./venv/bin/gunicorn", "-b", "0.0.0.0:5000", "app:app"]
