from rest_framework import serializers


class SessionCreateSerializer(serializers.Serializer):
    email = serializers.EmailField()
    name = serializers.CharField(required=False, allow_blank=True, default='')
    google_id = serializers.CharField(required=False, allow_blank=True, default='')
    photo_url = serializers.URLField(required=False, allow_blank=True, default='')


class SessionSerializer(serializers.Serializer):
    access = serializers.CharField()
    refresh = serializers.CharField()
    user = serializers.DictField()


class UserSerializer(serializers.Serializer):
    email = serializers.EmailField()
    name = serializers.CharField()
    photo_url = serializers.URLField()
    is_verified = serializers.BooleanField()
