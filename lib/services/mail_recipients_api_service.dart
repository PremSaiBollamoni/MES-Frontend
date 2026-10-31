import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';

class MailRecipient {
  final int id;
  final String email;
  final String? name;
  final bool receivesPayroll;
  final bool receivesAttendance;
  final bool receivesProduction;
  final bool active;

  const MailRecipient({
    required this.id,
    required this.email,
    required this.name,
    required this.receivesPayroll,
    required this.receivesAttendance,
    required this.receivesProduction,
    required this.active,
  });

  factory MailRecipient.fromJson(Map<String, dynamic> json) => MailRecipient(
        id: (json['id'] as num).toInt(),
        email: json['email'] as String,
        name: json['name'] as String?,
        receivesPayroll: json['receivesPayroll'] as bool,
        receivesAttendance: json['receivesAttendance'] as bool,
        receivesProduction: json['receivesProduction'] as bool,
        active: json['active'] as bool,
      );
}

class MailRecipientDraft {
  final String email;
  final String name;
  final bool receivesPayroll;
  final bool receivesAttendance;
  final bool receivesProduction;
  final bool active;

  const MailRecipientDraft({
    required this.email,
    required this.name,
    required this.receivesPayroll,
    required this.receivesAttendance,
    required this.receivesProduction,
    required this.active,
  });

  Map<String, dynamic> toJson() => {
        "email": email,
        "name": name,
        "receivesPayroll": receivesPayroll,
        "receivesAttendance": receivesAttendance,
        "receivesProduction": receivesProduction,
        "active": active,
      };
}

class MailRecipientsApiService extends ApiClient {
  static final MailRecipientsApiService _instance = MailRecipientsApiService._internal();
  factory MailRecipientsApiService() => _instance;
  MailRecipientsApiService._internal();

  Future<List<MailRecipient>> list() async {
    final response = await http
        .get(Uri.parse("$baseUrl/api/mail-recipients"), headers: headers)
        .timeout(const Duration(seconds: 30));
    ensureSuccess(response);
    final List<dynamic> data = json.decode(response.body);
    return data.map((e) => MailRecipient.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// The addresses that receive payroll emails - readable by payroll users too, so the
  /// Send Mail dialog can pre-fill them.
  Future<List<String>> payrollEmails() async {
    final response = await http
        .get(Uri.parse("$baseUrl/api/mail-recipients/payroll-emails"), headers: headers)
        .timeout(const Duration(seconds: 30));
    ensureSuccess(response);
    final List<dynamic> data = json.decode(response.body);
    return data.cast<String>();
  }

  Future<void> create(MailRecipientDraft draft) async {
    final response = await http
        .post(
          Uri.parse("$baseUrl/api/mail-recipients"),
          headers: headers,
          body: json.encode(draft.toJson()),
        )
        .timeout(const Duration(seconds: 30));
    ensureSuccess(response);
  }

  Future<void> update(int id, MailRecipientDraft draft) async {
    final response = await http
        .put(
          Uri.parse("$baseUrl/api/mail-recipients/$id"),
          headers: headers,
          body: json.encode(draft.toJson()),
        )
        .timeout(const Duration(seconds: 30));
    ensureSuccess(response);
  }

  Future<void> delete(int id) async {
    final response = await http
        .delete(Uri.parse("$baseUrl/api/mail-recipients/$id"), headers: headers)
        .timeout(const Duration(seconds: 30));
    ensureSuccess(response);
  }
}
