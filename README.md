# Sankalan - Smart Waste Management System

A comprehensive waste management solution built with Django REST API backend and Flutter frontend. Sankalan helps track, manage, and optimize waste collection with real-time bin monitoring and analytics.

## 🌟 Features

### Backend

- **RESTful API** with Django REST Framework
- **Real-time bin tracking** and monitoring
- **Analytics dashboard** for waste statistics
- **Admin notifications** for full bins
- **Route optimization** - Calculates best collection routes for filled bins
- **Waste incident reporting** system
- **CORS enabled** for cross-origin requests
- **Admin panel** for management operations

### Frontend

- **Interactive map view** using flutter_map
- **Analytics dashboard** with charts (fl_chart)
- **Material Design 3** UI/UX
- **Responsive design** (Desktop, Tablet, Mobile)
- **Real-time updates** with HTTP requests
- **Beautiful animations** with Lottie
- **Request new bins** functionality
- **Report waste issues** functionality

---

## 📋 Project Structure

```
Sankalan/
├── backend/                              # Django REST API Backend
│   ├── trash_tracker_backend/            # Main Django project configuration
│   │   ├── settings.py                   # Django settings
│   │   ├── urls.py                       # URL routing
│   │   ├── asgi.py                       # ASGI config
│   │   └── wsgi.py                       # WSGI config
│   ├── wastebins/                        # Waste bin management app
│   │   ├── models.py                     # WasteBin & ReportWaste models
│   │   ├── serializers.py                # API serializers
│   │   ├── views.py                      # API views
│   │   ├── urls.py                       # App routes
│   │   └── migrations/                   # Database migrations
│   ├── admin_side/                       # Admin interface app
│   │   ├── models.py                     # Admin models
│   │   ├── views.py                      # Admin views
│   │   └── forms.py                      # Admin forms
│   ├── map/                              # Map functionality app
│   │   └── views.py                      # Map endpoints
│   ├── manage.py                         # Django management script
│   ├── requirements.txt                  # Python dependencies
│   ├── db.sqlite3                        # SQLite database
│   ├── docker-compose.yml                # Docker configuration
│   ├── Dockerfile                        # Docker image definition
│   ├── templates/                        # HTML templates
│   └── staticfiles/                      # Static files (CSS, JS, images)
│
├── frontend/                             # Flutter Mobile & Web App
│   ├── lib/                              # Dart source code
│   │   ├── main.dart                     # App entry point
│   │   ├── mapscreen.dart                # Map screen widget
│   │   ├── analytics/                    # Analytics module
│   │   ├── pages/                        # Page screens
│   │   ├── screens/                      # UI screens
│   │   ├── requestbin/                   # Request bin functionality
│   │   ├── fohor/                        # Report waste functionality
│   │   └── bin/                          # Helper utilities
│   ├── pubspec.yaml                      # Flutter dependencies
│   ├── analysis_options.yaml             # Dart analysis config
│   ├── android/                          # Android native configuration
│   │   ├── app/                          # Android app module
│   │   └── gradle/                       # Gradle build files
│   ├── ios/                              # iOS native configuration
│   │   └── Runner/                       # iOS app module
│   ├── linux/                            # Linux desktop configuration
│   ├── macos/                            # macOS desktop configuration
│   ├── windows/                          # Windows desktop configuration
│   ├── web/                              # Web configuration
│   ├── build/                            # Build output directory
│   ├── test/                             # Widget tests
│   └── assets/                           # App assets (images, animations)
│
├── README.md                             # This file
└── UPGRADE_SUMMARY.md                    # Dependency upgrade details (if available)
```

---

## 🚀 Quick Start

### Prerequisites

- **Python 3.10+** (Backend)
- **Flutter 3.38.7+** (Frontend) - Supports all platforms (Web, Mobile, Desktop)
- **Dart 3.10.7+** (Frontend)
- **Docker** (Optional - for containerized deployment)
- **Git**
- **Node.js** (Optional - for web build optimization)

### One-Step Setup (Recommended)

For a quick development environment setup:

```bash
# Clone repository
git clone https://github.com/Upendra48/Sankalan.git
cd Sankalan

# Backend setup
cd backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1  # Windows
# or source .venv/bin/activate  # Linux/Mac
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver

# In another terminal, frontend setup
cd frontend
flutter pub get
flutter run -d chrome  # or your preferred device

```

