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
        
        data = {
            'total_bins': total_bins,
            'empty_bins': empty_bins,
            'half_filled_bins': half_filled_bins,
            'full_bins': full_bins,
            'empty_bins_percentage': empty_bins_percentage,
            'half_filled_bins_percentage': half_filled_bins_percentage,
            'full_bins_percentage': full_bins_percentage,
        }
        return Response(data)

