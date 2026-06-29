# ♻️ Sankalan – Smart Waste Management System

A production-ready full-stack waste management platform built with **Django REST Framework**, **Flutter**, and **PostgreSQL**, designed to help municipalities efficiently monitor waste bins, optimize collection routes, and enable citizens to report waste-related issues in real time.

Sankalan demonstrates modern backend engineering practices including **JWT Authentication**, **RESTful API Design**, **PostgreSQL**, **API Documentation**, **Containerized Deployment**, **Production-ready Security**, and **Cloud Deployment**.

---

## 🌐 Live Demo

### Frontend

🔗 https://sankalan-zeta.vercel.app/

### Backend API

🔗 https://sankalan.onrender.com/

### API Documentation

🔗 https://sankalan.onrender.com/api/docs/

---

# Core Backend Technologies

* Django 5
* Django REST Framework
* PostgreSQL (Neon Database)
* JWT Authentication (SimpleJWT)
* RESTful API Architecture
* OpenAPI / Swagger Documentation
* Docker
* Gunicorn
* WhiteNoise
* Render Deployment
* Vercel Deployment
* CORS Configuration
* Environment-based Configuration
* HATEOAS API Responses
* Pagination
* Filtering
* Search
* Ordering
* Production Logging

---

# Features

## Authentication

* User Registration
* Username & Password Login
* JWT Authentication
* Refresh Tokens
* Protected API Endpoints

---

## Waste Bin Management

* Create Waste Bins
* Update Bin Status
* Delete Waste Bins
* Live Bin Monitoring
* Bin Fill Levels
* Bin Availability Status

---

## Waste Reporting

Citizens can report:

* Illegal Waste Dumping
* Overflowing Bins
* Waste Locations

---

## Bin Requests

Users can request installation of new waste bins with location and reason.

---

## Analytics Dashboard

* Total Waste Bins
* Empty Bins
* Half Filled Bins
* Full Bins
* Collection Efficiency
* Daily Activity
* Waste Reports Statistics

---

## Smart Route Optimization

Automatically generates optimized waste collection routes using geographic coordinates.

---

# Architecture

```
Flutter Web
      │
      ▼
REST API (Django REST Framework)
      │
JWT Authentication
      │
Business Logic
      │
PostgreSQL (Neon)
```

---



---

# Project Structure

```
backend/
│
├── auth/
├── wastebins/
├── admin_side/
├── trash_tracker_backend/
│
frontend/
│
├── lib/
├── screens/
├── widgets/
├── services/
├── models/
└── providers/
```

---

# Local Setup

## Clone Repository

```bash
git clone https://github.com/Upendra48/Sankalan.git

cd Sankalan
```

---

## Backend

```bash
cd backend

python -m venv venv

source venv/bin/activate
```

Windows

```bash
venv\Scripts\activate
```

Install dependencies

```bash
pip install -r requirements.txt
```

Create a `.env`

```env
SECRET_KEY=your_secret_key

DEBUG=True

DATABASE_URL=postgresql://username:password@host/database

ALLOWED_HOSTS=localhost,127.0.0.1
```

Run migrations

```bash
python manage.py migrate
```

Create superuser

```bash
python manage.py createsuperuser
```

Run server

```bash
python manage.py runserver
```

---

## Frontend

```bash
cd frontend

flutter pub get

flutter run
```

---

# Deployment

## Backend

* Render
* Docker
* Gunicorn
* WhiteNoise

## Database

* Neon PostgreSQL

## Frontend

* Flutter Web
* Vercel

---

# API

Authentication

```
POST /api/auth/register/

POST /api/auth/login/

POST /api/auth/token/refresh/

GET /api/auth/me/
```

Waste Bins

```
GET    /api/waste-bins/

POST   /api/waste-bins/

PATCH  /api/waste-bins/{id}/

DELETE /api/waste-bins/{id}/
```

Reports

```
GET /api/waste-reports/

POST /api/waste-reports/
```

Requests

```
GET /api/bin-requests/

POST /api/bin-requests/
```

Analytics

```
GET /api/waste-bin-analytics/

GET /api/collection-routes/
```

---

# Authentication

All protected endpoints require

```
Authorization: Bearer <JWT_TOKEN>
```

---

# Why This Project?

This project was built to demonstrate real-world backend engineering practices rather than simple CRUD operations. It includes secure authentication, REST API design, PostgreSQL integration, cloud deployment, API documentation, optimized routing, production-ready configuration, and a responsive Flutter frontend.

---

# Author

**Upendra Raj Joshi**

Backend Developer | Django | Flutter | REST APIs | PostgreSQL

GitHub: https://github.com/Upendra48

LinkedIn: https://www.linkedin.com/in/upendra48/
