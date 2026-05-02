# Sankalan - Smart Waste Management System

A comprehensive waste management solution built with Django REST API backend and Flutter frontend. Sankalan helps track, manage, and optimize waste collection with real-time bin monitoring and analytics.

## 🌟 Features

### Backend

- **RESTful API** with Django REST Framework
- **Real-time bin tracking** and monitoring
- **Analytics dashboard** for waste statistics
- **Admin notifications** for full bins
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
├── backend/                          # Django REST API
│   ├── trash_tracker_backend/        # Main Django project
│   ├── wastebins/                    # Waste bin management app
│   ├── admin_side/                   # Admin interface
│   ├── map/                          # Map functionality
│   ├── manage.py                     # Django management
│   ├── requirements.txt              # Python dependencies
│   ├── db.sqlite3                    # Database
│   └── templates/                    # HTML templates
│
├── frontend/                         # Flutter app
│   ├── lib/
│   │   ├── main.dart                 # Main entry point
│   │   ├── mapscreen.dart            # Map screen
│   │   ├── analytics/                # Analytics module
│   │   ├── pages/                    # Page screens
│   │   ├── requestbin/               # Request bin forms
│   │   └── fohor/                    # Report forms
│   ├── pubspec.yaml                  # Flutter dependencies
│   ├── android/                      # Android configuration
│   ├── ios/                          # iOS configuration
│   └── web/                          # Web build
│
├── UPGRADE_SUMMARY.md                # Dependency upgrade details
└── README.md                         # This file
```

---

## 🚀 Quick Start

### Prerequisites

- **Python 3.10+** (Backend)
- **Flutter 3.38.7+** (Frontend)
- **Dart 3.10.7+** (Frontend)
- **Git**

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
# Web (Chrome)
flutter run -d chrome

# Android
flutter run -d android

# iOS
flutter run -d ios

# Windows
flutter run -d windows
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

#### 6. **Landing Page**

```
GET    /                            # API landing page (HTML)
GET    /api/                        # API root (JSON)
GET    /admin/                      # Django admin panel
```

---

## 🛠️ Technologies Used

### Backend

| Technology            | Version | Purpose       |
| --------------------- | ------- | ------------- |
| Django                | 6.1.1   | Web framework |
| Django REST Framework | 3.18.0  | API framework |
| django-cors-headers   | 4.10.0  | CORS support  |
| Python                | 3.10+   | Language      |
| SQLite                | Latest  | Database      |

### Frontend

| Package     | Version | Purpose          |
| ----------- | ------- | ---------------- |
| Flutter     | 3.38.7+ | Framework        |
| Dart        | 3.10.7+ | Language         |
| flutter_map | 8.0.0   | Map integration  |
| fl_chart    | 0.69.2  | Charts/Analytics |
| http        | 1.3.0   | HTTP requests    |
| lottie      | 3.1.3   | Animations       |
| latlong2    | 0.9.1   | Location data    |

---

## 📱 Frontend Features

### Navigation

- **Map View**: Interactive waste bin location map
- **Analytics**: Statistics and charts dashboard
- **Request Bin**: Submit new waste bin requests
- **Report Issue**: Report waste-related problems

### UI Components

- Modern Material Design 3 interface
- Navigation Rail (Desktop) / Bottom Navigation (Mobile)
- Floating Action Buttons for quick access
- Responsive layouts for all screen sizes

### Responsive Design

- **Desktop (>600px width)**: Side navigation with labeled destinations
- **Mobile (≤600px width)**: Floating action buttons with full-screen content

---

## 🔧 Configuration

### Backend Settings

Edit `backend/trash_tracker_backend/settings.py`:

```python
DEBUG = True                    # Set to False for production
ALLOWED_HOSTS = ['*']          # Specify hosts for production
CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",
    # Add your frontend URL
]
```

### Frontend Configuration

Edit `frontend/lib/main.dart`:

```dart
const String API_BASE_URL = 'http://127.0.0.1:8000/api/';
```

---

## 📊 Database Models

### WasteBin

- `id`: Unique identifier
- `name`: Bin name/location
- `latitude`: GPS latitude
- `longitude`: GPS longitude
- `fill_level`: Empty, Half-Filled, Full
- `created_at`: Creation timestamp
- `updated_at`: Last update timestamp

### Request

- `id`: Unique identifier
- `location`: Requested location
- `description`: Request details
- `status`: Pending, Approved, Completed
- `created_at`: Creation timestamp

### ReportWaste

- `id`: Unique identifier
- `description`: Issue description
- `latitude`: Location latitude
- `longitude`: Location longitude
- `created_at`: Report timestamp

### AdminNotification

- `id`: Unique identifier
- `waste_bin`: Associated bin
- `status`: Full (bin status)
- `created_at`: Notification timestamp

---

## 🧪 Testing

### Test Backend Endpoints

```bash
# Using curl
curl http://127.0.0.1:8000/api/wastebins/

# Using Python
python -c "
import requests
response = requests.get('http://127.0.0.1:8000/api/wastebins/')
print(response.json())
"
```


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

### Planned Features

- [ ] User authentication (JWT tokens)
- [ ] Real-time notifications (WebSocket)
- [ ] Mobile app improvements
- [ ] Advanced analytics dashboard
- [ ] Machine learning for route optimization
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

**Last Updated:** May 2, 2026  
**Status:** Active Development 🚀
