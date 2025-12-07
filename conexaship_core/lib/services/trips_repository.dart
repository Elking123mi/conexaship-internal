import 'dart:convert';
import '../services/authenticated_http_client.dart';
import '../services/auth_service_v2.dart';
import '../utils/constants.dart';

class Trip {
  final int? id;
  final String from;
  final String to;
  final DateTime? departureTime;
  final DateTime? arrivalTime;
  final String status;
  final Map<String, dynamic>? metadata;

  Trip({
    this.id,
    required this.from,
    required this.to,
    this.departureTime,
    this.arrivalTime,
    required this.status,
    this.metadata,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as int?,
      from: json['from'] as String,
      to: json['to'] as String,
      departureTime: json['departure_time'] != null ? DateTime.parse(json['departure_time']) : null,
      arrivalTime: json['arrival_time'] != null ? DateTime.parse(json['arrival_time']) : null,
      status: json['status'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'from': from,
      'to': to,
      if (departureTime != null) 'departure_time': departureTime!.toIso8601String(),
      if (arrivalTime != null) 'arrival_time': arrivalTime!.toIso8601String(),
      'status': status,
      if (metadata != null) 'metadata': metadata,
    };
  }
}

class TripsRepository {
  final AuthenticatedHttpClient _client;

  TripsRepository(this._client);

  Future<List<Trip>> getTrips({String? from, String? to}) async {
    String path = ApiEndpoints.trips;
    List<String> queryParams = [];

    if (from != null) queryParams.add('from=$from');
    if (to != null) queryParams.add('to=$to');

    if (queryParams.isNotEmpty) {
      path += '?${queryParams.join('&')}';
    }

    final response = await _client.get(path);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Trip.fromJson(json)).toList();
    } else {
      final error = jsonDecode(response.body);
      throw ApiException(
        detail: error['detail'] ?? 'Failed to load trips',
        code: error['code'],
        hint: error['hint'],
      );
    }
  }

  Future<Trip> createTrip(Trip trip) async {
    final response = await _client.post(
      ApiEndpoints.trips,
      trip.toJson(),
    );

    if (response.statusCode == 201) {
      return Trip.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw ApiException(
        detail: error['detail'] ?? 'Failed to create trip',
        code: error['code'],
        hint: error['hint'],
      );
    }
  }

  Future<Trip> updateTrip(int id, Map<String, dynamic> updates) async {
    final response = await _client.patch(
      '${ApiEndpoints.trips}/$id',
      updates,
    );

    if (response.statusCode == 200) {
      return Trip.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw ApiException(
        detail: error['detail'] ?? 'Failed to update trip',
        code: error['code'],
        hint: error['hint'],
      );
    }
  }
}
