from django.urls import path

from .views import CurrentUserView, SessionCreateView, SessionRefreshView

urlpatterns = [
    path('sessions/', SessionCreateView.as_view(), name='auth-session-create'),
    path('sessions/refresh/', SessionRefreshView.as_view(), name='auth-session-refresh'),
    path('me/', CurrentUserView.as_view(), name='auth-current-user'),
]
