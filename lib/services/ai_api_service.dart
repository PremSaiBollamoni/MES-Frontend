import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';

class AiModelView {
  final int id;
  final String modelName;
  final String? label;
  final bool enabled;

  const AiModelView({required this.id, required this.modelName, required this.label, required this.enabled});

  factory AiModelView.fromJson(Map<String, dynamic> json) => AiModelView(
        id: (json['id'] as num).toInt(),
        modelName: json['modelName'] as String,
        label: json['label'] as String?,
        enabled: json['enabled'] as bool,
      );
}

class AiProviderView {
  final int id;
  final String name;
  final String providerType;
  final String baseUrl;
  final bool enabled;
  final bool keySet;
  final List<AiModelView> models;

  const AiProviderView({
    required this.id,
    required this.name,
    required this.providerType,
    required this.baseUrl,
    required this.enabled,
    required this.keySet,
    required this.models,
  });

  factory AiProviderView.fromJson(Map<String, dynamic> json) => AiProviderView(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String,
        providerType: json['providerType'] as String,
        baseUrl: json['baseUrl'] as String,
        enabled: json['enabled'] as bool,
        keySet: json['keySet'] as bool,
        models: (json['models'] as List<dynamic>)
            .map((e) => AiModelView.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class AiFeatureView {
  final String feature;
  final int? modelId;
  final String? providerName;
  final String? modelName;
  final int? fallbackModelId;
  final String? fallbackProviderName;
  final String? fallbackModelName;

  const AiFeatureView({
    required this.feature,
    required this.modelId,
    required this.providerName,
    required this.modelName,
    required this.fallbackModelId,
    required this.fallbackProviderName,
    required this.fallbackModelName,
  });

  factory AiFeatureView.fromJson(Map<String, dynamic> json) => AiFeatureView(
        feature: json['feature'] as String,
        modelId: (json['modelId'] as num?)?.toInt(),
        providerName: json['providerName'] as String?,
        modelName: json['modelName'] as String?,
        fallbackModelId: (json['fallbackModelId'] as num?)?.toInt(),
        fallbackProviderName: json['fallbackProviderName'] as String?,
        fallbackModelName: json['fallbackModelName'] as String?,
      );
}

class AiApiService extends ApiClient {
  static final AiApiService _instance = AiApiService._internal();
  factory AiApiService() => _instance;
  AiApiService._internal();

  Future<List<AiProviderView>> listProviders() async {
    final response = await http
        .get(Uri.parse("$baseUrl/api/ai/providers"), headers: headers)
        .timeout(const Duration(seconds: 30));
    ensureSuccess(response);
    final List<dynamic> data = json.decode(response.body) as List<dynamic>;
    return data.map((e) => AiProviderView.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Creates a provider when [id] is null, otherwise updates it. A null or empty [apiKey] keeps the saved key.
  Future<void> saveProvider({
    int? id,
    required String name,
    required String providerType,
    required String address,
    required String? apiKey,
    required bool enabled,
  }) async {
    final body = json.encode({
      "name": name,
      "providerType": providerType,
      "baseUrl": address,
      "apiKey": apiKey,
      "enabled": enabled,
    });
    final response = id == null
        ? await http
            .post(Uri.parse("$baseUrl/api/ai/providers"), headers: headers, body: body)
            .timeout(const Duration(seconds: 30))
        : await http
            .put(Uri.parse("$baseUrl/api/ai/providers/$id"), headers: headers, body: body)
            .timeout(const Duration(seconds: 30));
    ensureSuccess(response);
  }

  Future<void> deleteProvider(int id) async {
    final response = await http
        .delete(Uri.parse("$baseUrl/api/ai/providers/$id"), headers: headers)
        .timeout(const Duration(seconds: 30));
    ensureSuccess(response);
  }

  Future<void> addModel({required int providerId, required String modelName, required String? label}) async {
    final response = await http
        .post(
          Uri.parse("$baseUrl/api/ai/providers/$providerId/models"),
          headers: headers,
          body: json.encode({"modelName": modelName, "label": label}),
        )
        .timeout(const Duration(seconds: 30));
    ensureSuccess(response);
  }

  Future<void> deleteModel(int id) async {
    final response = await http
        .delete(Uri.parse("$baseUrl/api/ai/models/$id"), headers: headers)
        .timeout(const Duration(seconds: 30));
    ensureSuccess(response);
  }

  /// Sends a short test request to the model with the saved key and returns the reply summary.
  Future<String> testModel(int id) async {
    final response = await http
        .post(Uri.parse("$baseUrl/api/ai/models/$id/test"), headers: headers)
        .timeout(const Duration(seconds: 120));
    ensureSuccess(response);
    final body = json.decode(response.body) as Map<String, dynamic>;
    return body["message"] as String? ?? "OK";
  }

  Future<List<AiFeatureView>> listFeatures() async {
    final response = await http
        .get(Uri.parse("$baseUrl/api/ai/features"), headers: headers)
        .timeout(const Duration(seconds: 30));
    ensureSuccess(response);
    final List<dynamic> data = json.decode(response.body) as List<dynamic>;
    return data.map((e) => AiFeatureView.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// [feature] is "CHAT" or "REPORT". A null [modelId] clears the choice; a null [fallbackModelId] means no fallback.
  Future<void> assignFeature(String feature, {int? modelId, int? fallbackModelId}) async {
    final response = await http
        .put(
          Uri.parse("$baseUrl/api/ai/features/$feature"),
          headers: headers,
          body: json.encode({"modelId": modelId, "fallbackModelId": fallbackModelId}),
        )
        .timeout(const Duration(seconds: 30));
    ensureSuccess(response);
  }
}
