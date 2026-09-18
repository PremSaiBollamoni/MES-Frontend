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

  // Report generation is a real LLM call at high effort and can genuinely
  // take 30-90+ seconds, hence the generous 3 minute timeout below.
  Future<ReportSummary> generateReport(
    String date,
    ReportType type, {
    bool force = false,
    ReportPeriod period = ReportPeriod.daily,
    ReportProvider? provider,
    String? model,
  }) async {
    final uri = Uri.parse("$baseUrl/api/reports/generate").replace(queryParameters: {
      'date': date,
      'type': type.apiValue,
      'period': period.apiValue,
      'force': '$force',
      if (provider != null) 'provider': provider.apiValue,
      if (provider == ReportProvider.openRouter && model != null && model.isNotEmpty) 'model': model,
    });
    final response = await http.post(uri, headers: headers).timeout(const Duration(minutes: 3));
    ensureSuccess(response);
    ApiClient.invalidateCache();
    return ReportSummary.fromJson(json.decode(response.body) as Map<String, dynamic>);
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
