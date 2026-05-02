from django.views.generic import TemplateView
from rest_framework.decorators import api_view
from rest_framework.response import Response


class APILandingView(TemplateView):
    """Landing page for the Trash Tracker API"""
    template_name = 'api_landing.html'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['api_endpoints'] = [
            {
                'name': 'Waste Bins',
                'url': '/api/wastebins/',
                'methods': ['GET', 'POST', 'PUT', 'DELETE'],
                'description': 'Manage waste bins and their fill levels'
            },
            {
                'name': 'Requests',
                'url': '/api/requests/',
                'methods': ['GET', 'POST', 'PUT', 'DELETE'],
                'description': 'Handle waste collection requests'
            },
            {
                'name': 'Admin Notifications',
                'url': '/api/admin-notifications/',
                'methods': ['GET', 'POST', 'PUT', 'DELETE'],
                'description': 'Manage admin notifications for full bins'
            },
            {
                'name': 'Report Waste',
                'url': '/api/report-waste/',
                'methods': ['GET', 'POST', 'PUT', 'DELETE'],
                'description': 'Report waste incidents'
            },
            {
                'name': 'Waste Bin Analytics',
                'url': '/api/waste-bin-analytics/',
                'methods': ['GET'],
                'description': 'Get statistics and analytics about waste bins'
            },
        ]
        return context


@api_view(['GET'])
def api_root(request):
    """API Root endpoint providing overview of available endpoints"""
    return Response({
        'message': 'Welcome to Trash Tracker API',
        'version': '1.0.0',
        'endpoints': {
            'admin': request.build_absolute_uri('/admin/'),
            'api_docs': request.build_absolute_uri('/api/'),
            'wastebins': request.build_absolute_uri('/api/wastebins/'),
            'requests': request.build_absolute_uri('/api/requests/'),
            'admin_notifications': request.build_absolute_uri('/api/admin-notifications/'),
            'report_waste': request.build_absolute_uri('/api/report-waste/'),
            'analytics': request.build_absolute_uri('/api/waste-bin-analytics/'),
        }
    })
