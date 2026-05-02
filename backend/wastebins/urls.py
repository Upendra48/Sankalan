from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import WasteBinViewSet, RequestViewSet, AdminNotificationViewSet, ReportWasteViewSet
from . import views

router = DefaultRouter()
router.register(r'wastebins', WasteBinViewSet)
router.register(r'requests', RequestViewSet)
router.register(r'admin-notifications', AdminNotificationViewSet)
router.register(r'report-waste', ReportWasteViewSet)
router.register(r'waste-bin-analytics', views.WasteBinAnalyticsViewSet, basename='waste-bin-analytics')


urlpatterns = [
    path('', include(router.urls))
]