Server: `http://127.0.0.1:8000/`  
API: `http://127.0.0.1:8000/api/`  
Admin: `http://127.0.0.1:8000/admin/`

---

### Backend Setup

1. **Clone the repository**

```bash
git clone https://github.com/Upendra48/Sankalan.git
cd Sankalan/backend
```

2. **Create virtual environment**

```bash
python -m venv .venv

# Windows
.\.venv\Scripts\Activate.ps1

# Linux/Mac
source .venv/bin/activate
```

3. **Install dependencies**

```bash
pip install -r requirements.txt
```

4. **Run migrations**

```bash
python manage.py migrate
```

5. **Start server**

```bash
python manage.py runserver
```

Server runs at: `http://127.0.0.1:8000/`

### Backend Setup (Docker - Optional)

1. **Navigate to backend**

```bash
cd backend
```

2. **Build and run with Docker**

```bash
docker-compose up --build
```

3. **Run migrations in container**

```bash
docker-compose exec web python manage.py migrate
```

4. **Create admin user (optional)**

```bash
docker-compose exec web python manage.py createsuperuser
```

Access the application at `http://localhost:8000/`

### Frontend Setup

1. **Navigate to frontend**

```bash
cd ../frontend
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Run the app**

```bash
# List available devices
flutter devices

# Run on specific platform
flutter run -d chrome          # Web (Chrome)
flutter run -d edge            # Web (Edge)
flutter run -d android         # Android
flutter run -d ios             # iOS
flutter run -d windows         # Windows
flutter run -d linux           # Linux
flutter run -d macos           # macOS

