"""
RFC 7807 Problem Details for HTTP APIs exception handling.
https://datatracker.ietf.org/doc/html/rfc7807
"""
from rest_framework.views import exception_handler

PROBLEM_TYPE_BASE = 'https://sankalan.dev/problems'

STATUS_TITLES = {
    400: 'Bad Request',
    401: 'Unauthorized',
    403: 'Forbidden',
    404: 'Not Found',
    405: 'Method Not Allowed',
    409: 'Conflict',
    422: 'Unprocessable Entity',
    500: 'Internal Server Error',
}


def _extract_detail(data):
    if isinstance(data, dict):
        if 'detail' in data:
            detail = data['detail']
            return str(detail) if not isinstance(detail, str) else detail
        if len(data) == 1:
            key = next(iter(data))
            val = data[key]
            if isinstance(val, list) and val:
                return f'{key}: {val[0]}'
    if isinstance(data, list) and data:
        return str(data[0])
    return STATUS_TITLES.get(400, 'An error occurred')


def problem_details_exception_handler(exc, context):
    response = exception_handler(exc, context)
    if response is None:
        return None

    request = context.get('request')
    instance = request.build_absolute_uri() if request else ''
    status_code = response.status_code

    problem = {
        'type': f'{PROBLEM_TYPE_BASE}/{status_code}',
        'title': STATUS_TITLES.get(status_code, 'Error'),
        'status': status_code,
        'detail': _extract_detail(response.data),
        'instance': instance,
    }

    if isinstance(response.data, dict) and 'detail' not in response.data:
        problem['errors'] = response.data

    response.data = problem
    response['Content-Type'] = 'application/problem+json'
    return response
