import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';
import '../models/user.dart';

class AuthenticatedHttpClient {
  final String baseUrl;
  final _storage = const FlutterSecureStorage();
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';

  AuthenticatedHttpClient({String? customBaseUrl})
      : baseUrl = customBaseUrl ?? AppConstants.apiBaseUrl;

  // Token management
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<void> saveUser(User user) async {
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }

  Future<User?> getUser() async {
    final userData = await _storage.read(key: _userKey);
    if (userData == null) return null;
    return User.fromJson(jsonDecode(userData));
  }

  Future<void> clearAuth() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userKey);
  }

  // Refresh token logic
  Future<bool> refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl${ApiEndpoints.authRefresh}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveTokens(data['access_token'], data['refresh_token']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Authorized requests with auto-refresh on 401
  Future<http.Response> get(String path) async {
    return _authorizedRequest(() async {
      final token = await getAccessToken();
      return http.get(
        Uri.parse('$baseUrl$path'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: AppConstants.apiTimeout));
    });
  }

  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    return _authorizedRequest(() async {
      final token = await getAccessToken();
      return http
          .post(
            Uri.parse('$baseUrl$path'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(Duration(seconds: AppConstants.apiTimeout));
    });
  }

  Future<http.Response> patch(String path, Map<String, dynamic> body) async {
    return _authorizedRequest(() async {
      final token = await getAccessToken();
      return http
          .patch(
            Uri.parse('$baseUrl$path'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(Duration(seconds: AppConstants.apiTimeout));
    });
  }

  Future<http.Response> put(String path, Map<String, dynamic> body) async {
    return _authorizedRequest(() async {
      final token = await getAccessToken();
      return http
          .put(
            Uri.parse('$baseUrl$path'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(Duration(seconds: AppConstants.apiTimeout));
    });
  }

  Future<http.Response> delete(String path) async {
    return _authorizedRequest(() async {
      final token = await getAccessToken();
      return http.delete(
        Uri.parse('$baseUrl$path'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: AppConstants.apiTimeout));
    });
  }

  // Core retry logic with token refresh
  Future<http.Response> _authorizedRequest(
    Future<http.Response> Function() request,
  ) async {
    http.Response response = await request();

    if (response.statusCode == 401) {
      // Try to refresh token
      final refreshed = await refreshAccessToken();
      if (refreshed) {
        // Retry request with new token
        response = await request();
      } else {
        // Refresh failed, clear auth
        await clearAuth();
      }
    }

    return response;
  }
}
