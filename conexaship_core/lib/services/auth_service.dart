import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';
import '../models/customer.dart';
import '../models/employee.dart';
import '../utils/constants.dart';

class AuthService {
  final String baseUrl;
  final _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  AuthService({String? customBaseUrl}) : baseUrl = customBaseUrl ?? AppConstants.apiBaseUrl;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
      };

  // Check if app is running on company network (for internal app)
  Future<bool> isOnCompanyNetwork() async {
    try {
      // Get device IP address
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4) {
            final ip = addr.address;
            // Check if IP starts with allowed network prefixes
            for (var allowedNetwork in AppConstants.allowedNetworks) {
              if (ip.startsWith(allowedNetwork)) {
                return true;
              }
            }
          }
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Public customer login
  Future<Map<String, dynamic>> loginCustomer(String email, String password) async {
    try {
      final url = Uri.parse('$baseUrl${ApiEndpoints.login}');
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
          'type': 'customer',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: _tokenKey, value: data['token']);
        await _storage.write(key: _userKey, value: jsonEncode(data['user']));

        return {
          'success': true,
          'token': data['token'],
          'user': Customer.fromJson(data['user']),
        };
      } else {
        return {
          'success': false,
          'error': jsonDecode(response.body)['message'] ?? ErrorMessages.invalidCredentials,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': ErrorMessages.networkError,
      };
    }
  }

  // Employee login (internal)
  Future<Map<String, dynamic>> loginEmployee(String employeeCode, String password) async {
    try {
      // Check if on company network first
      if (!await isOnCompanyNetwork()) {
        return {
          'success': false,
          'error': ErrorMessages.notInCompanyNetwork,
        };
      }

      final url = Uri.parse('$baseUrl${ApiEndpoints.login}');
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({
          'employee_code': employeeCode,
          'password': password,
          'type': 'employee',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: _tokenKey, value: data['token']);
        await _storage.write(key: _userKey, value: jsonEncode(data['user']));

        return {
          'success': true,
          'token': data['token'],
          'user': Employee.fromJson(data['user']),
        };
      } else {
        return {
          'success': false,
          'error': jsonDecode(response.body)['message'] ?? ErrorMessages.invalidCredentials,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': ErrorMessages.networkError,
      };
    }
  }

  // Register new customer
  Future<Map<String, dynamic>> registerCustomer({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final url = Uri.parse('$baseUrl${ApiEndpoints.register}');
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'password': password,
          'phone': phone,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await _storage.write(key: _tokenKey, value: data['token']);
        await _storage.write(key: _userKey, value: jsonEncode(data['user']));

        return {
          'success': true,
          'token': data['token'],
          'user': Customer.fromJson(data['user']),
        };
      } else {
        return {
          'success': false,
          'error': jsonDecode(response.body)['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': ErrorMessages.networkError,
      };
    }
  }

  // Get stored token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Get stored user
  Future<Map<String, dynamic>?> getUser() async {
    final userData = await _storage.read(key: _userKey);
    if (userData != null) {
      return jsonDecode(userData);
    }
    return null;
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // Logout
  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }
}
