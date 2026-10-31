import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/factory_detail.dart';
import '../models/factory_kpi_summary.dart';
import 'api_client.dart';

/// Factory (company/tenant) management - SUPER_ADMIN only on the backend.
/// Every endpoint here 401s for a non-super-admin token, enforced server-side.
class FactoryApiService extends ApiClient {
  static final FactoryApiService _instance = FactoryApiService._internal();
  factory FactoryApiService() => _instance;
  FactoryApiService._internal();

  Future<List<FactoryDetail>> listFactories({bool forceRefresh = false}) async {
    final response = await cachedGet(Uri.parse("$baseUrl/api/factories"), forceRefresh: forceRefresh);
    ensureSuccess(response);
    final List<dynamic> data = json.decode(response.body);
    return data.map((e) => FactoryDetail.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<FactoryDetail> getFactory(int id, {bool forceRefresh = false}) async {
    final response = await cachedGet(Uri.parse("$baseUrl/api/factories/$id"), forceRefresh: forceRefresh);
    ensureSuccess(response);
    return FactoryDetail.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  Future<FactoryDetail> createFactory(FactoryCreateRequest request) async {
    final response = await http
        .post(Uri.parse("$baseUrl/api/factories"), headers: headers, body: json.encode(request.toJson()))
        .timeout(const Duration(seconds: 60));
    ensureSuccess(response);
    ApiClient.invalidateCache();
    return FactoryDetail.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  Future<FactoryDetail> updateFactory(int id, FactoryUpdateRequest request) async {
    final response = await http
        .put(Uri.parse("$baseUrl/api/factories/$id"), headers: headers, body: json.encode(request.toJson()))
        .timeout(const Duration(seconds: 60));
    ensureSuccess(response);
    ApiClient.invalidateCache();
    return FactoryDetail.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  Future<FactoryDetail> updateHrmsConfig(int id, HrmsFactoryConfig config) async {
    final response = await http
        .post(Uri.parse("$baseUrl/api/factories/$id/hrms-config"), headers: headers, body: json.encode(config.toJson()))
        .timeout(const Duration(seconds: 60));
    ensureSuccess(response);
    ApiClient.invalidateCache();
    return FactoryDetail.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  /// Tries logging into HRMS with these exact credentials and fetching one real page
  /// of employees - nothing is saved. Lets the admin catch a wrong URL/password before
  /// committing it, rather than discovering it later when a sync silently fails.
  Future<HrmsConnectionTestResult> testHrmsConnection(HrmsFactoryConfig config) async {
    final response = await http
        .post(Uri.parse("$baseUrl/api/factories/hrms-test-connection"), headers: headers, body: json.encode(config.toJson()))
        .timeout(const Duration(seconds: 30));
    ensureSuccess(response);
    return HrmsConnectionTestResult.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  /// Renumbers every employee in this factory to its factory-code prefix (GTGBZA001,
  /// GTGBZA002, ...). Changes real login usernames - the result must be shown to the
  /// admin so affected employees can be told their new username.
  Future<List<UsernameChange>> fixUsernames(int factoryId) async {
    final response = await http
        .post(Uri.parse("$baseUrl/api/factories/$factoryId/fix-usernames"), headers: headers)
        .timeout(const Duration(seconds: 60));
    ensureSuccess(response);
    final List<dynamic> data = json.decode(response.body);
    ApiClient.invalidateCache();
    return data.map((e) => UsernameChange.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Cross-factory KPI overview - workforce, today's production, today's attendance,
  /// month-to-date payroll, one row per factory.
  Future<List<FactoryKpiSummary>> getKpiOverview({bool forceRefresh = false}) async {
    final response = await cachedGet(Uri.parse("$baseUrl/api/factories/kpi-overview"), forceRefresh: forceRefresh);
    ensureSuccess(response);
    final List<dynamic> data = json.decode(response.body);
    return data.map((e) => FactoryKpiSummary.fromJson(e as Map<String, dynamic>)).toList();
  }
}

class UsernameChange {
  final int employeeId;
  final String employeeName;
  final String oldUsername;
  final String newUsername;

  const UsernameChange({
    required this.employeeId,
    required this.employeeName,
    required this.oldUsername,
    required this.newUsername,
  });

  factory UsernameChange.fromJson(Map<String, dynamic> json) {
    return UsernameChange(
      employeeId: json['employeeId'] as int,
      employeeName: json['employeeName'] as String,
      oldUsername: json['oldUsername'] as String,
      newUsername: json['newUsername'] as String,
    );
  }
}

class HrmsConnectionTestResult {
  final bool success;
  final String message;
  final int employeeCount;

  const HrmsConnectionTestResult({required this.success, required this.message, required this.employeeCount});

  factory HrmsConnectionTestResult.fromJson(Map<String, dynamic> json) {
    return HrmsConnectionTestResult(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      employeeCount: json['employeeCount'] as int? ?? 0,
    );
  }
}
