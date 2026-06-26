import math
from datetime import timedelta

from django.utils import timezone
from rest_framework import status
from rest_framework.response import Response

from auth.permissions import IsAuthenticatedFrontendUser
from .api_base import EnvelopedModelViewSet, EnvelopedViewSet, enveloped_response
from .models import AdminNotification, ReportWaste, Request, WasteBin
from .pagination import EnvelopePagination
from .serializers import (
    BinRequestSerializer,
    WasteBinAnalyticsSerializer,
    WasteBinSerializer,
    WasteReportSerializer,
)


class WasteBinViewSet(EnvelopedModelViewSet):
    """
    Waste bin resource collection.

    Use PATCH for partial updates (e.g. fill_level) instead of action endpoints.
    """
    queryset = WasteBin.objects.all()
    serializer_class = WasteBinSerializer
    pagination_class = EnvelopePagination
    permission_classes = [IsAuthenticatedFrontendUser]
    filterset_fields = ['fill_level', 'status']
    search_fields = ['name']
    ordering_fields = ['id', 'name', 'fill_level']


class BinRequestViewSet(EnvelopedModelViewSet):
    queryset = Request.objects.all()
    serializer_class = BinRequestSerializer
    pagination_class = EnvelopePagination
    permission_classes = [IsAuthenticatedFrontendUser]
    filterset_fields = ['status']
    search_fields = ['user_name', 'reason']
    ordering_fields = ['id', 'user_name', 'status']

    def perform_create(self, serializer):
        serializer.save(status=Request.PENDING)


class WasteReportViewSet(EnvelopedModelViewSet):
    queryset = ReportWaste.objects.all()
    serializer_class = WasteReportSerializer
    pagination_class = EnvelopePagination
    permission_classes = [IsAuthenticatedFrontendUser]
    search_fields = ['user_name', 'description']
    ordering_fields = ['id', 'date_reported']


class WasteBinAnalyticsViewSet(EnvelopedViewSet):
    """Singleton analytics resource — GET returns aggregated waste bin statistics."""
    permission_classes = [IsAuthenticatedFrontendUser]

    def list(self, request):
        total_bins = WasteBin.objects.count()
        empty_bins = WasteBin.objects.filter(fill_level=WasteBin.EMPTY).count()
        half_filled_bins = WasteBin.objects.filter(fill_level=WasteBin.HALF_FILLED).count()
        full_bins = WasteBin.objects.filter(fill_level=WasteBin.FULL).count()

        if total_bins > 0:
            empty_bins_percentage = (empty_bins / total_bins) * 100
            half_filled_bins_percentage = (half_filled_bins / total_bins) * 100
            full_bins_percentage = (full_bins / total_bins) * 100
        else:
            empty_bins_percentage = 0
            half_filled_bins_percentage = 0
            full_bins_percentage = 0

        now = timezone.now()
        day_ago = now - timedelta(hours=24)

        filled_last_24h = AdminNotification.objects.filter(
            status=AdminNotification.FULL,
            date_reported__gte=day_ago,
        ).count()

        reports_last_24h = ReportWaste.objects.filter(
            date_reported__gte=day_ago,
        ).count()

        total_alerts = AdminNotification.objects.count()
        collected_alerts = AdminNotification.objects.filter(
            status=AdminNotification.COLLECTED,
        ).count()
        efficiency_rate = (
            round((collected_alerts / total_alerts) * 100, 1) if total_alerts > 0 else 100.0
        )

        weekly_activity = []
        for i in range(6, -1, -1):
            day_start = now.date() - timedelta(days=i)
            day_count = AdminNotification.objects.filter(
                status=AdminNotification.FULL,
                date_reported__date=day_start,
            ).count()
            weekly_activity.append({
                'day': day_start.strftime('%a'),
                'count': day_count,
            })

        data = {
            'total_bins': total_bins,
            'empty_bins': empty_bins,
            'half_filled_bins': half_filled_bins,
            'full_bins': full_bins,
            'empty_bins_percentage': empty_bins_percentage,
            'half_filled_bins_percentage': half_filled_bins_percentage,
            'full_bins_percentage': full_bins_percentage,
            'filled_last_24h': filled_last_24h,
            'reports_last_24h': reports_last_24h,
            'efficiency_rate': efficiency_rate,
            'weekly_activity': weekly_activity,
        }

        serializer = WasteBinAnalyticsSerializer(data)
        return self.enveloped(
            request,
            serializer.data,
            extra_links={
                'waste_bins': request.build_absolute_uri('/api/waste-bins/'),
                'waste_reports': request.build_absolute_uri('/api/waste-reports/'),
            },
        )


class CollectionRouteViewSet(EnvelopedViewSet):
    """
    Collection route resource — GET with query params computes an optimized route.

    Query params: start_lat, start_lng (defaults to Pokhara depot).
    Filter bins via fill_level and status on /waste-bins/ instead of nesting.
    """
    permission_classes = [IsAuthenticatedFrontendUser]

    def list(self, request):
        default_lat = 28.261336
        default_lng = 83.971944

        try:
            start_lat = float(request.query_params.get('start_lat', default_lat))
            start_lng = float(request.query_params.get('start_lng', default_lng))
        except (TypeError, ValueError):
            return Response(
                {
                    'type': 'https://sankalan.dev/problems/invalid-coordinates',
                    'title': 'Bad Request',
                    'status': 400,
                    'detail': 'start_lat and start_lng must be valid numbers.',
                    'instance': request.build_absolute_uri(),
                },
                status=status.HTTP_400_BAD_REQUEST,
                content_type='application/problem+json',
            )

        bins = list(
            WasteBin.objects.filter(
                fill_level__in=[WasteBin.FULL, WasteBin.HALF_FILLED],
                status=True,
            )
        )

        if not bins:
            return self.enveloped(
                request,
                {
                    'start_point': {'latitude': start_lat, 'longitude': start_lng},
                    'route': [],
                    'total_distance_km': 0.0,
                },
                extra_links={'waste_bins': request.build_absolute_uri('/api/waste-bins/')},
            )

        def haversine_distance(lat1, lon1, lat2, lon2):
            earth_radius_km = 6371.0
            dlat = math.radians(lat2 - lat1)
            dlon = math.radians(lon2 - lon1)
            a = (
                math.sin(dlat / 2) ** 2
                + math.cos(math.radians(lat1))
                * math.cos(math.radians(lat2))
                * math.sin(dlon / 2) ** 2
            )
            c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
            return earth_radius_km * c

        ordered_bins = []
        current_lat = start_lat
        current_lng = start_lng
        total_distance = 0.0
        unvisited = bins[:]

        while unvisited:
            closest_bin = min(
                unvisited,
                key=lambda b: haversine_distance(
                    current_lat, current_lng, float(b.latitude), float(b.longitude)
                ),
            )
            dist = haversine_distance(
                current_lat, current_lng,
                float(closest_bin.latitude), float(closest_bin.longitude),
            )
            total_distance += dist
            current_lat = float(closest_bin.latitude)
            current_lng = float(closest_bin.longitude)
            ordered_bins.append(closest_bin)
            unvisited.remove(closest_bin)

        route_serializer = WasteBinSerializer(
            ordered_bins, many=True, context={'request': request},
        )

        return self.enveloped(
            request,
            {
                'start_point': {'latitude': start_lat, 'longitude': start_lng},
                'route': route_serializer.data,
                'total_distance_km': round(total_distance, 2),
            },
            extra_links={'waste_bins': request.build_absolute_uri('/api/waste-bins/')},
        )
