import 'package:flutter/widgets.dart';
import '../l10n/app_localizations.dart';

/// Translates backend error codes into the user's language.
///
/// The backend is deliberately language-agnostic: it returns a stable code such as
/// ERR_NO_ACCESS plus an English fallback, and the translation lives here. That keeps
/// every translated string in the app's own .arb files, so adding a language never needs
/// a backend change or redeploy.
///
/// Errors are thrown as "CODE|English text" by the API client, since exceptions travel
/// through layers that have no BuildContext to translate with. This splits that apart at
/// the point of display, where a context is available.
class ErrorMessages {
  const ErrorMessages._();

  static const String separator = '|';

  /// Packs a code and its English fallback into a single exception message.
  static String pack(String? code, String fallback) =>
      code == null || code.isEmpty ? fallback : '$code$separator$fallback';

  /// Renders a thrown error in the user's language.
  ///
  /// Unknown codes fall back to the English text the backend supplied, so a backend
  /// newer than the app degrades to readable English rather than showing a raw code.
  static String translate(BuildContext context, Object error) {
    final raw = error.toString().replaceAll('Exception: ', '');
    final index = raw.indexOf(separator);
    if (index <= 0) return raw;

    final code = raw.substring(0, index);
    final fallback = raw.substring(index + 1);
    if (!code.startsWith('ERR_')) return raw;

    final t = L10n.of(context);
    switch (code) {
      case 'ERR_NO_ACCESS':
        return t.errNoAccess;
      case 'ERR_SESSION_INVALID':
        return t.errSessionInvalid;
      case 'ERR_PIECES_NEGATIVE':
        return t.errPiecesNegative;
      case 'ERR_TIME_NOT_POSITIVE':
        return t.errTimeNotPositive;
      case 'ERR_TIME_REQUIRED':
        return t.errTimeRequired;
      case 'ERR_END_BEFORE_START':
        return t.errEndBeforeStart;
      case 'ERR_SCAN_DISABLED':
        return 'Page scanning is not configured on the server';
      case 'ERR_SCAN_UNREADABLE':
        return 'Could not read this page - try a clearer photo';
      case 'ERR_SCAN_DATE_REQUIRED':
        return 'Set the date for this page before saving';
      case 'ERR_SCAN_HOUR_INVALID':
        return 'Hour must be between 1 and 8';
      case 'ERR_SCAN_FAILED':
        return 'Scanning failed - please try again';
      case 'ERR_TIME_OVERLAP':
        return t.errTimeOverlap;
      case 'ERR_EMPLOYEE_NOT_FOUND':
        return t.errEmployeeNotFound;
      case 'ERR_STATION_NOT_FOUND':
        return t.errStationNotFound;
      case 'ERR_HRMS_NOT_CONFIGURED':
        return t.errHrmsNotConfigured;
      case 'ERR_HRMS_UNREACHABLE':
        return t.errHrmsUnreachable;
      case 'ERR_HRMS_REJECTED':
        return t.errHrmsRejected;
      case 'ERR_REPORTS_DISABLED':
        return t.errReportsDisabled;
      case 'ERR_REPORT_FAILED':
        return t.errReportFailed;
      case 'ERR_EDIT_LIMIT_REACHED':
        return t.errEditLimitReached;
      default:
        return fallback;
    }
  }
}
