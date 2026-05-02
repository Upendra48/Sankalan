from rest_framework import serializers
from .models import ReportWaste, WasteBin, Request, AdminNotification

class WasteBinSerializer(serializers.ModelSerializer):
    class Meta:
        model = WasteBin
        fields = ['id','name', 'latitude','longitude', 'fill_level', 'status']

class RequestSerializer(serializers.ModelSerializer):
    class Meta:
        model = Request
        fields = ['id', 'user_name', 'latitude','longitude', 'reason', 'status']

class AdminNotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = AdminNotification
        fields = ['id', 'waste_bin', 'status', 'date_reported']
        
class ReportWasteSerializer(serializers.ModelSerializer):
    class Meta:
        model = ReportWaste
        fields = ['id', 'user_name', 'latitude','longitude', 'description', 'date_reported']

