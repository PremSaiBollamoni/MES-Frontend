import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/employee_detail.dart';
import '../models/profile_request.dart';
import 'api_client.dart';

class ProfileApiService extends ApiClient {
  static final ProfileApiService _instance = ProfileApiService._internal();
  factory ProfileApiService() => _instance;
  ProfileApiService._internal();

  Future<EmployeeDetail> getProfile({bool forceRefresh = false}) async {
    final response = await cachedGet(Uri.parse("$baseUrl/api/profile"), forceRefresh: forceRefresh);
    ensureSuccess(response);
    return EmployeeDetail.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  Future<EmployeeDetail> updateProfile(ProfileUpdateRequest request) async {
    final response = await http
        .put(
          Uri.parse("$baseUrl/api/profile"),
          headers: headers,
          body: json.encode(request.toJson()),
        )
        .timeout(const Duration(seconds: 60));
    ensureSuccess(response);
    ApiClient.invalidateCache();
    return EmployeeDetail.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  Future<void> changePassword(ChangePasswordRequest request) async {
    final response = await http
        .put(
          Uri.parse("$baseUrl/api/profile/password"),
          headers: headers,
          body: json.encode(request.toJson()),
        )
        .timeout(const Duration(seconds: 60));
    ensureSuccess(response);
  }
}
