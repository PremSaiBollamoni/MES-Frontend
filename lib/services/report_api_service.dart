import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/report.dart';
import 'api_client.dart';

class ReportApiService extends ApiClient {
  static final ReportApiService _instance = ReportApiService._internal();
  factory ReportApiService() => _instance;
  ReportApiService._internal();

  Future<List<ReportSummary>> listReports(ReportType type, {bool forceRefresh = false}) async {
    final response = await cachedGet(Uri.parse("$baseUrl/api/reports?type=${type.apiValue}"), forceRefresh: forceRefresh);
    ensureSuccess(response);
    final List<dynamic> data = json.decode(response.body);
    return data.map((e) => ReportSummary.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Generation runs on the server in the background, because a model call can take minutes.
  /// If the report already exists it comes back at once (200). Otherwise the server accepts
  /// the job (202) and this polls until it is DONE or FAILED.
  Future<ReportSummary> generateReport(
    String date,
    ReportType type, {
    bool force = false,
    ReportPeriod period = ReportPeriod.daily,
  }) async {
    final query = {
      'date': date,
      'type': type.apiValue,
      'period': period.apiValue,
    };
    final uri = Uri.parse("$baseUrl/api/reports/generate")
        .replace(queryParameters: {...query, 'force': '$force'});
    final response = await http.post(uri, headers: headers).timeout(const Duration(seconds: 60));
    ensureSuccess(response);
    ApiClient.invalidateCache();
    if (response.statusCode == 200) {
      return ReportSummary.fromJson(json.decode(response.body) as Map<String, dynamic>);
    }

    final statusUri = Uri.parse("$baseUrl/api/reports/generate/status").replace(queryParameters: query);
    final deadline = DateTime.now().add(const Duration(minutes: 15));
    while (DateTime.now().isBefore(deadline)) {
      await Future.delayed(const Duration(seconds: 4));
      final statusResponse = await http.get(statusUri, headers: headers).timeout(const Duration(seconds: 30));
      ensureSuccess(statusResponse);
      final body = json.decode(statusResponse.body) as Map<String, dynamic>;
      switch (body['state'] as String) {
        case 'DONE':
          ApiClient.invalidateCache();
          return ReportSummary.fromJson(body['report'] as Map<String, dynamic>);
        case 'FAILED':
          throw Exception(body['error'] as String? ?? 'Report generation failed');
        case 'NONE':
          throw Exception('The report did not start. Please try again.');
      }
    }
    throw Exception('The report is still being generated. Check the list again in a few minutes.');
  }

  // Not cached - potentially large binary PDF content, downloaded on explicit tap
  // rather than repeatedly on every screen visit, so caching it isn't worth the
  // in-memory footprint.
  Future<http.Response> downloadReportPdf(int id) async {
    final response = await http
        .get(Uri.parse("$baseUrl/api/reports/$id/pdf"), headers: headers)
        .timeout(const Duration(seconds: 60));
    ensureSuccess(response);
    return response;
  }
}
