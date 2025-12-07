import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import 'auth_service_simple.dart';

class UserService {
  final AuthService _authService = AuthService();

  /// Registro público (sin autenticación)
  Future<Map<String, dynamic>> registerUser({
    required String username,
    required String email,
    required String password,
    String name = '',
    List<String> roles = const ["operator"],
    List<String> allowedApps = const ["conexaship"],
  }) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': username,
            'email': email,
            'password': password,
            'name': name,
            'roles': roles,
            'allowed_apps': allowedApps,
          }),
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 400) {
      throw Exception('Usuario o email ya existe');
    } else {
      throw Exception('Error al registrar: ${response.statusCode}');
    }
  }

  /// Crear usuario como admin (requiere autenticación)
  Future<Map<String, dynamic>> createUserAsAdmin({
    required String username,
    required String email,
    required String password,
    String name = '',
    List<String> roles = const ["operator"],
    List<String> allowedApps = const ["conexaship"],
  }) async {
    final accessToken = await _authService.getAccessToken();
    if (accessToken == null) throw Exception('No autenticado');

    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/api/v1/users'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({
            'username': username,
            'email': email,
            'password': password,
            'name': name,
            'roles': roles,
            'allowed_apps': allowedApps,
          }),
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 403) {
      throw Exception('Se requiere rol de admin');
    } else if (response.statusCode == 400) {
      throw Exception('Usuario o email ya existe');
    } else {
      throw Exception('Error al crear usuario: ${response.statusCode}');
    }
  }

  /// Listar todos los usuarios
  Future<List<dynamic>> listUsers() async {
    final accessToken = await _authService.getAccessToken();
    if (accessToken == null) throw Exception('No autenticado');

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/v1/users'),
      headers: {'Authorization': 'Bearer $accessToken'},
    ).timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al listar usuarios: ${response.statusCode}');
    }
  }

  /// Obtener detalle de un usuario
  Future<Map<String, dynamic>> getUser(int userId) async {
    final accessToken = await _authService.getAccessToken();
    if (accessToken == null) throw Exception('No autenticado');

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/v1/users/$userId'),
      headers: {'Authorization': 'Bearer $accessToken'},
    ).timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Usuario no encontrado');
    } else {
      throw Exception('Error al obtener usuario: ${response.statusCode}');
    }
  }
}
