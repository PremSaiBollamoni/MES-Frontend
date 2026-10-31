import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'api_client.dart';

class EmployeeExportApiService extends ApiClient {
  static final EmployeeExportApiService _instance = EmployeeExportApiService._internal();
  factory EmployeeExportApiService() => _instance;
  EmployeeExportApiService._internal();

  /// Returns the spreadsheet bytes. With [resetPasswords] every employee gets a new temporary
  /// password first, and the sheet lists it.
  Future<Uint8List> downloadEmployees(int factoryId, {required bool resetPasswords}) async {
    final response = await http
        .post(
          Uri.parse("$baseUrl/api/employee-export/factories/$factoryId/download"),
          headers: headers,
          body: json.encode({"resetPasswords": resetPasswords}),
        )
        .timeout(const Duration(seconds: 60));
    ensureSuccess(response);
    return response.bodyBytes;
  }

  Future<void> emailEmployees(int factoryId, {required bool resetPasswords, required List<String> recipients}) async {
    final response = await http
        .post(
          Uri.parse("$baseUrl/api/employee-export/factories/$factoryId/email"),
          headers: headers,
          body: json.encode({"resetPasswords": resetPasswords, "recipients": recipients}),
        )
        .timeout(const Duration(seconds: 90));
    ensureSuccess(response);
  }
}
