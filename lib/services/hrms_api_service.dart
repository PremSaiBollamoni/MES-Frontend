import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/hrms_employee.dart';
import 'api_client.dart';

class HrmsApiService extends ApiClient {
  static final HrmsApiService _instance = HrmsApiService._internal();
  factory HrmsApiService() => _instance;
  HrmsApiService._internal();

  Future<List<HrmsUnlinkedEmployee>> getUnlinkedEmployees() async {
    final response = await http
        .get(Uri.parse("$baseUrl/api/hrms/employees/unlinked"), headers: headers)
        .timeout(const Duration(seconds: 10));
    ensureSuccess(response);
    final List<dynamic> data = json.decode(response.body);
    return data.map((e) => HrmsUnlinkedEmployee.fromJson(e as Map<String, dynamic>)).toList();
  }
}