# Release build
flutter build apk              # Android APK
flutter build aab              # Android App Bundle
flutter build ios              # iOS
flutter build web --release    # Web
flutter build windows          # Windows
flutter build linux            # Linux
```

### API Configuration

Update `backend/trash_tracker_backend/settings.py` with your frontend URLs:

```python
CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",
    "http://localhost:5000",
    "http://127.0.0.1:8000",
    # Add your deployment URLs
]
```

Update `frontend/lib/main.dart` with your backend API URL:

```dart
const String API_BASE_URL = 'http://127.0.0.1:8000/api/';
// For production, use your deployed backend URL
```

---

## 📡 API Endpoints

### Base URL

```
http://127.0.0.1:8000/api/
```

### Authentication

Currently no authentication required (for development). Production setup should include token-based auth.

### Endpoints

#### 1. **Waste Bins**

```
GET    /api/wastebins/              # List all waste bins
POST   /api/wastebins/              # Create new waste bin
GET    /api/wastebins/{id}/         # Get specific bin details
PUT    /api/wastebins/{id}/         # Update bin
DELETE /api/wastebins/{id}/         # Delete bin
PUT    /api/wastebins/{id}/change_fill_level/  # Update fill level
POST   /api/wastebins/{id}/report_full/        # Report bin as full
```

**Bin Fill Levels:** `Empty`, `Half-Filled`, `Full`

**Example Request:**

```bash
curl http://127.0.0.1:8000/api/wastebins/
```

#### 2. **Requests**

```
GET    /api/requests/               # List all requests
POST   /api/requests/               # Create new request
GET    /api/requests/{id}/          # Get request details
PUT    /api/requests/{id}/          # Update request
DELETE /api/requests/{id}/          # Delete request
```

#### 3. **Admin Notifications**

```
GET    /api/admin-notifications/    # List all notifications
POST   /api/admin-notifications/    # Create notification
GET    /api/admin-notifications/{id}/  # Get notification
PUT    /api/admin-notifications/{id}/  # Update notification
DELETE /api/admin-notifications/{id}/  # Delete notification
```

#### 4. **Report Waste**

```
GET    /api/report-waste/           # List all reports
POST   /api/report-waste/           # Submit waste report
GET    /api/report-waste/{id}/      # Get report details
PUT    /api/report-waste/{id}/      # Update report
DELETE /api/report-waste/{id}/      # Delete report
```

**Report Fields:**

- `description`: Issue description
- `latitude`: Location latitude
- `longitude`: Location longitude
- `image`: Optional photo (if supported)

#### 5. **Analytics**

```
GET    /api/waste-bin-analytics/    # Get bin statistics
```

**Response Example:**

```json
{
  "total_bins": 150,
  "empty_bins": 45,
  "half_filled_bins": 80,
  "full_bins": 25
}
```

#### 6. **Route Optimization** 🚀

```
GET    /api/route-optimization/     # Get optimized collection route for full bins
POST   /api/route-optimization/     # Calculate best route based on filled bins
```

**Query Parameters:**

- `include_full_only`: Boolean - Include only full bins (default: true)
- `latitude`: Float - Starting location latitude (optional)
- `longitude`: Float - Starting location longitude (optional)

**Response Example:**

```json
{
  "route_id": "opt_123456",
  "total_distance": 45.3,
  "estimated_time": "2 hours 15 minutes",
  "full_bins_count": 12,
  "stops": [
    {
      "order": 1,
      "bin_id": 45,
      "name": "Downtown Market",
      "latitude": 28.5355,
      "longitude": 77.391,
      "fill_level": "Full"
    },
    {
      "order": 2,
      "bin_id": 67,
      "name": "Park Square",
      "latitude": 28.5367,
      "longitude": 77.3945,
      "fill_level": "Full"
    }
  ]
}
```

#### 7. **Landing Page**

```
GET    /                            # API landing page (HTML)
GET    /api/                        # API root (JSON)
GET    /admin/                      # Django admin panel
```

---

## 🛠️ Technologies Used

### Backend Stack

| Technology            | Version | Purpose                       |
| --------------------- | ------- | ----------------------------- |
| Django                | 6.1.1   | Web framework & ORM           |
| Django REST Framework | 3.18.0  | RESTful API development       |
| django-cors-headers   | 4.10.0  | CORS support for frontend     |
| SQLite                | 3.x     | Lightweight database          |
| Python                | 3.10+   | Programming language          |
| Gunicorn              | Latest  | WSGI HTTP Server (production) |

### Frontend Stack

| Package           | Version  | Purpose                   |
| ----------------- | -------- | ------------------------- |
| Flutter           | 3.38.7+  | Multi-platform framework  |
| Dart              | 3.10.7+  | Programming language      |
| flutter_map       | 8.0.0    | Map widget & integration  |
| fl_chart          | 0.69.2   | Analytics & charts        |
| http              | 1.3.0    | HTTP client for API calls |
| lottie            | 3.1.3    | Vector animations         |
| latlong2          | 0.9.1    | Geographic coordinates    |
| Material Design 3 | Built-in | Modern UI/UX components   |

### Deployment

| Technology     | Purpose                       |
| -------------- | ----------------------------- |
| Docker         | Container orchestration       |
| Docker Compose | Multi-container configuration |

---

## 📱 Frontend Features & UI

### Screen Layouts

#### Desktop Layout (>600px width)

- Side navigation rail with labeled destinations
- Persistent navigation
- Wider map views and dashboards
- Multi-column layouts

#### Mobile Layout (≤600px width)

- Bottom navigation bar
- Floating action buttons for quick access
- Full-screen content views
- Touch-optimized interactions

### Feature Modules

| Module           | Description                                      |
| ---------------- | ------------------------------------------------ |
| **Map View**     | Interactive waste bin locations on OpenStreetMap |
| **Analytics**    | Statistical charts and dashboard for waste data  |
| **Request Bin**  | Form to submit new waste bin requests            |
| **Report Issue** | Report waste-related problems with location      |
| **Admin Panel**  | Management interface for administrators          |

### UI Components

- Modern Material Design 3 interface
- Responsive layouts for all screen sizes
- Animated transitions and Lottie animations
- Accessible navigation patterns
- Custom themed colors and typography

---

## 🌐 Multi-Platform Support

### Mobile Platforms

- **Android 5.0+** - Via `android/` configuration
- **iOS 11.0+** - Via `ios/` configuration

### Desktop Platforms

- **Windows 10+** - Via `windows/` configuration
- **Linux** - Via `linux/` configuration
- **macOS 10.11+** - Via `macos/` configuration

### Web Platform

- **Chrome** - Primary support
- **Firefox** - Supported
- **Safari** - Supported
- **Edge** - Supported

---

## 🔧 Configuration

### Backend Settings

Edit `backend/trash_tracker_backend/settings.py`:

```python
DEBUG = True                    # Set to False for production
ALLOWED_HOSTS = ['*']          # Specify hosts for production
SECRET_KEY = 'your-secret-key' # Use environment variables in production

CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",
    "http://localhost:5000",
    # Add your frontend URL for production
]

