import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service_simple.dart';

class ApiClient {
  final AuthService _authService;

  ApiClient(this._authService);

  // ==================== GET AUTORIZADO ====================
  Future<Map<String, dynamic>> get(String url) async {
    final headers = await _getHeaders();
    return await _makeRequest(() => http.get(Uri.parse(url), headers: headers));
  }

  // ==================== POST AUTORIZADO ====================
  Future<Map<String, dynamic>> post(String url, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    return await _makeRequest(() => http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(body),
        ));
  }

  // ==================== PATCH AUTORIZADO ====================
  Future<Map<String, dynamic>> patch(String url, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    return await _makeRequest(() => http.patch(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(body),
        ));
  }

  // ==================== DELETE AUTORIZADO ====================
  Future<Map<String, dynamic>> delete(String url) async {
    final headers = await _getHeaders();
    return await _makeRequest(() => http.delete(Uri.parse(url), headers: headers));
  }

  // ==================== HELPER: HEADERS CON AUTH ====================
  Future<Map<String, String>> _getHeaders() async {
    final accessToken = await _authService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };
  }

  // ==================== INTERCEPTOR: REFRESH SI 401 ====================
  Future<Map<String, dynamic>> _makeRequest(Future<http.Response> Function() request) async {
    http.Response response = await request();

    // Si 401, intentar refresh y reintentar
    if (response.statusCode == 401) {
      await _authService.refreshAccessToken();
      response = await request(); // Reintentar con nuevo token
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }
  }
}
