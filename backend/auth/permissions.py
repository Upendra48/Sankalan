from rest_framework.permissions import BasePermission, IsAuthenticated


class IsAuthenticatedFrontendUser(IsAuthenticated):
    """
    Allows access only to authenticated users.
    Used for all frontend API endpoints.
    """

    message = "Authentication credentials were not provided or are invalid."


class IsStaffAdmin(BasePermission):
    """
    Allows access only to authenticated staff users.
    Used for admin-only API endpoints.
    """

    message = "You do not have permission to perform this action."

    def has_permission(self, request, view):
        return (
            request.user
            and request.user.is_authenticated
            and request.user.is_staff
        )