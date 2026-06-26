# Use official lightweight Python image
FROM python:3.12-slim

# Environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy project
COPY . .

# Expose port
EXPOSE 8000

# Production settings
ENV DJANGO_SETTINGS_MODULE=trash_tracker_backend.production_settings

# Start application
CMD sh -c "\
python manage.py collectstatic --noinput && \
python manage.py migrate && \
python manage.py shell -c '\
from django.contrib.auth import get_user_model; \
User = get_user_model(); \
username = \"admin\"; \
email = \"admin@example.com\"; \
password = \"admin123\"; \
user, created = User.objects.get_or_create(username=username, defaults={\"email\": email, \"is_staff\": True, \"is_superuser\": True}); \
if created: \
    user.set_password(password); \
    user.save(); \
print(\"Superuser ready\")' && \
gunicorn trash_tracker_backend.wsgi:application --bind 0.0.0.0:8000"