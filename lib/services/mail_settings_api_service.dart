import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';

class MailSettingsView {
  final String smtpHost;
  final int smtpPort;
  final String? smtpUsername;
  final bool passwordSet;

  const MailSettingsView({
    required this.smtpHost,
    required this.smtpPort,
    required this.smtpUsername,
    required this.passwordSet,
  });

  factory MailSettingsView.fromJson(Map<String, dynamic> json) => MailSettingsView(
        smtpHost: json['smtpHost'] as String,
        smtpPort: (json['smtpPort'] as num).toInt(),
        smtpUsername: json['smtpUsername'] as String?,
        passwordSet: json['passwordSet'] as bool,
      );
}

class MailSettingsApiService extends ApiClient {
  static final MailSettingsApiService _instance = MailSettingsApiService._internal();
  factory MailSettingsApiService() => _instance;
  MailSettingsApiService._internal();

  Future<MailSettingsView> get() async {
    final response = await http
        .get(Uri.parse("$baseUrl/api/mail-settings"), headers: headers)
        .timeout(const Duration(seconds: 30));
    ensureSuccess(response);
    return MailSettingsView.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  /// A null or empty [password] keeps the password already saved on the server.
  Future<MailSettingsView> save({
    required String host,
    required int port,
    required String? username,
    required String? password,
  }) async {
    final response = await http
        .put(
          Uri.parse("$baseUrl/api/mail-settings"),
          headers: headers,
          body: json.encode({
            "smtpHost": host,
            "smtpPort": port,
            "smtpUsername": username,
            "smtpPassword": password,
          }),
        )
        .timeout(const Duration(seconds: 30));
    ensureSuccess(response);
    return MailSettingsView.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  Future<void> sendTest(String recipient) async {
    final response = await http
        .post(
          Uri.parse("$baseUrl/api/mail-settings/test"),
          headers: headers,
          body: json.encode({"recipient": recipient}),
        )
        .timeout(const Duration(seconds: 60));
    ensureSuccess(response);
  }
}
