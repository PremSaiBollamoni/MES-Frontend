import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/roster_entry.dart';
import '../models/scanned_page.dart';
import 'api_client.dart';

/// Reads photographed production book pages and saves the supervisor's confirmed result.
///
/// Reading and saving are deliberately separate calls: nothing reaches the production log until
/// the supervisor has seen the draft and confirmed it.
class ScanApiService extends ApiClient {
  static final ScanApiService _instance = ScanApiService._internal();
  factory ScanApiService() => _instance;
  ScanApiService._internal();

  /// Whether the server is configured to scan, so the button can be hidden rather than fail.
  Future<bool> isEnabled() async {
    try {
      final response = await cachedGet(Uri.parse("$baseUrl/api/production-scan/status"));
      if (response.statusCode != 200) return false;
      return (json.decode(response.body) as Map<String, dynamic>)['enabled'] as bool? ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Everyone whose book can be scanned - all active staff, not today's roster, because the
  /// books being imported are historical.
  Future<List<RosterEntry>> scannableEmployees({bool forceRefresh = false}) async {
    final response = await cachedGet(
        Uri.parse("$baseUrl/api/production-scan/employees"), forceRefresh: forceRefresh);
    ensureSuccess(response);
    final List<dynamic> data = json.decode(response.body);
    return data
        .map((e) => RosterEntry(
              employeeId: e['id'] as int,
              employeeName: e['name'] as String,
              employeeCode: e['username'] as String?,
            ))
        .toList();
  }

  /// Reads one page. Generous timeout - a full page of handwriting takes a while to work through.
  Future<ScannedPage> readPage({
    required String imagePath,
    required int employeeId,
    String? expectedDate,
  }) async {
    final uri = Uri.parse("$baseUrl/api/production-scan/read").replace(queryParameters: {
      'employeeId': '$employeeId',
      'expectedDate': ?expectedDate,
    });

    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(headers..remove('Content-Type'))
      ..files.add(await http.MultipartFile.fromPath('image', imagePath));

    final streamed = await request.send().timeout(const Duration(minutes: 3));
    final response = await http.Response.fromStream(streamed);
    ensureSuccess(response);
    return ScannedPage.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  /// Writes the confirmed rows. Returns how many production entries were created.
  Future<int> confirm(ScannedPage page) async {
    final body = {
      'employeeId': page.employeeId,
      'shiftDate': page.shiftDate,
      'rows': page.rows.where((r) => r.isSaveable).map((r) => r.toConfirmJson()).toList(),
    };

    final response = await http
        .post(Uri.parse("$baseUrl/api/production-scan/confirm"),
            headers: headers, body: json.encode(body))
        .timeout(const Duration(seconds: 90));
    ensureSuccess(response);
    ApiClient.invalidateCache();
    return (json.decode(response.body) as Map<String, dynamic>)['entriesCreated'] as int? ?? 0;
  }
}
