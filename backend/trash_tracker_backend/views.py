from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from django.views.generic import TemplateView


class APILandingView(TemplateView):
    """Landing page for the Trash Tracker API."""
    template_name = 'api_landing.html'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['api_endpoints'] = [
            {
                'name': 'Auth Sessions',
                'url': '/api/auth/sessions/',
                'methods': ['POST'],
                'description': 'Create a JWT session (Google sign-in)',
            },
            {
                'name': 'Auth Me',
                'url': '/api/auth/me/',
                'methods': ['GET'],
                'description': 'Get the authenticated user profile',
            },
            {
                'name': 'Waste Bins',
                'url': '/api/waste-bins/',
                'methods': ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
                'description': 'Manage waste bins; requires Bearer token',
            },
            {
                'name': 'Bin Requests',
                'url': '/api/bin-requests/',
                'methods': ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
                'description': 'Request new waste bins at a location',
            },
            {
                'name': 'Waste Reports',
                'url': '/api/waste-reports/',
                'methods': ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
                'description': 'Community waste incident reports',
            },
            {
                'name': 'Waste Bin Analytics',
                'url': '/api/waste-bin-analytics/',
                'methods': ['GET'],
                'description': 'Aggregated statistics and insights',
            },
            {
                'name': 'Collection Routes',
                'url': '/api/collection-routes/',
                'methods': ['GET'],
                'description': 'Optimized collection routes (query: start_lat, start_lng)',
            },
        ]
        return context


@api_view(['GET'])
@permission_classes([AllowAny])
def api_root(request):
    """API root with HATEOAS links to all resource collections."""
    base = request.build_absolute_uri('/api/')
    return Response({
        'data': {
            'message': 'Welcome to Sankalan API',
            'version': '2.0.0',
        },
        'links': {
            'self': request.build_absolute_uri(),
            'schema': request.build_absolute_uri('/api/schema/'),
            'docs': request.build_absolute_uri('/api/docs/'),
            'auth_sessions': f'{base}auth/sessions/',
            'auth_me': f'{base}auth/me/',
            'waste_bins': f'{base}waste-bins/',
            'bin_requests': f'{base}bin-requests/',
            'waste_reports': f'{base}waste-reports/',
            'waste_bin_analytics': f'{base}waste-bin-analytics/',
            'collection_routes': f'{base}collection-routes/',
            'admin': request.build_absolute_uri('/admin/'),
        },
    })
