from django.views.generic import TemplateView

from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response


class APILandingView(TemplateView):
    """Landing page for the Sankalan API."""
    template_name = "api_landing.html"

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)

        context["api_endpoints"] = [
            {
                "name": "Register",
                "url": "/api/auth/register/",
                "methods": ["POST"],
                "description": "Create a new user account.",
            },
            {
                "name": "Login",
                "url": "/api/auth/login/",
                "methods": ["POST"],
                "description": "Login with username and password to receive JWT tokens.",
            },
            {
                "name": "Refresh Token",
                "url": "/api/auth/refresh/",
                "methods": ["POST"],
                "description": "Generate a new access token using a refresh token.",
            },
            {
                "name": "Current User",
                "url": "/api/auth/me/",
                "methods": ["GET"],
                "description": "Retrieve the authenticated user's profile.",
            },
            {
                "name": "Waste Bins",
                "url": "/api/waste-bins/",
                "methods": ["GET", "POST", "PUT", "PATCH", "DELETE"],
                "description": "Manage waste bins.",
            },
            {
                "name": "Bin Requests",
                "url": "/api/bin-requests/",
                "methods": ["GET", "POST", "PUT", "PATCH", "DELETE"],
                "description": "Request installation of new waste bins.",
            },
            {
                "name": "Waste Reports",
                "url": "/api/waste-reports/",
                "methods": ["GET", "POST", "PUT", "PATCH", "DELETE"],
                "description": "Report illegal dumping and waste-related issues.",
            },
            {
                "name": "Waste Bin Analytics",
                "url": "/api/waste-bin-analytics/",
                "methods": ["GET"],
                "description": "Retrieve waste collection analytics.",
            },
            {
                "name": "Collection Routes",
                "url": "/api/collection-routes/",
                "methods": ["GET"],
                "description": "Get optimized waste collection routes.",
            },
        ]

        return context


@api_view(["GET"])
@permission_classes([AllowAny])
def api_root(request):
    """API root endpoint."""

    base = request.build_absolute_uri("/api/")

    return Response(
        {
            "success": True,
            "data": {
                "name": "Sankalan API",
                "version": "2.0.0",
                "description": "Smart Waste Management REST API",
            },
            "links": {
                "self": request.build_absolute_uri(),
                "schema": request.build_absolute_uri("/api/schema/"),
                "docs": request.build_absolute_uri("/api/docs/"),

                "register": f"{base}auth/register/",
                "login": f"{base}auth/login/",
                "refresh": f"{base}auth/refresh/",
                "me": f"{base}auth/me/",

                "waste_bins": f"{base}waste-bins/",
                "bin_requests": f"{base}bin-requests/",
                "waste_reports": f"{base}waste-reports/",
                "waste_bin_analytics": f"{base}waste-bin-analytics/",
                "collection_routes": f"{base}collection-routes/",

                "admin": request.build_absolute_uri("/admin/"),
            },
        }
    )
