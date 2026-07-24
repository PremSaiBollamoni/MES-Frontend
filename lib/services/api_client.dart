import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';
import 'auth_session.dart';

/// Shared HTTP plumbing (base URL, auth header, error unwrapping) for every
/// authenticated API service - keeps each service focused on its own endpoints.
abstract class ApiClient {
  String get baseUrl => ApiConfig.baseUrl;

  Map<String, String> get headers {
    final token = AuthSession().token;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  void ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    String message = "Request failed (${response.statusCode})";
    try {
      final body = json.decode(response.body);
      if (body is Map && body['error'] != null) {
        message = body['error'] as String;
      }
    } catch (_) {
      // Response body wasn't JSON - fall back to the generic status message.
    }
    throw Exception(message);
  }
}
