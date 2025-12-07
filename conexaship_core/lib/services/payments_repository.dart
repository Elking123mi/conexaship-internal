import 'dart:convert';
import '../services/authenticated_http_client.dart';
import '../services/auth_service_v2.dart';
import '../utils/constants.dart';

class Payment {
  final int? id;
  final int orderId;
  final double amount;
  final String status;
  final String? paymentMethod;
  final DateTime? createdAt;

  Payment({
    this.id,
    required this.orderId,
    required this.amount,
    required this.status,
    this.paymentMethod,
    this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as int?,
      orderId: json['order_id'] as int,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      paymentMethod: json['payment_method'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'order_id': orderId,
      'amount': amount,
      'status': status,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}

class PaymentsRepository {
  final AuthenticatedHttpClient _client;

  PaymentsRepository(this._client);

  Future<List<Payment>> getPayments({int? orderId, String? status}) async {
    String path = ApiEndpoints.payments;
    List<String> queryParams = [];

    if (orderId != null) queryParams.add('order_id=$orderId');
    if (status != null) queryParams.add('status=$status');

    if (queryParams.isNotEmpty) {
      path += '?${queryParams.join('&')}';
    }

    final response = await _client.get(path);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Payment.fromJson(json)).toList();
    } else {
      final error = jsonDecode(response.body);
      throw ApiException(
        detail: error['detail'] ?? 'Failed to load payments',
        code: error['code'],
        hint: error['hint'],
      );
    }
  }
}
