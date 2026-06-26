from rest_framework.permissions import BasePermission, IsAuthenticated


class IsAuthenticatedFrontendUser(IsAuthenticated):
    """Authenticated non-staff users accessing the public frontend API."""

    message = 'Authentication credentials were not provided or are invalid.'


class IsStaffAdmin(BasePermission):
    """Reserved for internal tooling — staff manage data via Django admin, not the public API."""

    message = 'Admin operations are only available through the Django admin panel.'

    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.is_staff
