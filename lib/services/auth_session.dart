import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

/// Holds the current session's JWT + user, both in memory for the rest of this
/// run and persisted to disk so a login survives an app restart. Call [restore]
/// once at startup (before deciding whether to show the login screen) to load
/// any previously saved session back into memory.
class AuthSession {
  static final AuthSession _instance = AuthSession._internal();
  factory AuthSession() => _instance;
  AuthSession._internal();

  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  String? _token;
  UserModel? _user;

  String? get token => _token;
  UserModel? get user => _user;

  Future<void> save(String token, UserModel user) async {
    _token = token;
    _user = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }

  /// Loads a previously saved session (if any) into memory. Returns the
  /// restored user, or null if there's nothing saved.
  Future<UserModel?> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final userJson = prefs.getString(_userKey);
    if (token == null || userJson == null) return null;
    _token = token;
    _user = UserModel.fromJson(json.decode(userJson) as Map<String, dynamic>);
    return _user;
  }

  Future<void> clear() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
