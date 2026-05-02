
from django.contrib import admin
from django.urls import path, include
from admin_side.admin import admin_site  # Import custom admin site

urlpatterns = [
    path('admin/', admin_site.urls),
    path('wastebins/', include('wastebins.urls')),
]
