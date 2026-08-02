import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stock_availability.dart';
import 'api_client.dart';

class StockAvailabilityApiService extends ApiClient {
  static final StockAvailabilityApiService _instance = StockAvailabilityApiService._internal();
  factory StockAvailabilityApiService() => _instance;
  StockAvailabilityApiService._internal();

  Future<List<StockAvailability>> listForDate(String date, {bool forceRefresh = false}) async {
    final response = await cachedGet(Uri.parse("$baseUrl/api/stock-availability?date=$date"), forceRefresh: forceRefresh);
    ensureSuccess(response);
    final List<dynamic> data = json.decode(response.body);
    return data.map((e) => StockAvailability.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<StockAvailability> log(LogStockAvailabilityRequest request) async {
    final response = await http
        .post(Uri.parse("$baseUrl/api/stock-availability"), headers: headers, body: json.encode(request.toJson()))
        .timeout(const Duration(seconds: 60));
    ensureSuccess(response);
    ApiClient.invalidateCache();
    return StockAvailability.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }
}
