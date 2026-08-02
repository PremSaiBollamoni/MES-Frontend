import 'dart:convert';
import '../models/dashboard_summary.dart';
import 'api_client.dart';

class DashboardApiService extends ApiClient {
  static final DashboardApiService _instance = DashboardApiService._internal();
  factory DashboardApiService() => _instance;
  DashboardApiService._internal();

  Future<DashboardSummary> getSummary({bool forceRefresh = false}) async {
    final response = await cachedGet(Uri.parse("$baseUrl/api/dashboard/summary"), forceRefresh: forceRefresh);
    ensureSuccess(response);
    return DashboardSummary.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }
}
