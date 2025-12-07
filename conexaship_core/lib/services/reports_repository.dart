import 'dart:convert';
import '../services/authenticated_http_client.dart';
import '../services/auth_service_v2.dart';
import '../utils/constants.dart';

class ReportStatus {
  final String jobId;
  final String status;
  final String? downloadUrl;
  final String? error;

  ReportStatus({
    required this.jobId,
    required this.status,
    this.downloadUrl,
    this.error,
  });

  factory ReportStatus.fromJson(Map<String, dynamic> json) {
    return ReportStatus(
      jobId: json['job_id'] as String,
      status: json['status'] as String,
      downloadUrl: json['download_url'] as String?,
      error: json['error'] as String?,
    );
  }

  bool get isDone => status == 'done';
  bool get isFailed => status == 'failed';
  bool get isPending => status == 'pending' || status == 'processing';
}

class ReportsRepository {
  final AuthenticatedHttpClient _client;

  ReportsRepository(this._client);

  /// Export report with filters - returns job_id for polling
  Future<String> exportReport(Map<String, dynamic> filters) async {
    final response = await _client.post(
      ApiEndpoints.reportsExport,
      filters,
    );

    if (response.statusCode == 200 || response.statusCode == 202) {
      final data = jsonDecode(response.body);
      return data['job_id'] as String;
    } else {
      final error = jsonDecode(response.body);
      throw ApiException(
        detail: error['detail'] ?? 'Failed to export report',
        code: error['code'],
        hint: error['hint'],
      );
    }
  }

  /// Check report generation status
  Future<ReportStatus> getReportStatus(String jobId) async {
    final response = await _client.get(
      ApiEndpoints.reportsStatus(jobId),
    );

    if (response.statusCode == 200) {
      return ReportStatus.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw ApiException(
        detail: error['detail'] ?? 'Failed to get report status',
        code: error['code'],
        hint: error['hint'],
      );
    }
  }

  /// Poll report until done or failed (with delay between checks)
  Future<ReportStatus> pollReportUntilDone(
    String jobId, {
    Duration pollInterval = const Duration(seconds: 3),
    Duration? timeout,
  }) async {
    final startTime = DateTime.now();

    while (true) {
      final status = await getReportStatus(jobId);

      if (status.isDone || status.isFailed) {
        return status;
      }

      if (timeout != null && DateTime.now().difference(startTime) > timeout) {
        throw ApiException(
          detail: 'Report generation timed out',
          code: 'TIMEOUT',
        );
      }

      await Future.delayed(pollInterval);
    }
  }
}
