import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/report.dart';
import 'api_client.dart';

class ReportApiService extends ApiClient {
  static final ReportApiService _instance = ReportApiService._internal();
  factory ReportApiService() => _instance;
  ReportApiService._internal();

  Future<List<ReportSummary>> listReports(ReportType type) async {
    final response = await http
        .get(Uri.parse("$baseUrl/api/reports?type=${type.apiValue}"), headers: headers)
        .timeout(const Duration(seconds: 10));
    ensureSuccess(response);
    final List<dynamic> data = json.decode(response.body);
    return data.map((e) => ReportSummary.fromJson(e as Map<String, dynamic>)).toList();
  }

  // Report generation is a real LLM call at high effort and can genuinely
  // take 30-90+ seconds, hence the generous 3 minute timeout below.
  Future<ReportSummary> generateReport(String date, ReportType type, {bool force = false}) async {
    final response = await http
        .post(Uri.parse("$baseUrl/api/reports/generate?date=$date&type=${type.apiValue}&force=$force"), headers: headers)
        .timeout(const Duration(minutes: 3));
    ensureSuccess(response);
    return ReportSummary.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  Future<http.Response> downloadReportPdf(int id) async {
    final response = await http
        .get(Uri.parse("$baseUrl/api/reports/$id/pdf"), headers: headers)
        .timeout(const Duration(seconds: 30));
    ensureSuccess(response);
    return response;
  }
}
