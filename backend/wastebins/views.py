import math
from datetime import timedelta
from django.utils import timezone
from django.shortcuts import render
from rest_framework import viewsets
from rest_framework.decorators import action
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import ReportWaste, WasteBin, Request, AdminNotification
from .serializers import ReportWasteSerializer, WasteBinSerializer, RequestSerializer, AdminNotificationSerializer

class WasteBinViewSet(viewsets.ModelViewSet):
    queryset = WasteBin.objects.all()
    serializer_class = WasteBinSerializer

    @action(detail=True, methods=['put'])
    def change_fill_level(self, request, pk=None):
        bin = self.get_object()
        new_fill_level = request.data.get('fill_level')
        if new_fill_level in ['Empty', 'Half-Filled', 'Full']:
            bin.fill_level = new_fill_level
            bin.save()
            return Response({'status': 'fill level updated'})
        return Response({'status': 'invalid fill level'}, status=400)

    @action(detail=True, methods=['post'])
    def report_full(self, request, pk=None):
        bin = self.get_object()
        if bin.fill_level == 'Full':
            AdminNotification.objects.create(waste_bin=bin, status='Full')
            return Response({'status': 'bin reported as full'})
        return Response({'status': 'bin is not full'}, status=400)

    @action(detail=False, methods=['get'], url_path='optimized-route')
    def optimized_route(self, request):
        # Default start coordinates (Pokhara Center depot)
        default_lat = 28.261336
        default_lng = 83.971944
        
        try:
            start_lat = float(request.query_params.get('start_lat', default_lat))
            start_lng = float(request.query_params.get('start_lng', default_lng))
        except ValueError:
            return Response({'error': 'Invalid start coordinates'}, status=400)
            
        # Get active bins that need collection (Full or Half-Filled)
        bins = list(WasteBin.objects.filter(fill_level__in=['Full', 'Half-Filled'], status=True))
        
        if not bins:
            return Response({
                'start_point': {'latitude': start_lat, 'longitude': start_lng},
                'route': [],
                'total_distance_km': 0.0
            })
            
        # Haversine distance calculator
        def haversine_distance(lat1, lon1, lat2, lon2):
            R = 6371.0  # Earth radius in kilometers
            dlat = math.radians(lat2 - lat1)
            dlon = math.radians(lon2 - lon1)
            a = (math.sin(dlat / 2)**2 + 
                 math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon / 2)**2)
            c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
            return R * c
            
        # Nearest Neighbor Algorithm
        ordered_bins = []
        current_lat = start_lat
        current_lng = start_lng
        total_distance = 0.0
        
        unvisited = bins[:]
        while unvisited:
            # Find the closest unvisited bin
            closest_bin = min(
                unvisited,
                key=lambda b: haversine_distance(current_lat, current_lng, float(b.latitude), float(b.longitude))
            )
            dist = haversine_distance(current_lat, current_lng, float(closest_bin.latitude), float(closest_bin.longitude))
            total_distance += dist
            
            # Move to closest bin
            current_lat = float(closest_bin.latitude)
            current_lng = float(closest_bin.longitude)
            
            ordered_bins.append(closest_bin)
            unvisited.remove(closest_bin)
            
        # Serialize the ordered list of bins
        serializer = self.get_serializer(ordered_bins, many=True)
        
        return Response({
            'start_point': {'latitude': start_lat, 'longitude': start_lng},
            'route': serializer.data,
            'total_distance_km': round(total_distance, 2)
        })

    

class RequestViewSet(viewsets.ModelViewSet):
    queryset = Request.objects.all()
    serializer_class = RequestSerializer

class AdminNotificationViewSet(viewsets.ModelViewSet):
    queryset = AdminNotification.objects.all()
    serializer_class = AdminNotificationSerializer

class ReportWasteViewSet(viewsets.ModelViewSet):
    queryset = ReportWaste.objects.all()
    serializer_class = ReportWasteSerializer

class WasteBinAnalyticsViewSet(viewsets.ViewSet):
    def list(self, request):
        total_bins = WasteBin.objects.all().count()
        empty_bins = WasteBin.objects.filter(fill_level='Empty').count()
        half_filled_bins = WasteBin.objects.filter(fill_level='Half-Filled').count()
        full_bins = WasteBin.objects.filter(fill_level='Full').count()
        
        if total_bins > 0:
            empty_bins_percentage = (empty_bins / total_bins) * 100
            half_filled_bins_percentage = (half_filled_bins / total_bins) * 100
            full_bins_percentage = (full_bins / total_bins) * 100
        else: 
            empty_bins_percentage = 0
            half_filled_bins_percentage = 0
            full_bins_percentage = 0

        # Enriched SaaS insights
        now = timezone.now()
        day_ago = now - timedelta(hours=24)
        
        # 1. Bins filled in the last 24 hours
        filled_last_24h = AdminNotification.objects.filter(
            status='Full',
            date_reported__gte=day_ago
        ).count()
        
        # 2. Community reports in the last 24 hours
        reports_last_24h = ReportWaste.objects.filter(
            date_reported__gte=day_ago
        ).count()
        
        # 3. Collection Efficiency Rate
        total_alerts = AdminNotification.objects.count()
        collected_alerts = AdminNotification.objects.filter(status='Collected').count()
        if total_alerts > 0:
            efficiency_rate = round((collected_alerts / total_alerts) * 100, 1)
        else:
            efficiency_rate = 100.0
            
        # 4. Weekly Activity Timeline (bins filled per day for the last 7 days)
        weekly_activity = []
        for i in range(6, -1, -1):
            day_start = now.date() - timedelta(days=i)
            day_count = AdminNotification.objects.filter(
                status='Full',
                date_reported__date=day_start
            ).count()
            
            day_label = day_start.strftime('%a')
            weekly_activity.append({
                'day': day_label,
                'count': day_count
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
        return Response(data)


@api_view(['POST'])
def google_login(request):
    email = request.data.get('email')
    name = request.data.get('name', '')
    google_id = request.data.get('google_id', '')
    photo_url = request.data.get('photo_url', '')

    if not email:
        return Response({'error': 'Email is required'}, status=400)

    from django.contrib.auth.models import User
    
    # Check if user already exists
    user_exists = User.objects.filter(username=email).exists()
    
    if not user_exists:
        # Create a new user but set is_staff = False (unverified)
        user = User.objects.create_user(
            username=email,
            email=email,
            first_name=name
        )
        user.is_staff = False
        user.save()
    else:
        user = User.objects.get(username=email)
        # Update name if changed
        if name and user.first_name != name:
            user.first_name = name
            user.save()

    return Response({
        'token': f"mock-jwt-token-for-{user.username}",
        'user': {
            'email': user.email,
            'name': user.first_name or user.username.split('@')[0],
            'photo_url': photo_url or 'https://www.gravatar.com/avatar/',
            'is_verified': user.is_staff
        }
    })


