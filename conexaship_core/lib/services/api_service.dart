import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/customer.dart';
import '../models/employee.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/attendance.dart';
import '../utils/constants.dart';

class ApiService {
  final String baseUrl;
  String? _authToken;

  ApiService({String? customBaseUrl}) : baseUrl = customBaseUrl ?? AppConstants.apiBaseUrl;

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  // Helper methods
  Future<http.Response> _get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.get(url, headers: _headers);
  }

  Future<http.Response> _post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.post(url, headers: _headers, body: jsonEncode(body));
  }

  // ignore: unused_element
  Future<http.Response> _put(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.put(url, headers: _headers, body: jsonEncode(body));
  }

  // ignore: unused_element
  Future<http.Response> _delete(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.delete(url, headers: _headers);
  }

  // Product APIs
  Future<List<Product>> getProducts({int? limit, int? offset, String? category}) async {
    String endpoint = ApiEndpoints.products;
    List<String> queryParams = [];

    if (limit != null) queryParams.add('limit=$limit');
    if (offset != null) queryParams.add('offset=$offset');
    if (category != null) queryParams.add('category=$category');

    if (queryParams.isNotEmpty) {
      endpoint += '?${queryParams.join('&')}';
    }

    final response = await _get(endpoint);
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      // El backend devuelve {products: [...], count: 12}
      final List<dynamic> data = responseData['products'] ?? responseData;
      return data.map((json) => Product.fromJson(json)).toList();
    }
    throw Exception('Failed to load products');
  }

  Future<Product> getProduct(int id) async {
    final response = await _get('${ApiEndpoints.products}/$id');
    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load product');
  }

  // Customer APIs
  Future<Customer> createCustomer(Customer customer) async {
    final response = await _post(ApiEndpoints.customers, customer.toJson());
    if (response.statusCode == 201) {
      return Customer.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create customer');
  }

  Future<Customer> getCustomer(int id) async {
    final response = await _get('${ApiEndpoints.customers}/$id');
    if (response.statusCode == 200) {
      return Customer.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load customer');
  }

  // Order APIs
  Future<Order> createOrder(Order order) async {
    final response = await _post(ApiEndpoints.orders, order.toJson());
    if (response.statusCode == 201) {
      return Order.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create order');
  }

  Future<List<Order>> getCustomerOrders(int customerId) async {
    final response = await _get('${ApiEndpoints.customers}/$customerId/orders');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Order.fromJson(json)).toList();
    }
    throw Exception('Failed to load orders');
  }

  // Employee APIs (Internal)
  Future<List<Employee>> getEmployees() async {
    final response = await _get(ApiEndpoints.employees);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Employee.fromJson(json)).toList();
    }
    throw Exception('Failed to load employees');
  }

  Future<Employee> getEmployee(int id) async {
    final response = await _get('${ApiEndpoints.employees}/$id');
    if (response.statusCode == 200) {
      return Employee.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load employee');
  }

  // Attendance APIs (Internal)
  Future<Attendance> clockIn(int employeeId, String location, String ipAddress) async {
    final response = await _post(ApiEndpoints.clockIn, {
      'employee_id': employeeId,
      'location': location,
      'ip_address': ipAddress,
    });
    if (response.statusCode == 201) {
      return Attendance.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to clock in');
  }

  Future<Attendance> clockOut(int attendanceId) async {
    final response = await _post(ApiEndpoints.clockOut, {
      'attendance_id': attendanceId,
    });
    if (response.statusCode == 200) {
      return Attendance.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to clock out');
  }

  Future<List<Attendance>> getEmployeeAttendance(int employeeId,
      {DateTime? startDate, DateTime? endDate}) async {
    String endpoint = '${ApiEndpoints.employees}/$employeeId/attendance';
    List<String> queryParams = [];

    if (startDate != null) queryParams.add('start_date=${startDate.toIso8601String()}');
    if (endDate != null) queryParams.add('end_date=${endDate.toIso8601String()}');

    if (queryParams.isNotEmpty) {
      endpoint += '?${queryParams.join('&')}';
    }

    final response = await _get(endpoint);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Attendance.fromJson(json)).toList();
    }
    throw Exception('Failed to load attendance records');
  }

  // Search
  Future<List<Product>> searchProducts(String query) async {
    final response = await _get('${ApiEndpoints.products}/search?q=$query');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    }
    throw Exception('Failed to search products');
  }
}
