import '../services/auth_service_simple.dart';
import '../services/api_client.dart';
import '../config/api_config.dart';

class TripsService {
  final _apiClient = ApiClient(AuthService());

  Future<List<dynamic>> getTrips() async {
    final response = await _apiClient.get(ApiConfig.tripsUrl);
    return response['trips'];
  }

  Future<Map<String, dynamic>> createTrip(Map<String, dynamic> tripData) async {
    return await _apiClient.post(ApiConfig.tripsUrl, tripData);
  }

  Future<Map<String, dynamic>> updateTrip(int tripId, Map<String, dynamic> updates) async {
    return await _apiClient.patch('${ApiConfig.tripsUrl}/$tripId', updates);
  }

  Future<void> deleteTrip(int tripId) async {
    await _apiClient.delete('${ApiConfig.tripsUrl}/$tripId');
  }
}
