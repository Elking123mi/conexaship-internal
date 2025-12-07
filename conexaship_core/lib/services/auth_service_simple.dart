import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();

  // Claves para almacenamiento seguro
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';

  // ==================== LOGIN ====================
  Future<Map<String, dynamic>> login(String emailOrUsername, String password) async {
    // Si recibimos un email, extraer el username (parte antes del @)
    String username = emailOrUsername;
    if (emailOrUsername.contains('@')) {
      // Si es un email, usar el email completo como username
      // porque en la BD algunos usuarios tienen email como username
      username = emailOrUsername;
    }

    final response = await http
        .post(
          Uri.parse(ApiConfig.authLoginUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'username': username, 'password': password}),
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Guardar tokens y usuario
      await _storage.write(key: _accessTokenKey, value: data['access_token']);
      await _storage.write(key: _refreshTokenKey, value: data['refresh_token']);
      await _storage.write(key: _userDataKey, value: jsonEncode(data['user']));

      return data;
    } else if (response.statusCode == 401) {
      throw Exception('Usuario o contraseña incorrectos');
    } else {
      throw Exception('Error de conexión: ${response.statusCode}');
    }
  }

  // ==================== REFRESH TOKEN ====================
  Future<void> refreshAccessToken() async {
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    if (refreshToken == null) throw Exception('No refresh token available');

    final response = await http
        .post(
          Uri.parse(ApiConfig.authRefreshUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'refresh_token': refreshToken}),
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _storage.write(key: _accessTokenKey, value: data['access_token']);
      // refresh_token se mantiene igual
    } else {
      // Token expirado o revocado, forzar re-login
      await logout();
      throw Exception('Session expired, please login again');
    }
  }

  // ==================== LOGOUT ====================
  Future<void> logout() async {
    final refreshToken = await _storage.read(key: _refreshTokenKey);

    if (refreshToken != null) {
      try {
        await http
            .post(
              Uri.parse(ApiConfig.authLogoutUrl),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'refresh_token': refreshToken}),
            )
            .timeout(ApiConfig.timeout);
      } catch (e) {
        // Ignorar errores de red, limpiar local de todas formas
      }
    }

    // Limpiar almacenamiento local
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userDataKey);
  }

  // ==================== GET CURRENT USER ====================
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final userData = await _storage.read(key: _userDataKey);
    if (userData == null) return null;
    return jsonDecode(userData);
  }

  // ==================== IS LOGGED IN ====================
  Future<bool> isLoggedIn() async {
    final accessToken = await _storage.read(key: _accessTokenKey);
    return accessToken != null;
  }

  // ==================== GET ACCESS TOKEN ====================
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }
}
