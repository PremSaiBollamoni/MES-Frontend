import 'dart:convert';
import '../models/hrms_employee.dart';
import 'api_client.dart';

class HrmsApiService extends ApiClient {
  static final HrmsApiService _instance = HrmsApiService._internal();
  factory HrmsApiService() => _instance;
  HrmsApiService._internal();

  Future<List<HrmsUnlinkedEmployee>> getUnlinkedEmployees({bool forceRefresh = false}) async {
    // This hits the backend, which in turn makes a live call to the external HRMS
    // portal (no caching on the backend side) - genuinely slow, so this is exactly
    // the kind of read that should sit behind the shared cache by default and only
    // be forced fresh on an explicit "Sync with HRMS" action.
    final response = await cachedGet(Uri.parse("$baseUrl/api/hrms/employees/unlinked"), forceRefresh: forceRefresh);
    ensureSuccess(response);
    final List<dynamic> data = json.decode(response.body);
    return data.map((e) => HrmsUnlinkedEmployee.fromJson(e as Map<String, dynamic>)).toList();
  }
}
