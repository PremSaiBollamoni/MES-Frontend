import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/allocation.dart';
import '../models/roster_entry.dart';
import 'api_client.dart';

class AllocationApiService extends ApiClient {
  static final AllocationApiService _instance = AllocationApiService._internal();
  factory AllocationApiService() => _instance;
  AllocationApiService._internal();

  Future<List<RosterEntry>> rosterForDate(String date) async {
    final response = await http
        .get(Uri.parse("$baseUrl/api/allocations/roster?date=$date"), headers: headers)
        .timeout(const Duration(seconds: 10));
    ensureSuccess(response);
    final List<dynamic> data = json.decode(response.body);
    return data.map((e) => RosterEntry.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Allocation>> listForDate(String date) async {
    final response = await http
        .get(Uri.parse("$baseUrl/api/allocations?date=$date"), headers: headers)
        .timeout(const Duration(seconds: 10));
    ensureSuccess(response);
    final List<dynamic> data = json.decode(response.body);
    return data.map((e) => Allocation.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Allocation> assign(AssignAllocationRequest request) async {
    final response = await http
        .post(Uri.parse("$baseUrl/api/allocations"), headers: headers, body: json.encode(request.toJson()))
        .timeout(const Duration(seconds: 8));
    ensureSuccess(response);
    return Allocation.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  Future<void> unassign(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/api/allocations/$id"), headers: headers).timeout(const Duration(seconds: 8));
    ensureSuccess(response);
  }
}
