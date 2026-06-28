import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:trash_map/auth/auth_service.dart';

const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://sankalan.onrender.com/api/',
);

String apiPath(String path) {
  final normalized = apiBaseUrl.endsWith('/') ? apiBaseUrl : '$apiBaseUrl/';
  return '$normalized${path.replaceFirst(RegExp(r'^/+'), '')}';
}

Uri apiUri(String path) => Uri.parse(apiPath(path));

Map<String, String> jsonHeaders({String? token}) {
  final authToken = token ?? AuthService.instance.accessToken;
  return {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (authToken != null) 'Authorization': 'Bearer $authToken',
  };
}

dynamic unwrapEnvelope(http.Response response) {
  if (response.body.isEmpty) return null;
  final decoded = json.decode(response.body);
  if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
    return decoded['data'];
  }
  return decoded;
}

List<dynamic> unwrapList(http.Response response) {
  final data = unwrapEnvelope(response);
  if (data is List) return data;
  return [];
}

Map<String, dynamic> unwrapMap(http.Response response) {
  final data = unwrapEnvelope(response);
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return Map<String, dynamic>.from(data);
  return {};
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

Future<http.Response> apiGet(String path) => ApiClient.get(path);

Future<http.Response> apiPost(String path, {Object? body}) =>
    ApiClient.post(path, body: body);

Future<http.Response> apiPatch(String path, {Object? body}) =>
    ApiClient.patch(path, body: body);

Future<http.Response> apiPut(String path, {Object? body}) =>
    ApiClient.put(path, body: body);

Future<http.Response> apiDelete(String path) => ApiClient.delete(path);

class ApiClient {
  static Future<http.Response> get(String path) =>
      _send(() => http.get(apiUri(path), headers: jsonHeaders()));

  static Future<http.Response> post(String path, {Object? body}) => _send(
        () => http.post(apiUri(path), headers: jsonHeaders(), body: body),
      );

  static Future<http.Response> patch(String path, {Object? body}) => _send(
        () => http.patch(apiUri(path), headers: jsonHeaders(), body: body),
      );

  static Future<http.Response> put(String path, {Object? body}) => _send(
        () => http.put(apiUri(path), headers: jsonHeaders(), body: body),
      );

  static Future<http.Response> delete(String path) =>
      _send(() => http.delete(apiUri(path), headers: jsonHeaders()));

  static Future<http.Response> _send(
    Future<http.Response> Function() request,
  ) async {
    var response = await request();
    if (response.statusCode == 401 &&
        AuthService.instance.refreshToken != null) {
      final refreshed = await AuthService.instance.refreshSession();
      if (refreshed) {
        response = await request();
      }
    }
    return response;
  }

  static void ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    final body = unwrapEnvelope(response);
    final detail = body is Map ? (body['detail'] ?? body['title']) : null;
    throw ApiException(
      response.statusCode,
      detail?.toString() ?? 'Request failed (${response.statusCode})',
    );
  }
}
