import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/attendance.dart';
import '../models/attendance_history_record.dart';
import 'api_client.dart';

class AttendanceApiService extends ApiClient {
  static final AttendanceApiService _instance = AttendanceApiService._internal();
  factory AttendanceApiService() => _instance;
  AttendanceApiService._internal();

  Future<LiveAttendanceStatus> getLiveStatus({bool forceRefresh = false}) async {
    final response = await cachedGet(Uri.parse("$baseUrl/api/attendance/live"), forceRefresh: forceRefresh);
    ensureSuccess(response);
    return LiveAttendanceStatus.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  Future<List<DailyAttendanceRecord>> getDaily({DateTime? date, bool forceRefresh = false}) async {
    final uri = Uri.parse("$baseUrl/api/attendance/daily").replace(
      queryParameters: date != null ? {'date': _isoDate(date)} : null,
    );
    final response = await cachedGet(uri, forceRefresh: forceRefresh);
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
    ApiClient.invalidateCache();
    return AttendanceSyncResult.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  Future<List<AttendanceHistoryRecord>> getHistory({int days = 30, bool forceRefresh = false}) async {
    final uri = Uri.parse("$baseUrl/api/attendance/history").replace(queryParameters: {'days': '$days'});
    final response = await cachedGet(uri, forceRefresh: forceRefresh);
    ensureSuccess(response);
    final List<dynamic> data = json.decode(response.body);
    return data.map((e) => AttendanceHistoryRecord.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Local history for an explicit date range - used by the Monthly view.
  Future<List<AttendanceHistoryRecord>> getHistoryRange(DateTime from, DateTime to, {bool forceRefresh = false}) async {
    final uri = Uri.parse("$baseUrl/api/attendance/history")
        .replace(queryParameters: {'from': _isoDate(from), 'to': _isoDate(to)});
    final response = await cachedGet(uri, forceRefresh: forceRefresh);
    ensureSuccess(response);
    final List<dynamic> data = json.decode(response.body);
    return data.map((e) => AttendanceHistoryRecord.fromJson(e as Map<String, dynamic>)).toList();
  }

  String _isoDate(DateTime d) => "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
}
