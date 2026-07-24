import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bulk_delete_result.dart';
import '../models/role_detail.dart';
import '../models/role_request.dart';
import 'api_client.dart';

class RoleApiService extends ApiClient {
  static final RoleApiService _instance = RoleApiService._internal();
  factory RoleApiService() => _instance;
  RoleApiService._internal();

  Future<List<String>> getActivityCatalog() async {
    final response = await http
        .get(Uri.parse("$baseUrl/api/roles/manage/activities"), headers: headers)
        .timeout(const Duration(seconds: 8));
    ensureSuccess(response);
    return (json.decode(response.body) as List<dynamic>).cast<String>();
  }

  Future<List<RoleDetail>> listRoles() async {
    final response = await http
        .get(Uri.parse("$baseUrl/api/roles/manage"), headers: headers)
        .timeout(const Duration(seconds: 8));
    ensureSuccess(response);
    final List<dynamic> data = json.decode(response.body);
    return data.map((e) => RoleDetail.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<RoleDetail> getRole(int id) async {
    final response = await http
        .get(Uri.parse("$baseUrl/api/roles/manage/$id"), headers: headers)
        .timeout(const Duration(seconds: 8));
    ensureSuccess(response);
    return RoleDetail.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  Future<RoleDetail> createRole(RoleCreateRequest request) async {
    final response = await http
        .post(
          Uri.parse("$baseUrl/api/roles/manage"),
          headers: headers,
          body: json.encode(request.toJson()),
        )
        .timeout(const Duration(seconds: 8));
    ensureSuccess(response);
    return RoleDetail.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  Future<RoleDetail> updateRole(int id, RoleUpdateRequest request) async {
    final response = await http
        .put(
          Uri.parse("$baseUrl/api/roles/manage/$id"),
          headers: headers,
          body: json.encode(request.toJson()),
        )
        .timeout(const Duration(seconds: 8));
    ensureSuccess(response);
    return RoleDetail.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  Future<void> deleteRole(int id) async {
    final response = await http
        .delete(Uri.parse("$baseUrl/api/roles/manage/$id"), headers: headers)
        .timeout(const Duration(seconds: 8));
    ensureSuccess(response);
  }

  Future<BulkDeleteResult> bulkDeleteRoles(List<int> ids) async {
    final response = await http
        .post(
          Uri.parse("$baseUrl/api/roles/manage/bulk-delete"),
          headers: headers,
          body: json.encode({'ids': ids}),
        )
        .timeout(const Duration(seconds: 20));
    ensureSuccess(response);
    return BulkDeleteResult.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }
}