INSTALLED_APPS = [
    # Core Django apps
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',

    # Third-party apps
    'rest_framework',
    'corsheaders',

    # Local apps
    'wastebins',
    'admin_side',
    'map',
]
```

### Frontend Configuration

Edit `frontend/lib/main.dart`:

```dart
const String API_BASE_URL = 'http://127.0.0.1:8000/api/';
const String MAP_CENTER_LAT = 28.5355;
const String MAP_CENTER_LNG = 77.391;
```

### Environment Variables (Recommended)

Create `.env` in the backend directory:

```
DEBUG=True
SECRET_KEY=your-secret-key-here
ALLOWED_HOSTS=localhost,127.0.0.1
DATABASE_URL=sqlite:///db.sqlite3
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost:5000
```

### Docker Configuration

Edit `backend/docker-compose.yml` for production:

```yaml
version: "3.8"

services:
  web:
    build: .
    command: gunicorn trash_tracker_backend.wsgi:application --bind 0.0.0.0:8000
    ports:
      - "8000:8000"
    environment:
      DEBUG: "False"
      SECRET_KEY: "your-production-secret-key"
```

---

## 📊 Database Models

### WasteBin Model

```python
- id: Auto-generated unique identifier
- name: Bin name/location identifier
- latitude: GPS latitude coordinate
- longitude: GPS longitude coordinate
- fill_level: Choices (Empty, Half-Filled, Full)
- created_at: Timestamp when bin was created
- updated_at: Timestamp when bin was last modified
```

**Fill Level Codes:**

- `Empty` (0%) - Bin is empty
- `Half-Filled` (50%) - Bin is half full
- `Full` (100%) - Bin is full and needs collection

### Request Model

- `id`: Unique identifier
- `location`: Requested location/coordinates
- `description`: Request details and description
- `status`: Status (Pending, Approved, Completed)
- `created_at`: Request submission timestamp
- `updated_at`: Last status update timestamp

### ReportWaste Model

- `id`: Unique identifier
- `description`: Issue/problem description
- `latitude`: Report location latitude
- `longitude`: Report location longitude
- `created_at`: Report submission timestamp

### AdminNotification Model

- `id`: Unique identifier
- `waste_bin`: Foreign key to associated WasteBin
- `status`: Notification status (Read, Unread)
- `message`: Notification message content
- `created_at`: Notification creation timestamp

---

## 🧪 Testing

### Test Backend Endpoints

```bash
# Using curl
curl http://127.0.0.1:8000/api/wastebins/

# Using Python with requests
python -c "
import requests
response = requests.get('http://127.0.0.1:8000/api/wastebins/')
print(response.json())
"

# Using httpie (simpler curl alternative)
http GET http://127.0.0.1:8000/api/wastebins/
```

### Test Frontend

```bash
# Run widget tests
flutter test

# Run integration tests (if created)
flutter test integration_test/

# Build and test on physical device
flutter run --profile  # Profile mode for performance testing
```

### Run Tests with Coverage

```bash
# Backend (Django)
cd backend
coverage run --source='.' manage.py test
coverage report

# Frontend (Flutter)
cd ../frontend
flutter test --coverage
```

## 🐛 Troubleshooting

### Common Backend Issues

| Issue                    | Solution                                                                                                                     |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------------------- |
| Port 8000 already in use | `lsof -i :8000` and kill the process or use `python manage.py runserver 8001`                                                |
| ModuleNotFoundError      | Ensure virtual environment is activated: `.\.venv\Scripts\Activate.ps1` (Windows) or `source .venv/bin/activate` (Linux/Mac) |
| Database locked          | Delete `db.sqlite3` and run migrations again: `python manage.py migrate`                                                     |
| CORS errors in frontend  | Add frontend URL to `CORS_ALLOWED_ORIGINS` in settings.py                                                                    |
| Static files not found   | Run `python manage.py collectstatic`                                                                                         |

### Common Frontend Issues

| Issue                  | Solution                                                          |
| ---------------------- | ----------------------------------------------------------------- |
| flutter pub get fails  | Run `flutter clean` then `flutter pub get`                        |
| Device not found       | Run `flutter devices` to list available devices                   |
| Build fails            | Update Flutter: `flutter upgrade` or Clean build: `flutter clean` |
| API connection refused | Ensure backend is running and check API_BASE_URL in main.dart     |
| Map not displaying     | Verify latitude/longitude coordinates are valid                   |

### Docker Issues

```bash
# View container logs
docker-compose logs web

