import 'package:shared_preferences/shared_preferences.dart';
import '../../models/report.dart';

/// Persists the last-chosen report provider/model across app restarts - a supervisor who
/// switches to a replacement OpenRouter model because the usual one is down shouldn't have
/// to re-type it every time they open a report screen.
class ReportProviderPrefs {
  static const _providerKey = 'report_provider';
  static const _modelKey = 'report_openrouter_model';

  static Future<(ReportProvider, String)> load() async {
    final prefs = await SharedPreferences.getInstance();
    final provider = prefs.getString(_providerKey) == 'OPENROUTER' ? ReportProvider.openRouter : ReportProvider.claude;
    final model = prefs.getString(_modelKey) ?? '';
    return (provider, model);
  }

  static Future<void> save(ReportProvider provider, String model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_providerKey, provider.apiValue);
    await prefs.setString(_modelKey, model);
  }
}
