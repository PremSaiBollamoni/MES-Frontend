import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/payroll_preview.dart';
import 'api_client.dart';

class PayrollApiService extends ApiClient {
  static final PayrollApiService _instance = PayrollApiService._internal();
  factory PayrollApiService() => _instance;
  PayrollApiService._internal();

  /// The same rows the Excel sheet is built from, as JSON - lets HR review every
  /// operator's earnings breakdown live before committing to a download.
  Future<List<PayrollOperatorRow>> previewPayroll(String startDate, String endDate) async {
    final response = await http
        .get(Uri.parse("$baseUrl/api/payroll/preview?startDate=$startDate&endDate=$endDate"), headers: headers)
        .timeout(const Duration(seconds: 60));
    ensureSuccess(response);
    final List<dynamic> data = json.decode(response.body);
    return data.map((e) => PayrollOperatorRow.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Not cached - a fresh workbook per request, downloaded on explicit tap.
  Future<http.Response> downloadPayrollXlsx(String startDate, String endDate) async {
    final response = await http
        .get(Uri.parse("$baseUrl/api/payroll/xlsx?startDate=$startDate&endDate=$endDate"), headers: headers)
        .timeout(const Duration(seconds: 60));
    ensureSuccess(response);
    return response;
  }
}
