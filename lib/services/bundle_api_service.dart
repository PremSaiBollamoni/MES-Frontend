import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bundle.dart';
import 'api_client.dart';

class BundleApiService extends ApiClient {
  static final BundleApiService _instance = BundleApiService._internal();
  factory BundleApiService() => _instance;
  BundleApiService._internal();

  Future<List<Bundle>> listActive() async {
    final response = await http.get(Uri.parse("$baseUrl/api/wip/bundles"), headers: headers).timeout(const Duration(seconds: 10));
    ensureSuccess(response);
    final List<dynamic> data = json.decode(response.body);
    return data.map((e) => Bundle.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Bundle> createBundle(CreateBundleRequest request) async {
    final response = await http
        .post(Uri.parse("$baseUrl/api/wip/bundles"), headers: headers, body: json.encode(request.toJson()))
        .timeout(const Duration(seconds: 8));
    ensureSuccess(response);
    return Bundle.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  Future<Bundle> moveBundle(int id, int toStationId) async {
    final response = await http
        .post(Uri.parse("$baseUrl/api/wip/bundles/$id/move"), headers: headers, body: json.encode({'toStationId': toStationId}))
        .timeout(const Duration(seconds: 8));
    ensureSuccess(response);
    return Bundle.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  Future<Bundle> completeBundle(int id) async {
    final response = await http.post(Uri.parse("$baseUrl/api/wip/bundles/$id/complete"), headers: headers).timeout(const Duration(seconds: 8));
    ensureSuccess(response);
    return Bundle.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  Future<List<StationWipSummary>> getWipSummary() async {
    final response = await http.get(Uri.parse("$baseUrl/api/wip/summary"), headers: headers).timeout(const Duration(seconds: 10));
    ensureSuccess(response);
    final List<dynamic> data = json.decode(response.body);
    return data.map((e) => StationWipSummary.fromJson(e as Map<String, dynamic>)).toList();
  }
}
