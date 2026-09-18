import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the app's chosen language and persists it across launches.
///
/// A ValueNotifier rather than a full state-management package: the locale is a single
/// value read at the very top of the widget tree, so MaterialApp can simply rebuild
/// itself when it changes. Every screen below picks up the new language automatically.
class LocaleController {
  static const _prefsKey = 'app_locale';

  static final LocaleController _instance = LocaleController._internal();
  factory LocaleController() => _instance;
  LocaleController._internal();

  /// Languages the app ships with. Adding another means adding an .arb file and
  /// one entry here - no screen needs touching.
  static const List<Locale> supported = [
    Locale('en'),
    Locale('te'),
  ];

  final ValueNotifier<Locale> locale = ValueNotifier(const Locale('en'));

  /// Restores the saved language. Call once before runApp so the first frame is
  /// already in the right language rather than flashing English first.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code != null && supported.any((l) => l.languageCode == code)) {
      locale.value = Locale(code);
    }
  }

  Future<void> setLocale(Locale value) async {
    if (locale.value == value) return;
    locale.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, value.languageCode);
  }

  /// Human-readable name for a language, written in that language itself - a Telugu
  /// speaker should see "తెలుగు", not the English word "Telugu".
  static String nameOf(Locale l) {
    switch (l.languageCode) {
      case 'te':
        return 'తెలుగు';
      case 'en':
      default:
        return 'English';
    }
  }
}
