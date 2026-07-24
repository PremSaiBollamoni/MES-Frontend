import 'package:flutter/material.dart';
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

  String _formatDate(String iso) {
    try {
      return formatLongDate(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }

  String _formatTimestamp(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final hh = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      return "${_formatDate(iso)} at $hh:$mm";
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
              tooltip: "Regenerate",
              icon: const Icon(Icons.refresh_rounded, color: ThemeTokens.textLight, size: 20),
              onPressed: onRegenerate,
            ),
          ],
        ),
      ),
    );
  }
}
