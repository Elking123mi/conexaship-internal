import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

/// Service to communicate with SQL Server through a REST API
/// You'll need to create a backend API (Node.js, Python, .NET) that connects to SQL Server
class DatabaseService {
  final String baseUrl;

  DatabaseService({String? customBaseUrl}) : baseUrl = customBaseUrl ?? AppConstants.apiBaseUrl;

  // Generic request method
  Future<Map<String, dynamic>> _request({
    required String endpoint,
    required String method,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final defaultHeaders = {
        'Content-Type': 'application/json',
        ...?headers,
      };

      http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(url, headers: defaultHeaders);
          break;
        case 'POST':
          response = await http.post(
            url,
            headers: defaultHeaders,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            url,
            headers: defaultHeaders,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(url, headers: defaultHeaders);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'error': jsonDecode(response.body)['message'] ?? 'Unknown error',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'statusCode': 0,
      };
    }
  }

  // Query methods
  Future<Map<String, dynamic>> query(String sql, [List<dynamic>? params]) async {
    return await _request(
      endpoint: '/query',
      method: 'POST',
      body: {
        'sql': sql,
        'params': params,
      },
    );
  }

  Future<Map<String, dynamic>> execute(String sql, [List<dynamic>? params]) async {
    return await _request(
      endpoint: '/execute',
      method: 'POST',
      body: {
        'sql': sql,
        'params': params,
      },
    );
  }

  // Generic CRUD operations
  Future<Map<String, dynamic>> getAll(String table) async {
    return await _request(
      endpoint: '/table/$table',
      method: 'GET',
    );
  }

  Future<Map<String, dynamic>> getById(String table, int id) async {
    return await _request(
      endpoint: '/table/$table/$id',
      method: 'GET',
    );
  }

  Future<Map<String, dynamic>> insert(String table, Map<String, dynamic> data) async {
    return await _request(
      endpoint: '/table/$table',
      method: 'POST',
      body: data,
    );
  }

  Future<Map<String, dynamic>> update(String table, int id, Map<String, dynamic> data) async {
    return await _request(
      endpoint: '/table/$table/$id',
      method: 'PUT',
      body: data,
    );
  }

  Future<Map<String, dynamic>> delete(String table, int id) async {
    return await _request(
      endpoint: '/table/$table/$id',
      method: 'DELETE',
    );
  }

  // Test connection
  Future<bool> testConnection() async {
    try {
      final response = await _request(
        endpoint: '/health',
        method: 'GET',
      );
      return response['success'] == true;
    } catch (e) {
      return false;
    }
  }
}
