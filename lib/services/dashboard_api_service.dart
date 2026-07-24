import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dashboard_summary.dart';
import 'api_client.dart';

class DashboardApiService extends ApiClient {
  static final DashboardApiService _instance = DashboardApiService._internal();
  factory DashboardApiService() => _instance;
  DashboardApiService._internal();

  Future<DashboardSummary> getSummary() async {
    final response = await http
        .get(Uri.parse("$baseUrl/api/dashboard/summary"), headers: headers)
        .timeout(const Duration(seconds: 8));
    ensureSuccess(response);
    return DashboardSummary.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }
}
