import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/station_status.dart';
import 'api_client.dart';

class StationStatusApiService extends ApiClient {
  static final StationStatusApiService _instance = StationStatusApiService._internal();
  factory StationStatusApiService() => _instance;
  StationStatusApiService._internal();

  Future<List<StationStatus>> getStatus(String date) async {
    final response = await http
        .get(Uri.parse("$baseUrl/api/station-status?date=$date"), headers: headers)
        .timeout(const Duration(seconds: 10));
    ensureSuccess(response);
    final List<dynamic> data = json.decode(response.body);
    return data.map((e) => StationStatus.fromJson(e as Map<String, dynamic>)).toList();
  }
}
