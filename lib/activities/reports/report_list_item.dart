import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/report.dart';
import '../../utils/theme_tokens.dart';
import '../operations/operations_widgets.dart';

class ReportListItem extends StatelessWidget {
  final ReportSummary report;
  final VoidCallback onOpen;
  final VoidCallback onRegenerate;

  const ReportListItem({
    super.key,
    required this.report,
    required this.onOpen,
    required this.onRegenerate,
  });

  static const _months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return report.isMonthly ? "${_months[d.month - 1]} ${d.year}" : formatLongDate(d);
    } catch (_) {
      return iso;
    }
  }

  String _formatTimestamp(String iso) {
    try {
      // generatedAt comes from the backend as a naive Java LocalDateTime string (no
      // timezone marker) representing the server's UTC clock - parse it as UTC
      // explicitly, then convert to the device's local time for display, otherwise
      // it's off by the device's UTC offset (and can even land on the wrong date).
      final dt = DateTime.parse(iso.endsWith('Z') ? iso : "${iso}Z").toLocal();
      final hh = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      return "${formatLongDate(dt)} at $hh:$mm";
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
      onTap: onOpen,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 15.0),
        decoration: BoxDecoration(
          color: ThemeTokens.surfaceSolid,
          borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
          border: Border.all(color: ThemeTokens.hairline),
        ),
        child: Row(
          children: [
            const Icon(Icons.picture_as_pdf_rounded, color: ThemeTokens.primary, size: 22),
            const SizedBox(width: 14.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_formatDate(report.reportDate), style: ThemeTokens.bodyLarge.copyWith(fontSize: 14.5)),
                  const SizedBox(height: 3.0),
                  Text("Generated ${_formatTimestamp(report.generatedAt)} - ${report.modelUsed}", style: ThemeTokens.caption),
                ],
              ),
            ),
            IconButton(
              tooltip: L10n.of(context).regenerate,
              icon: const Icon(Icons.refresh_rounded, color: ThemeTokens.textLight, size: 20),
              onPressed: onRegenerate,
            ),
          ],
        ),
      ),
    );
  }
}
