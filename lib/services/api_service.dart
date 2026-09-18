import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/login_result.dart';
import '../models/user_model.dart';
import '../utils/api_config.dart';
import 'api_client.dart';
import 'auth_session.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String get baseUrl => ApiConfig.baseUrl;

  /// Checks the connectivity and database status of the Spring Boot backend.
  /// Returns the connection URL if successful, otherwise null.
  Future<String?> checkBackendHealth() async {
    final String healthUrl = "$baseUrl/api/auth/health";
    try {
      final response = await http.get(
        Uri.parse(healthUrl),
        headers: {'Content-Type': 'application/json'},
        // Render's free tier spins the backend down after ~15 min idle; waking it
        // (JVM boot + Flyway) can take 30-60s, so a short "fail fast" timeout here
        // would misreport a cold start as the backend being down.
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'UP') {
          return healthUrl;
        }
      }
    } catch (e) {
      debugPrint("Connectivity check failed for $healthUrl: $e");
    }
    return null;
  }

  /// Sends a login request to the backend. Returns either a completed
  /// [LoginResult.success] (employee has exactly one active role - session is
  /// already persisted) or [LoginResult.roleSelectionRequired] (employee holds
  /// more than one active role - call [selectRole] next). Throws on failure.
  Future<LoginResult> login(String username, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/auth/login"),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
      }),
    ).timeout(const Duration(seconds: 60));

    final Map<String, dynamic> responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      if (responseData['requiresRoleSelection'] == true) {
        return LoginResult.roleSelectionRequired(RoleSelectionRequired.fromJson(responseData));
      }
      final String? token = responseData['token'] as String?;
      final user = UserModel.fromJson(responseData);
      if (token != null) {
        await AuthSession().save(token, user);
        // The response cache is keyed by URL only (self-scoped endpoints like
        // /production-entries/me carry no employee id in the URL) - without this, a
        // second employee logging in on the same device within the cache TTL would be
        // served the first employee's cached responses.
        ApiClient.invalidateCache();
      }
      return LoginResult.success(user);
    } else {
      final String errorMessage = responseData['error'] ?? "Authentication failed";
      throw Exception(errorMessage);
    }
  }

  /// Second step for a multi-role employee: exchanges the role-selection token
  /// plus a chosen role name for a real session (persisted, like a normal login).
  Future<UserModel> selectRole(String preAuthToken, String roleName) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/auth/select-role"),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'preAuthToken': preAuthToken,
        'roleName': roleName,
      }),
    ).timeout(const Duration(seconds: 60));

    final Map<String, dynamic> responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      final String? token = responseData['token'] as String?;
      final user = UserModel.fromJson(responseData);
      if (token != null) {
        await AuthSession().save(token, user);
        ApiClient.invalidateCache();
      }
      return user;
    } else {
      final String errorMessage = responseData['error'] ?? "Role selection failed";
      throw Exception(errorMessage);
    }
  }

  /// Switches the current, already-signed-in employee to a different role they
  /// hold - no password re-entry. The "Switch Role" drawer action.
  Future<UserModel> switchRole(String roleName) async {
    final token = AuthSession().token;
    final response = await http.post(
      Uri.parse("$baseUrl/api/auth/switch-role"),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode({'roleName': roleName}),
    ).timeout(const Duration(seconds: 60));

    final Map<String, dynamic> responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      final String? newToken = responseData['token'] as String?;
      final user = UserModel.fromJson(responseData);
      if (newToken != null) {
        await AuthSession().save(newToken, user);
        ApiClient.invalidateCache();
      }
      return user;
    } else {
      final String errorMessage = responseData['error'] ?? "Couldn't switch role";
      throw Exception(errorMessage);
    }
  }
}
