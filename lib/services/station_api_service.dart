import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bulk_delete_result.dart';
import '../models/station.dart';
import 'api_client.dart';

class StationApiService extends ApiClient {
  static final StationApiService _instance = StationApiService._internal();
  factory StationApiService() => _instance;
  StationApiService._internal();

  Future<List<Station>> listStations() async {
    final response = await http.get(Uri.parse("$baseUrl/api/stations"), headers: headers).timeout(const Duration(seconds: 10));
    ensureSuccess(response);
    final List<dynamic> data = json.decode(response.body);
    return data.map((e) => Station.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Station> getStation(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/api/stations/$id"), headers: headers).timeout(const Duration(seconds: 8));
    ensureSuccess(response);
    return Station.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  Future<Station> createStation(StationRequest request) async {
    final response = await http
        .post(Uri.parse("$baseUrl/api/stations"), headers: headers, body: json.encode(request.toJson()))
        .timeout(const Duration(seconds: 8));
    ensureSuccess(response);
    return Station.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  Future<Station> updateStation(int id, StationRequest request) async {
    final response = await http
        .put(Uri.parse("$baseUrl/api/stations/$id"), headers: headers, body: json.encode(request.toJson()))
        .timeout(const Duration(seconds: 8));
    ensureSuccess(response);
    return Station.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  Future<void> deleteStation(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/api/stations/$id"), headers: headers).timeout(const Duration(seconds: 8));
    ensureSuccess(response);
  }

  Future<BulkDeleteResult> bulkDeleteStations(List<int> ids) async {
    final response = await http
        .post(Uri.parse("$baseUrl/api/stations/bulk-delete"), headers: headers, body: json.encode({'ids': ids}))
        .timeout(const Duration(seconds: 20));
    ensureSuccess(response);
    return BulkDeleteResult.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }
}
