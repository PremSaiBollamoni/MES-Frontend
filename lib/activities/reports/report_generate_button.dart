import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/theme_tokens.dart';

/// The Generate button for a report type screen, split out to keep that file under the
/// project's 200-line convention.
class ReportGenerateButton extends StatelessWidget {
  final bool generating;
  final VoidCallback onPressed;

  const ReportGenerateButton({super.key, required this.generating, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: generating ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeTokens.primary,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium)),
        ),
        child: generating
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                  const SizedBox(width: 12.0),
                  Text(L10n.of(context).generatingAiReportThisCan, style: ThemeTokens.buttonText),
                ],
              )
            : Text(L10n.of(context).generateReport, style: ThemeTokens.buttonText),
      ),
    );
  }
}
