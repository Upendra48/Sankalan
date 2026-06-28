from django.contrib.auth.models import User

from rest_framework import status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.views import TokenRefreshView

from wastebins.api_base import enveloped_response

from .models import UserProfile
from .serializers import (
    RegisterSerializer,
    LoginSerializer,
    UserSerializer,
)

from .services import create_user_profile


class RegisterView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)

        if not serializer.is_valid():
            return enveloped_response(
                success=False,
                errors=serializer.errors,
                status_code=status.HTTP_400_BAD_REQUEST,
            )

        user = serializer.save()

        create_user_profile(user)

        refresh = RefreshToken.for_user(user)

        return enveloped_response(
            success=True,
            data={
                "user": UserSerializer(user).data,
                "tokens": {
                    "access": str(refresh.access_token),
                    "refresh": str(refresh),
                },
            },
            status_code=status.HTTP_201_CREATED,
        )


class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = LoginSerializer(data=request.data)

        if not serializer.is_valid():
            return enveloped_response(
                success=False,
                errors=serializer.errors,
                status_code=status.HTTP_400_BAD_REQUEST,
            )

        user = serializer.validated_data["user"]

        refresh = RefreshToken.for_user(user)

        return enveloped_response(
            success=True,
            data={
                "user": UserSerializer(user).data,
                "tokens": {
                    "access": str(refresh.access_token),
                    "refresh": str(refresh),
                },
            },
            status_code=status.HTTP_200_OK,
        )


class CurrentUserView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        return enveloped_response(
            success=True,
            data=UserSerializer(request.user).data,
            status_code=status.HTTP_200_OK,
        )


class SessionRefreshView(TokenRefreshView):
    permission_classes = [AllowAny]