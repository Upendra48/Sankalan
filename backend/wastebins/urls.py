from django.urls import include, path
from rest_framework.routers import DefaultRouter

from .views import (
    BinRequestViewSet,
    CollectionRouteViewSet,
    WasteBinAnalyticsViewSet,
    WasteBinViewSet,
    WasteReportViewSet,
)

router = DefaultRouter()
router.register(r'waste-bins', WasteBinViewSet, basename='waste-bin')
router.register(r'bin-requests', BinRequestViewSet, basename='bin-request')
router.register(r'waste-reports', WasteReportViewSet, basename='waste-report')
router.register(r'waste-bin-analytics', WasteBinAnalyticsViewSet, basename='waste-bin-analytics')
router.register(r'collection-routes', CollectionRouteViewSet, basename='collection-route')

urlpatterns = [
    path('', include(router.urls)),
]