# Remove all containers and start fresh
docker-compose down -v
docker-compose up --build

# Access container shell
docker-compose exec web bash
```

## 📂 Key Files & Directories Reference

### Backend Key Files

| File                                        | Purpose                            |
| ------------------------------------------- | ---------------------------------- |
| `backend/manage.py`                         | Django management CLI              |
| `backend/requirements.txt`                  | Python package dependencies        |
| `backend/trash_tracker_backend/settings.py` | Django configuration               |
| `backend/trash_tracker_backend/urls.py`     | Main URL router                    |
| `backend/wastebins/models.py`               | Database models for bins & reports |
| `backend/wastebins/serializers.py`          | API request/response serializers   |
| `backend/wastebins/views.py`                | API endpoint handlers              |
| `backend/admin_side/admin.py`               | Django admin configuration         |
| `backend/templates/api_landing.html`        | API root HTML page                 |
| `backend/Dockerfile`                        | Docker container definition        |

### Frontend Key Files

| File                             | Purpose                         |
| -------------------------------- | ------------------------------- |
| `frontend/pubspec.yaml`          | Flutter & Dart dependencies     |
| `frontend/lib/main.dart`         | App entry point & configuration |
| `frontend/lib/mapscreen.dart`    | Map screen implementation       |
| `frontend/lib/analytics/`        | Analytics module & widgets      |
| `frontend/lib/pages/`            | Page screens/routes             |
| `frontend/lib/screens/`          | UI screen components            |
| `frontend/lib/requestbin/`       | New bin request functionality   |
| `frontend/lib/fohor/`            | Waste report functionality      |
| `frontend/analysis_options.yaml` | Dart analyzer configuration     |
| `frontend/web/index.html`        | Web app HTML entry point        |

## 📝 API Response Format

### Success Response (200)

```json
{
  "id": 1,
  "name": "Bin Location 1",
  "latitude": 28.5355,
  "longitude": 77.391,
  "fill_level": "Half-Filled",
  "created_at": "2026-05-02T10:30:00Z",
  "updated_at": "2026-05-02T10:30:00Z"
}
```

### Error Response (400)

```json
{
  "error": "Invalid fill level",
  "detail": "fill_level must be one of: Empty, Half-Filled, Full"
}
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see LICENSE file for details.

---

## 👨‍💻 Author

**Upendra** - [GitHub](https://github.com/Upendra48)

---

## 🎯 Roadmap

### Implemented Features ✅

- ✅ Real-time bin tracking and monitoring
- ✅ Route optimization for full bins
- ✅ Analytics dashboard for waste statistics
- ✅ Admin notifications system

### Planned Features

- [ ] User authentication (JWT tokens)
- [ ] Real-time notifications (WebSocket)
- [ ] Mobile app improvements
- [ ] Advanced analytics dashboard
- [ ] Machine learning for intelligent route optimization
- [ ] Multi-language support
- [ ] Dark mode UI
- [ ] Offline mode support
- [ ] Push notifications
- [ ] IoT sensor integration

---

## 📚 Additional Resources

- [Django REST Framework Docs](https://www.django-rest-framework.org/)
- [Flutter Documentation](https://flutter.dev/docs)
- [Material Design 3 Guide](https://m3.material.io/)
- [OpenStreetMap (flutter_map)](https://pub.dev/packages/flutter_map)

---

## ✨ Changelog

### v1.1.0 (June 24, 2026)

- ✅ Enhanced README with detailed documentation
- ✅ Added Docker/Docker-Compose setup guide
- ✅ Added troubleshooting section for common issues
- ✅ Added key files reference guide
- ✅ Added environment variables configuration
- ✅ Added testing and coverage guidelines
- ✅ Improved project structure documentation
- ✅ Added deployment considerations

### v1.0.0 (May 2, 2026)

- ✅ Initial project setup
- ✅ Django REST API with basic endpoints
- ✅ Flutter app with Material Design 3
- ✅ Map integration with flutter_map
- ✅ Analytics dashboard
- ✅ Request and report functionality
- ✅ GitHub repository setup
- ✅ Comprehensive API documentation

---

**Last Updated:** June 24, 2026  
**Status:** Active Development 🚀  
**Repository:** [GitHub](https://github.com/Upendra48/Sankalan)  
**Issues & Feedback:** [GitHub Issues](https://github.com/Upendra48/Sankalan/issues)
