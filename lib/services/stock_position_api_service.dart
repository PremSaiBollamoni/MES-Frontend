import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stock_position.dart';
import 'api_client.dart';

class StockPositionApiService extends ApiClient {
  static final StockPositionApiService _instance = StockPositionApiService._internal();
  factory StockPositionApiService() => _instance;
  StockPositionApiService._internal();

  Future<List<StockPosition>> listForDate(String date, {bool forceRefresh = false}) async {
    final response = await cachedGet(Uri.parse("$baseUrl/api/stock-position?date=$date"), forceRefresh: forceRefresh);
    ensureSuccess(response);
    final List<dynamic> data = json.decode(response.body);
    return data.map((e) => StockPosition.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<StockPosition> update(UpdateStockPositionRequest request) async {
    final response = await http
        .post(Uri.parse("$baseUrl/api/stock-position"), headers: headers, body: json.encode(request.toJson()))
        .timeout(const Duration(seconds: 60));
    ensureSuccess(response);
    ApiClient.invalidateCache();
    return StockPosition.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }
}
