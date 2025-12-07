import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../services/authenticated_http_client.dart';
import '../services/auth_service_v2.dart';
import '../utils/constants.dart';

class PresignedUrlResponse {
  final String putUrl;
  final String getUrl;
  final String fileId;

  PresignedUrlResponse({
    required this.putUrl,
    required this.getUrl,
    required this.fileId,
  });

  factory PresignedUrlResponse.fromJson(Map<String, dynamic> json) {
    return PresignedUrlResponse(
      putUrl: json['put_url'] as String,
      getUrl: json['get_url'] as String,
      fileId: json['file_id'] as String,
    );
  }
}

class StorageRepository {
  final AuthenticatedHttpClient _client;

  StorageRepository(this._client);

  /// Get presigned URL for upload
  Future<PresignedUrlResponse> getPresignedUrl({
    required String fileName,
    required String contentType,
  }) async {
    final response = await _client.post(
      ApiEndpoints.storagePresign,
      {
        'file_name': fileName,
        'content_type': contentType,
      },
    );

    if (response.statusCode == 200) {
      return PresignedUrlResponse.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw ApiException(
        detail: error['detail'] ?? 'Failed to get presigned URL',
        code: error['code'],
        hint: error['hint'],
      );
    }
  }

  /// Upload file using presigned URL
  Future<void> uploadFile({
    required String presignedUrl,
    required Uint8List fileBytes,
    required String contentType,
  }) async {
    final response = await http
        .put(
          Uri.parse(presignedUrl),
          headers: {
            'Content-Type': contentType,
          },
          body: fileBytes,
        )
        .timeout(Duration(seconds: AppConstants.apiTimeout * 2));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw ApiException(
        detail: 'Failed to upload file',
        code: 'UPLOAD_ERROR',
      );
    }
  }

  /// Complete flow: get presigned URL and upload
  Future<PresignedUrlResponse> uploadFileComplete({
    required String fileName,
    required String contentType,
    required Uint8List fileBytes,
  }) async {
    final presignedResponse = await getPresignedUrl(
      fileName: fileName,
      contentType: contentType,
    );

    await uploadFile(
      presignedUrl: presignedResponse.putUrl,
      fileBytes: fileBytes,
      contentType: contentType,
    );

    return presignedResponse;
  }
}
