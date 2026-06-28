"""
URL configuration for trash_tracker_backend project.
"""
from django.contrib import admin
from django.urls import include, path
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView
from rest_framework.permissions import AllowAny

from .views import APILandingView, api_root

SpectacularAPIView.permission_classes = [AllowAny]
SpectacularSwaggerView.permission_classes = [AllowAny]

urlpatterns = [
    path('', APILandingView.as_view(), name='api-landing'),
    path('admin/', admin.site.urls),
    path('api/', api_root, name='api-root'),
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/docs/', SpectacularSwaggerView.as_view(url_name='schema'), name='docs'),
    path('api/auth/', include('auth.urls')),
    path('api/waste-bins/', include('wastebins.urls')),
]
