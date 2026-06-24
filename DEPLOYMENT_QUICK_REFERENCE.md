# Deployment Quick Reference

## 🚀 One-Liner Deployment Commands

### Backend (Render)

```bash
# Push to main branch - GitHub Actions triggers deployment automatically
git add .
git commit -m "Deploy to Render"
git push origin main
```

### Frontend (Vercel)

```bash
# Push to main branch - GitHub Actions triggers deployment automatically
# OR use Vercel CLI
npm install -g vercel
cd frontend
vercel --prod
```

---

## 📋 Required Secrets for GitHub Actions

### Backend (Render)

```yaml
RENDER_SERVICE_ID: srv-xxxxxxxxxxxx
RENDER_DEPLOY_KEY: rnd_xxxxxxxxxxxx
```

### Frontend (Vercel)

```yaml
VERCEL_TOKEN: xxxxxxxxxxxx
VERCEL_ORG_ID: xxxxxxxxxxxx
VERCEL_PROJECT_ID: xxxxxxxxxxxx
```

---

## 🔗 Key URLs After Deployment

| Service           | URL                                                 | Notes                          |
| ----------------- | --------------------------------------------------- | ------------------------------ |
| Backend API       | `https://trash-tracker-backend.onrender.com/api/`   | Replace with your service name |
| Django Admin      | `https://trash-tracker-backend.onrender.com/admin/` | Requires superuser             |
| Frontend App      | `https://trash-tracker-frontend.vercel.app`         | Replace with your project name |
| GitHub Repo       | `https://github.com/Upendra48/Sankalan`             | Source code                    |
| Actions Workflows | `https://github.com/Upendra48/Sankalan/actions`     | CI/CD status                   |

---

## 🔐 Environment Variables Needed

### Render (Backend)

```
DEBUG=False
SECRET_KEY=your-strong-secret-key-here
ALLOWED_HOSTS=trash-tracker-backend.onrender.com,localhost
CORS_ALLOWED_ORIGINS=https://trash-tracker-frontend.vercel.app,http://localhost:3000
SECURE_SSL_REDIRECT=True
SESSION_COOKIE_SECURE=True
CSRF_COOKIE_SECURE=True
```

### Vercel (Frontend)

```
API_BASE_URL=https://trash-tracker-backend.onrender.com/api/
```

---

## 📊 Workflow Status

### Backend CI/CD (.github/workflows/backend-ci.yml)

- ✅ Python 3.10 & 3.11 tests
- ✅ Django checks & migrations
- ✅ Code linting (flake8, black)
- ✅ Auto-deploy to Render on main push
- **Trigger**: Push/PR to main/develop with `backend/**` changes

### Frontend CI/CD (.github/workflows/frontend-ci.yml)

- ✅ Flutter 3.38.7 setup
- ✅ Code analysis & formatting
- ✅ Flutter tests
- ✅ Web build (CanvasKit)
- ✅ Auto-deploy to Vercel on main push
- **Trigger**: Push/PR to main/develop with `frontend/**` changes

---

## 🔄 Deployment Flow

```
1. Push code to GitHub (main branch)
        ↓
2. GitHub Actions triggers workflows
        ↓
   Backend Workflow          Frontend Workflow
   ├─ Test Python            ├─ Setup Flutter
   ├─ Run Django tests       ├─ Analyze code
   ├─ Lint code              ├─ Build web
   └─ Deploy to Render       └─ Deploy to Vercel
        ↓                         ↓
3. Backend live at           Frontend live at
   render.com                vercel.app
```

---

## 🛠️ Configuration Files

| File                                | Purpose                  | Location                          |
| ----------------------------------- | ------------------------ | --------------------------------- |
| `render.yaml`                       | Render deployment config | `/`                               |
| `vercel.json`                       | Vercel deployment config | `/frontend/`                      |
| `build.sh`                          | Render build script      | `/backend/`                       |
| `production_settings.py`            | Django production config | `/backend/trash_tracker_backend/` |
| `.github/workflows/backend-ci.yml`  | Backend CI/CD            | `/.github/workflows/`             |
| `.github/workflows/frontend-ci.yml` | Frontend CI/CD           | `/.github/workflows/`             |
| `DEPLOYMENT_GUIDE.md`               | Detailed setup guide     | `/`                               |
| `DEPLOYMENT_CHECKLIST.md`           | Pre-deployment checklist | `/`                               |

---

## 🚨 Common Issues & Fixes

### Backend Not Deploying

```bash
# Check Render logs for errors
# Verify SECRET_KEY is set
# Ensure ALLOWED_HOSTS includes your Render domain
# Check if build.sh has correct permissions
chmod +x backend/build.sh
```

### Frontend Build Failing

```bash
# Clear Flutter cache
flutter clean

# Get fresh dependencies
flutter pub get

# Try building locally first
flutter build web --release

# Check Vercel build command is correct
```

### CORS Errors

```
# Add your frontend URL to backend CORS_ALLOWED_ORIGINS
CORS_ALLOWED_ORIGINS=https://trash-tracker-frontend.vercel.app,http://localhost:3000
```

### API Not Responding

```bash
# Check backend is running
curl https://trash-tracker-backend.onrender.com/api/

# Verify frontend API_BASE_URL is correct
# Check network tab in browser DevTools
```

---

## 📈 Monitoring Links

- **Render Dashboard**: https://dashboard.render.com/
- **Vercel Dashboard**: https://vercel.com/dashboard
- **GitHub Actions**: https://github.com/Upendra48/Sankalan/actions
- **GitHub Secrets**: https://github.com/Upendra48/Sankalan/settings/secrets/actions

---

## 🎓 Learning Resources

- [Render Django Deployment](https://render.com/docs/deploy-django)
- [Vercel Flutter Web](https://vercel.com/docs/concepts/frameworks/flutter)
- [GitHub Actions Documentation](https://docs.github.com/actions)
- [Django Production Deployment](https://docs.djangoproject.com/en/6.0/howto/deployment/)

---

**Last Updated**: June 24, 2026  
**Deployment Status**: Ready for Production 🚀
