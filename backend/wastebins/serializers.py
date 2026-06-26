from rest_framework import serializers
from .models import ReportWaste, WasteBin, Request


class ResourceLinksMixin:
    """Adds HATEOAS _links to serialized resources."""

    def get_links(self, obj):
        request = self.context.get('request')
        if not request:
            return {}
        return self.build_resource_links(request, obj)

    def build_resource_links(self, request, obj):
        raise NotImplementedError


class WasteBinSerializer(ResourceLinksMixin, serializers.ModelSerializer):
    links = serializers.SerializerMethodField()

    class Meta:
        model = WasteBin
        fields = ['id', 'name', 'latitude', 'longitude', 'fill_level', 'status', 'links']
        read_only_fields = ['id', 'links']

    def build_resource_links(self, request, obj):
        return {
            'self': request.build_absolute_uri(f'/api/waste-bins/{obj.id}/'),
            'collection': request.build_absolute_uri('/api/waste-bins/'),
        }


class BinRequestSerializer(ResourceLinksMixin, serializers.ModelSerializer):
    links = serializers.SerializerMethodField()

    class Meta:
        model = Request
        fields = ['id', 'user_name', 'latitude', 'longitude', 'reason', 'status', 'links']
        read_only_fields = ['id', 'status', 'links']

    def build_resource_links(self, request, obj):
        return {
            'self': request.build_absolute_uri(f'/api/bin-requests/{obj.id}/'),
            'collection': request.build_absolute_uri('/api/bin-requests/'),
        }


class WasteReportSerializer(ResourceLinksMixin, serializers.ModelSerializer):
    links = serializers.SerializerMethodField()

    class Meta:
        model = ReportWaste
        fields = ['id', 'user_name', 'latitude', 'longitude', 'description', 'date_reported', 'links']
        read_only_fields = ['id', 'date_reported', 'links']

    def build_resource_links(self, request, obj):
        return {
            'self': request.build_absolute_uri(f'/api/waste-reports/{obj.id}/'),
            'collection': request.build_absolute_uri('/api/waste-reports/'),
        }


class WasteBinAnalyticsSerializer(serializers.Serializer):
  total_bins = serializers.IntegerField()
  empty_bins = serializers.IntegerField()
  half_filled_bins = serializers.IntegerField()
  full_bins = serializers.IntegerField()
  empty_bins_percentage = serializers.FloatField()
  half_filled_bins_percentage = serializers.FloatField()
  full_bins_percentage = serializers.FloatField()
  filled_last_24h = serializers.IntegerField()
  reports_last_24h = serializers.IntegerField()
  efficiency_rate = serializers.FloatField()
  weekly_activity = serializers.ListField(child=serializers.DictField())


class CollectionRouteSerializer(serializers.Serializer):
    start_point = serializers.DictField()
    route = WasteBinSerializer(many=True)
    total_distance_km = serializers.FloatField()
