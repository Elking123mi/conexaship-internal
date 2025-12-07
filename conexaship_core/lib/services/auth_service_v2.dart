import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/user.dart';
import 'authenticated_http_client.dart';

class AuthServiceV2 {
  final AuthenticatedHttpClient _client;
  final String baseUrl;

  AuthServiceV2({String? customBaseUrl})
      : baseUrl = customBaseUrl ?? AppConstants.apiBaseUrl,
        _client = AuthenticatedHttpClient(customBaseUrl: customBaseUrl);

  /// Login with username/password
  /// Returns User object on success, throws ApiException on failure
  Future<User> login(String username, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl${ApiEndpoints.authLogin}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': username,
              'password': password,
            }),
          )
          .timeout(Duration(seconds: AppConstants.apiTimeout));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['access_token'] as String;
        final refreshToken = data['refresh_token'] as String;
        final user = User.fromJson(data['user']);

        await _client.saveTokens(accessToken, refreshToken);
        await _client.saveUser(user);

        return user;
      } else {
        final error = jsonDecode(response.body);
        throw ApiException(
          detail: error['detail'] ?? 'Login failed',
          code: error['code'],
          hint: error['hint'],
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        detail: ErrorMessages.networkError,
        code: 'NETWORK_ERROR',
      );
    }
  }

  /// Register new user with allowed_apps
  Future<User> register({
    required String username,
    required String email,
    required String password,
    required List<String> allowedApps,
    List<String>? roles,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl${ApiEndpoints.authRegister}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': username,
              'email': email,
              'password': password,
              'allowed_apps': allowedApps,
              if (roles != null) 'roles': roles,
              if (metadata != null) 'metadata': metadata,
            }),
          )
          .timeout(Duration(seconds: AppConstants.apiTimeout));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return User.fromJson(data['user']);
      } else {
        final error = jsonDecode(response.body);
        throw ApiException(
          detail: error['detail'] ?? 'Registration failed',
          code: error['code'],
          hint: error['hint'],
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        detail: ErrorMessages.networkError,
        code: 'NETWORK_ERROR',
      );
    }
  }

  /// Logout (clears local storage and optionally notifies backend)
  Future<void> logout() async {
    try {
      final refreshToken = await _client.getRefreshToken();
      if (refreshToken != null) {
        await http
            .post(
              Uri.parse('$baseUrl${ApiEndpoints.authLogout}'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'refresh_token': refreshToken}),
            )
            .timeout(const Duration(seconds: 5));
      }
    } catch (e) {
      // Ignore backend errors during logout
    } finally {
      await _client.clearAuth();
    }
  }

  /// Get currently logged-in user
  Future<User?> getCurrentUser() async {
    return await _client.getUser();
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _client.getAccessToken();
    return token != null;
  }

  /// Get the authenticated HTTP client for making API calls
  AuthenticatedHttpClient get httpClient => _client;
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String detail;
  final String? code;
  final String? hint;

  ApiException({
    required this.detail,
    this.code,
    this.hint,
  });

  @override
  String toString() => detail;
}
