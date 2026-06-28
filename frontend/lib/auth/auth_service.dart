import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trash_map/api.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _emailKey = 'user_email';
  static const _nameKey = 'user_name';
  static const _photoKey = 'user_photo';

  String? accessToken;
  String? refreshToken;
  String? currentUserEmail;
  String? currentUserName;
  String? currentUserPhoto;

  bool get isLoggedIn => accessToken != null && accessToken!.isNotEmpty;

  String get displayName {
    final name = currentUserName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return currentUserEmail ?? 'User';
  }

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString(_accessKey);
    refreshToken = prefs.getString(_refreshKey);
    currentUserEmail = prefs.getString(_emailKey);
    currentUserName = prefs.getString(_nameKey);
    currentUserPhoto = prefs.getString(_photoKey);

    if (accessToken != null) {
      final valid = await getCurrentUser();
      if (!valid && refreshToken != null) {
        final refreshed = await refreshSession();
        if (refreshed) await getCurrentUser();
      } else if (!valid) {
        await logout();
      }
    }
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    final http.Response response;
    try {
      response = await http.post(
        apiUri('auth/login/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'username': username, 'password': password}),
      );
    } catch (_) {
      return false;
    }

    if (response.statusCode != 200) return false;

    final data = unwrapMap(response);
    _applyAuthPayload(data);

    await _persistSession();
    return isLoggedIn;
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    String firstName = '',
    String lastName = '',
  }) async {
    final http.Response response;
    try {
      response = await http.post(
        apiUri('auth/register/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
        }),
      );
    } catch (_) {
      return false;
    }

    if (response.statusCode != 201) return false;

    final data = unwrapMap(response);
    _applyAuthPayload(data);

    await _persistSession();
    return isLoggedIn;
  }

  Future<bool> getCurrentUser() async {
    if (accessToken == null) return false;

    final http.Response response;
    try {
      response = await http.get(
        apiUri('auth/me/'),
        headers: jsonHeaders(token: accessToken),
      );
    } catch (_) {
      return false;
    }

    if (response.statusCode != 200) return false;

    final user = unwrapMap(response);
    _applyUser(user);
    await _persistSession();
    return true;
  }

  Future<bool> refreshSession() async {
    if (refreshToken == null) return false;

    final http.Response response;
    try {
      response = await http.post(
        apiUri('auth/refresh/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'refresh': refreshToken}),
      );
    } catch (_) {
      await logout();
      return false;
    }

    if (response.statusCode != 200) {
      await logout();
      return false;
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    accessToken = data['access'] as String?;
    if (data['refresh'] != null) {
      refreshToken = data['refresh'] as String;
    }
    await _persistSession();
    return true;
  }

  Future<void> logout() async {
    accessToken = null;
    refreshToken = null;
    currentUserEmail = null;
    currentUserName = null;
    currentUserPhoto = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessKey);
    await prefs.remove(_refreshKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_photoKey);
  }

  Future<void> _persistSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (accessToken != null) await prefs.setString(_accessKey, accessToken!);
    if (refreshToken != null) await prefs.setString(_refreshKey, refreshToken!);
    if (currentUserEmail != null) {
      await prefs.setString(_emailKey, currentUserEmail!);
    }
    if (currentUserName != null) {
      await prefs.setString(_nameKey, currentUserName!);
    }
    if (currentUserPhoto != null) {
      await prefs.setString(_photoKey, currentUserPhoto!);
    }
  }

  void _applyAuthPayload(Map<String, dynamic> data) {
    final tokens = data['tokens'] as Map<String, dynamic>? ?? {};
    final user = data['user'] as Map<String, dynamic>? ?? {};
    accessToken = tokens['access'] as String?;
    refreshToken = tokens['refresh'] as String?;
    _applyUser(user);
  }

  void _applyUser(Map<String, dynamic> user) {
    currentUserEmail = user['email'] as String? ?? currentUserEmail;
    final firstName = user['first_name']?.toString().trim() ?? '';
    final lastName = user['last_name']?.toString().trim() ?? '';
    final fullName = [
      firstName,
      lastName,
    ].where((part) => part.isNotEmpty).join(' ');
    currentUserName = fullName.isNotEmpty
        ? fullName
        : (user['username'] as String? ?? currentUserName);
    currentUserPhoto =
        'https://api.dicebear.com/7.x/initials/png?seed=${Uri.encodeComponent(displayName)}';
  }
}
