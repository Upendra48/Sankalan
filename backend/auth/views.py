from rest_framework import status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.views import TokenRefreshView

from wastebins.api_base import enveloped_response

from .serializers import SessionCreateSerializer, SessionSerializer, UserSerializer
from .services import get_or_create_google_user, serialize_user


class SessionCreateView(APIView):
    """POST /api/auth/sessions/ — create a JWT session (Google sign-in)."""

    permission_classes = [AllowAny]

    def post(self, request):
        input_serializer = SessionCreateSerializer(data=request.data)
        input_serializer.is_valid(raise_exception=True)

        user, profile = get_or_create_google_user(
            email=input_serializer.validated_data['email'],
            name=input_serializer.validated_data.get('name', ''),
            google_id=input_serializer.validated_data.get('google_id', ''),
            photo_url=input_serializer.validated_data.get('photo_url', ''),
        )

        refresh = RefreshToken.for_user(user)
        session_data = {
            'access': str(refresh.access_token),
            'refresh': str(refresh),
            'user': serialize_user(user, profile),
        }
        output_serializer = SessionSerializer(session_data)
        response = enveloped_response(request, output_serializer.data)
        response.status_code = status.HTTP_201_CREATED
        response['Location'] = request.build_absolute_uri()
        return response


class SessionRefreshView(TokenRefreshView):
    """POST /api/auth/sessions/refresh/ — refresh an access token."""

    permission_classes = [AllowAny]


class CurrentUserView(APIView):
    """GET /api/auth/me/ — return the authenticated user profile."""

    permission_classes = [IsAuthenticated]

    def get(self, request):
        user_data = serialize_user(request.user)
        serializer = UserSerializer(user_data)
        return enveloped_response(
            request,
            serializer.data,
            extra_links={'sessions': request.build_absolute_uri('/api/auth/sessions/')},
        )
