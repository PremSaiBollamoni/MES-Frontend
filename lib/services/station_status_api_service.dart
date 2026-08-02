import 'dart:convert';
import '../models/station_status.dart';
import 'api_client.dart';

class StationStatusApiService extends ApiClient {
  static final StationStatusApiService _instance = StationStatusApiService._internal();
  factory StationStatusApiService() => _instance;
  StationStatusApiService._internal();

  Future<List<StationStatus>> getStatus(String date, {bool forceRefresh = false}) async {
    final response = await cachedGet(Uri.parse("$baseUrl/api/station-status?date=$date"), forceRefresh: forceRefresh);
    ensureSuccess(response);
    final List<dynamic> data = json.decode(response.body);
    return data.map((e) => StationStatus.fromJson(e as Map<String, dynamic>)).toList();
  }
}
