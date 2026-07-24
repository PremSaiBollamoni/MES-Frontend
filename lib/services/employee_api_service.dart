import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bulk_delete_result.dart';
import '../models/bulk_import_result.dart';
import '../models/employee_detail.dart';
import '../models/employee_request.dart';
import '../models/employee_summary.dart';
import '../models/import_from_hrms_request.dart';
import '../models/role_model.dart';
import 'api_client.dart';
import 'auth_session.dart';

class EmployeeApiService extends ApiClient {
  static final EmployeeApiService _instance = EmployeeApiService._internal();
  factory EmployeeApiService() => _instance;
  EmployeeApiService._internal();

  Future<List<RoleModel>> getRoles() async {
    final response = await http
        .get(Uri.parse("$baseUrl/api/roles"), headers: headers)
        .timeout(const Duration(seconds: 8));
    ensureSuccess(response);
    final List<dynamic> data = json.decode(response.body);
    return data.map((e) => RoleModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<EmployeeSummary>> listEmployees() async {
    final response = await http
        .get(Uri.parse("$baseUrl/api/employees"), headers: headers)
        .timeout(const Duration(seconds: 8));
    ensureSuccess(response);
    final List<dynamic> data = json.decode(response.body);
    return data.map((e) => EmployeeSummary.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<EmployeeDetail> getEmployee(int id) async {
    final response = await http
        .get(Uri.parse("$baseUrl/api/employees/$id"), headers: headers)
        .timeout(const Duration(seconds: 8));
    ensureSuccess(response);
    return EmployeeDetail.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  Future<EmployeeDetail> createEmployee(EmployeeCreateRequest request) async {
    final response = await http
        .post(
          Uri.parse("$baseUrl/api/employees"),
          headers: headers,
          body: json.encode(request.toJson()),
        )
        .timeout(const Duration(seconds: 8));
    ensureSuccess(response);
    return EmployeeDetail.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  Future<EmployeeDetail> updateEmployee(int id, EmployeeUpdateRequest request) async {
    final response = await http
        .put(
          Uri.parse("$baseUrl/api/employees/$id"),
          headers: headers,
          body: json.encode(request.toJson()),
        )
        .timeout(const Duration(seconds: 8));
    ensureSuccess(response);
    return EmployeeDetail.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  /// Replaces the employee's full set of roles - the "Assign Roles" action.
  Future<EmployeeDetail> assignRoles(int id, List<String> roleCodes) async {
    final response = await http
        .put(
          Uri.parse("$baseUrl/api/employees/$id/roles"),
          headers: headers,
          body: json.encode({'roleCodes': roleCodes}),
        )
        .timeout(const Duration(seconds: 8));
    ensureSuccess(response);
    return EmployeeDetail.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  Future<void> deactivateEmployee(int id) async {
    final response = await http
        .patch(Uri.parse("$baseUrl/api/employees/$id/deactivate"), headers: headers)
        .timeout(const Duration(seconds: 8));
    ensureSuccess(response);
  }

  Future<void> reactivateEmployee(int id) async {
    final response = await http
        .patch(Uri.parse("$baseUrl/api/employees/$id/reactivate"), headers: headers)
        .timeout(const Duration(seconds: 8));
    ensureSuccess(response);
  }

  Future<void> deleteEmployee(int id) async {
    final response = await http
        .delete(Uri.parse("$baseUrl/api/employees/$id"), headers: headers)
        .timeout(const Duration(seconds: 8));
    ensureSuccess(response);
  }

  Future<BulkDeleteResult> bulkDeleteEmployees(List<int> ids) async {
    final response = await http
        .post(
          Uri.parse("$baseUrl/api/employees/bulk-delete"),
          headers: headers,
          body: json.encode({'ids': ids}),
        )
        .timeout(const Duration(seconds: 20));
    ensureSuccess(response);
    return BulkDeleteResult.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  Future<EmployeeDetail> importFromHrms(ImportFromHrmsRequest request) async {
    final response = await http
        .post(
          Uri.parse("$baseUrl/api/employees/import-from-hrms"),
          headers: headers,
          body: json.encode(request.toJson()),
        )
        .timeout(const Duration(seconds: 8));
    ensureSuccess(response);
    return EmployeeDetail.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  /// One-click "sync all" - imports every unlinked HRMS employee under [defaultRoleCode].
  /// [defaultDepartment], if given, overrides HRMS's own department for every imported
  /// employee; leave it null to keep each employee's HRMS department as-is.
  Future<BulkImportResult> importAllFromHrms(String defaultRoleCode, {String? defaultDepartment}) async {
    final response = await http
        .post(
          Uri.parse("$baseUrl/api/employees/import-from-hrms/bulk"),
          headers: headers,
          body: json.encode({'defaultRoleCode': defaultRoleCode, 'defaultDepartment': defaultDepartment}),
        )
        .timeout(const Duration(seconds: 30));
    ensureSuccess(response);
    return BulkImportResult.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  /// Uploads a photo for HRMS face-recognition enrollment. Fingerprint/RFID can't be
  /// done this way - those require physical presence at the biometric device.
  Future<void> enrollFace(int id, List<int> fileBytes, String filename) async {
    final request = http.MultipartRequest("POST", Uri.parse("$baseUrl/api/employees/$id/face"));
    final token = AuthSession().token;
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.files.add(http.MultipartFile.fromBytes('file', fileBytes, filename: filename));
    final streamedResponse = await request.send().timeout(const Duration(seconds: 20));
    final response = await http.Response.fromStream(streamedResponse);
    ensureSuccess(response);
  }
}
