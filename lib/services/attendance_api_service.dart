import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/attendance.dart';
import '../models/attendance_history_record.dart';
import 'api_client.dart';

class AttendanceApiService extends ApiClient {
  static final AttendanceApiService _instance = AttendanceApiService._internal();
  factory AttendanceApiService() => _instance;
  AttendanceApiService._internal();

  // HRMS lives on a remote biometric portal that can be slow to answer; the old
  // 10s ceiling was tripping "TimeoutException: Future not completed". 30s gives
  // the portal room to respond without hanging the UI indefinitely.
  static const Duration _hrmsTimeout = Duration(seconds: 30);
  static const Duration _localTimeout = Duration(seconds: 20);

  Future<LiveAttendanceStatus> getLiveStatus() async {
    final response = await http.get(Uri.parse("$baseUrl/api/attendance/live"), headers: headers).timeout(_hrmsTimeout);
    ensureSuccess(response);
    return LiveAttendanceStatus.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  Future<List<DailyAttendanceRecord>> getDaily({DateTime? date}) async {
    final uri = Uri.parse("$baseUrl/api/attendance/daily").replace(
      queryParameters: date != null ? {'date': _isoDate(date)} : null,
    );
    final response = await http.get(uri, headers: headers).timeout(_hrmsTimeout);
    ensureSuccess(response);
    final List<dynamic> data = json.decode(response.body);
    return data.map((e) => DailyAttendanceRecord.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Pulls every day in the window from HRMS into our local attendance history.
  /// Safe to call repeatedly - a re-sync just overwrites the same rows.
  Future<AttendanceSyncResult> syncHistory({int days = 90}) async {
    final uri = Uri.parse("$baseUrl/api/attendance/sync").replace(queryParameters: {'days': '$days'});
    final response = await http.post(uri, headers: headers).timeout(const Duration(minutes: 2));
    ensureSuccess(response);
    return AttendanceSyncResult.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  Future<List<AttendanceHistoryRecord>> getHistory({int days = 30}) async {
    final uri = Uri.parse("$baseUrl/api/attendance/history").replace(queryParameters: {'days': '$days'});
    final response = await http.get(uri, headers: headers).timeout(_localTimeout);
    ensureSuccess(response);
    final List<dynamic> data = json.decode(response.body);
    return data.map((e) => AttendanceHistoryRecord.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Local history for an explicit date range - used by the Monthly view.
  Future<List<AttendanceHistoryRecord>> getHistoryRange(DateTime from, DateTime to) async {
    final uri = Uri.parse("$baseUrl/api/attendance/history")
        .replace(queryParameters: {'from': _isoDate(from), 'to': _isoDate(to)});
    final response = await http.get(uri, headers: headers).timeout(_localTimeout);
    ensureSuccess(response);
    final List<dynamic> data = json.decode(response.body);
    return data.map((e) => AttendanceHistoryRecord.fromJson(e as Map<String, dynamic>)).toList();
  }

  String _isoDate(DateTime d) => "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
}
