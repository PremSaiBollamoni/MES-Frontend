import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tracking_session.dart';
import 'api_client.dart';

class TrackingSessionApiService extends ApiClient {
  static final TrackingSessionApiService _instance = TrackingSessionApiService._internal();
  factory TrackingSessionApiService() => _instance;
  TrackingSessionApiService._internal();

  Future<List<TrackingSession>> listForDate(String date, {bool forceRefresh = false}) async {
    final response = await cachedGet(Uri.parse("$baseUrl/api/tracking?date=$date"), forceRefresh: forceRefresh);
    ensureSuccess(response);
    final List<dynamic> data = json.decode(response.body);
    return data.map((e) => TrackingSession.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<TrackingSession> start(StartTrackingRequest request) async {
    final response = await http
        .post(Uri.parse("$baseUrl/api/tracking/start"), headers: headers, body: json.encode(request.toJson()))
        .timeout(const Duration(seconds: 60));
    ensureSuccess(response);
    ApiClient.invalidateCache();
    return TrackingSession.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  Future<TrackingSession> stop(int id, {int? piecesCompleted}) async {
    final response = await http
        .post(
          Uri.parse("$baseUrl/api/tracking/$id/stop"),
          headers: headers,
          body: json.encode(StopTrackingRequest(piecesCompleted: piecesCompleted).toJson()),
        )
        .timeout(const Duration(seconds: 60));
    ensureSuccess(response);
    ApiClient.invalidateCache();
    return TrackingSession.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }
}
