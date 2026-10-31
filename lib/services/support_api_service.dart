import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';

class TicketDraft {
  final String subject;
  final String description;
  const TicketDraft(this.subject, this.description);
}

class SupportTicket {
  final int id;
  final String employeeName;
  final String subject;
  final String description;
  final String status;
  final String? resolutionNotes;
  final String createdAt;

  SupportTicket({
    required this.id,
    required this.employeeName,
    required this.subject,
    required this.description,
    required this.status,
    this.resolutionNotes,
    required this.createdAt,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) => SupportTicket(
        id: json['id'] as int,
        employeeName: json['employeeName'] as String,
        subject: json['subject'] as String,
        description: json['description'] as String,
        status: json['status'] as String,
        resolutionNotes: json['resolutionNotes'] as String?,
        createdAt: json['createdAt'] as String,
      );
}

class SupportApiService extends ApiClient {
  static final SupportApiService _instance = SupportApiService._internal();
  factory SupportApiService() => _instance;
  SupportApiService._internal();

  /// [history] is the conversation so far as {role: "user"|"assistant", content: "..."}
  /// maps, oldest first - the backend is stateless, so the whole thing is resent each turn.
  Future<String> sendChatMessage(List<Map<String, String>> history) async {
    final response = await http
        .post(
          Uri.parse("$baseUrl/api/support/chat"),
          headers: headers,
          body: json.encode({"history": history}),
        )
        .timeout(const Duration(seconds: 60));
    ensureSuccess(response);
    final body = json.decode(response.body) as Map<String, dynamic>;
    return body['reply'] as String;
  }

  Future<void> raiseTicket(String subject, String description) async {
    final response = await http
        .post(
          Uri.parse("$baseUrl/api/support/tickets"),
          headers: headers,
          body: json.encode({"subject": subject, "description": description}),
        )
        .timeout(const Duration(seconds: 30));
    ensureSuccess(response);
  }

  /// Unauthenticated variant for the Login screen - no token to read an identity from,
  /// so the same conversation-history shape is sent straight to the public endpoint.
  Future<String> sendPublicChatMessage(List<Map<String, String>> history) async {
    final response = await http
        .post(
          Uri.parse("$baseUrl/api/support/chat/public"),
          headers: headers,
          body: json.encode({"history": history}),
        )
        .timeout(const Duration(seconds: 60));
    ensureSuccess(response);
    final body = json.decode(response.body) as Map<String, dynamic>;
    return body['reply'] as String;
  }

  /// Unauthenticated variant for the Login screen - the employee identifies themselves
  /// by username since there's no JWT to read it from.
  Future<void> raisePublicTicket(String username, String subject, String description) async {
    final response = await http
        .post(
          Uri.parse("$baseUrl/api/support/tickets/public"),
          headers: headers,
          body: json.encode({"username": username, "subject": subject, "description": description}),
        )
        .timeout(const Duration(seconds: 30));
    ensureSuccess(response);
  }

  /// Asks the AI to turn the conversation so far into a ready-to-submit ticket
  /// (subject + description) instead of the employee writing it up themselves.
  Future<TicketDraft> draftTicket(List<Map<String, String>> history, {bool isPublic = false}) async {
    final path = isPublic ? "/api/support/draft-ticket/public" : "/api/support/draft-ticket";
    final response = await http
        .post(
          Uri.parse("$baseUrl$path"),
          headers: headers,
          body: json.encode({"history": history}),
        )
        .timeout(const Duration(seconds: 30));
    ensureSuccess(response);
    final body = json.decode(response.body) as Map<String, dynamic>;
    return TicketDraft(body['subject'] as String? ?? "", body['description'] as String? ?? "");
  }

  Future<List<SupportTicket>> listTickets({bool forceRefresh = false}) async {
    final response = await cachedGet(Uri.parse("$baseUrl/api/support/tickets"), forceRefresh: forceRefresh);
    ensureSuccess(response);
    final list = json.decode(response.body) as List;
    return list.map((e) => SupportTicket.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> resolveTicket(int id, String resolutionNotes) async {
    final response = await http
        .put(
          Uri.parse("$baseUrl/api/support/tickets/$id"),
          headers: headers,
          body: json.encode({"status": "RESOLVED", "resolutionNotes": resolutionNotes}),
        )
        .timeout(const Duration(seconds: 30));
    ensureSuccess(response);
    ApiClient.invalidateCache();
  }
}
