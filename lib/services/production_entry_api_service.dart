import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/production_entry.dart';
import 'api_client.dart';

class ProductionEntryApiService extends ApiClient {
  static final ProductionEntryApiService _instance = ProductionEntryApiService._internal();
  factory ProductionEntryApiService() => _instance;
  ProductionEntryApiService._internal();

  Future<List<ProductionEntry>> listForDate(String date) async {
    final response = await http
        .get(Uri.parse("$baseUrl/api/production-entries?date=$date"), headers: headers)
        .timeout(const Duration(seconds: 10));
    ensureSuccess(response);
    final List<dynamic> data = json.decode(response.body);
    return data.map((e) => ProductionEntry.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ProductionEntry> log(LogProductionEntryRequest request) async {
    final response = await http
        .post(Uri.parse("$baseUrl/api/production-entries"), headers: headers, body: json.encode(request.toJson()))
        .timeout(const Duration(seconds: 8));
    ensureSuccess(response);
    return ProductionEntry.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  Future<List<ProductionEntry>> myEntries({int days = 30}) async {
    final response = await http
        .get(Uri.parse("$baseUrl/api/production-entries/me?days=$days"), headers: headers)
        .timeout(const Duration(seconds: 10));
    ensureSuccess(response);
    final List<dynamic> data = json.decode(response.body);
    return data.map((e) => ProductionEntry.fromJson(e as Map<String, dynamic>)).toList();
  }
}
