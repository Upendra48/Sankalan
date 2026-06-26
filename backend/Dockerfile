FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --upgrade pip && pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

ENV DJANGO_SETTINGS_MODULE=trash_tracker_backend.production_settings

CMD sh -c "\
python manage.py collectstatic --noinput && \
python manage.py migrate && \
python manage.py createsuperuser --noinput || true && \
gunicorn trash_tracker_backend.wsgi:application --bind 0.0.0.0:8000"