from rest_framework import status
from rest_framework.response import Response
from rest_framework.viewsets import ModelViewSet, ViewSet


def enveloped_response(request, data, extra_links=None):
    links = {'self': request.build_absolute_uri()}
    if extra_links:
        links.update(extra_links)
    return Response({'data': data, 'links': links})


class EnvelopedModelViewSet(ModelViewSet):
    """ModelViewSet with enveloped responses, correct status codes, and HATEOAS links."""

    def _envelope_item(self, request, data, extra_links=None):
        links = {'self': request.build_absolute_uri()}
        if extra_links:
            links.update(extra_links)
        if isinstance(data, dict) and 'links' in data:
            links.update(data.pop('links', {}))
        return {'data': data, 'links': links}

    def list(self, request, *args, **kwargs):
        queryset = self.filter_queryset(self.get_queryset())
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)
        serializer = self.get_serializer(queryset, many=True)
        return enveloped_response(request, serializer.data)

    def retrieve(self, request, *args, **kwargs):
        instance = self.get_object()
        serializer = self.get_serializer(instance)
        return Response(self._envelope_item(request, serializer.data))

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        headers = self.get_success_headers(serializer.data)
        return Response(
            self._envelope_item(request, serializer.data),
            status=status.HTTP_201_CREATED,
            headers=headers,
        )

    def update(self, request, *args, **kwargs):
        partial = kwargs.pop('partial', False)
        instance = self.get_object()
        serializer = self.get_serializer(instance, data=request.data, partial=partial)
        serializer.is_valid(raise_exception=True)
        self.perform_update(serializer)
        return Response(self._envelope_item(request, serializer.data))

    def destroy(self, request, *args, **kwargs):
        instance = self.get_object()
        self.perform_destroy(instance)
        return Response(status=status.HTTP_204_NO_CONTENT)


class EnvelopedViewSet(ViewSet):
    """Read-only or custom ViewSet with enveloped responses."""

    def enveloped(self, request, data, extra_links=None):
        return enveloped_response(request, data, extra_links)
