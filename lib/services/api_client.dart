import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';
import '../utils/error_messages.dart';
import 'auth_session.dart';

class _CacheEntry {
  final http.Response response;
  final DateTime storedAt;
  _CacheEntry(this.response, this.storedAt);
}

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

  // Process-wide (not per-instance) GET response cache, keyed by full URL. The backend
  // is now a remote, sometimes-cold-starting server instead of localhost, and several
  // screens were re-fetching the same read-only data (including live HRMS calls) every
  // single time they were visited. Read endpoints are cached for [defaultCacheTtl] by
  // default; explicit user actions (pull-to-refresh, a "Sync"/"Retry" button) should
  // pass forceRefresh: true to bypass the cache and hit the network for real.
  static final Map<String, _CacheEntry> _cache = {};
  static const Duration defaultCacheTtl = Duration(minutes: 15);

  /// Cached GET - returns the cached response if one exists and is younger than [ttl],
  /// otherwise performs the real request and caches a successful (2xx) result.
  Future<http.Response> cachedGet(
    Uri uri, {
    bool forceRefresh = false,
    Duration ttl = defaultCacheTtl,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    final key = uri.toString();
    if (!forceRefresh) {
      final cached = _cache[key];
      if (cached != null && DateTime.now().difference(cached.storedAt) < ttl) {
        return cached.response;
      }
    }
    final response = await http.get(uri, headers: headers).timeout(timeout);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      _cache[key] = _CacheEntry(response, DateTime.now());
    }
    return response;
  }

  /// Drops every cached GET response - call after any mutation whose result other
  /// screens' cached reads might now disagree with (e.g. after creating an employee).
  static void invalidateCache() => _cache.clear();

  /// Throws on a non-2xx response, carrying the backend's error code alongside its
  /// English text as "CODE|text". The code is preserved rather than discarded so the UI
  /// can translate it - see ErrorMessages.translate, which needs a BuildContext that
  /// isn't available down here in the service layer.
  void ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    String message = "Request failed (${response.statusCode})";
    String? code;
    try {
      final body = json.decode(response.body);
      if (body is Map) {
        if (body['error'] != null) message = body['error'] as String;
        if (body['code'] != null) code = body['code'] as String;
      }
    } catch (_) {
      // Response body wasn't JSON - fall back to the generic status message.
    }
    throw Exception(ErrorMessages.pack(code, message));
  }
}
