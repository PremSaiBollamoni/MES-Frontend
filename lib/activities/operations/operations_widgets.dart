import 'package:flutter/material.dart';
import '../../utils/theme_tokens.dart';

/// Shared date helpers/widgets for the Operations screens - every one of them
/// works off a "shift date" the Supervisor can page through.
String formatIsoDate(DateTime d) {
  final mm = d.month.toString().padLeft(2, '0');
  final dd = d.day.toString().padLeft(2, '0');
  return "${d.year}-$mm-$dd";
}

String formatLongDate(DateTime d) {
  const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
  return "${d.day} ${months[d.month - 1]} ${d.year}";
}

class OpsDatePickerBar extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  const OpsDatePickerBar({super.key, required this.date, required this.onChanged});

  Future<void> _pick(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
      onTap: () => _pick(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 15.0),
        decoration: BoxDecoration(
          color: ThemeTokens.surfaceSolid,
          borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
          border: Border.all(color: ThemeTokens.hairline),
        ),
        child: Row(
          children: [
            const Icon(Icons.event_rounded, size: 19, color: ThemeTokens.primary),
            const SizedBox(width: 12.0),
            Expanded(child: Text(formatLongDate(date), style: ThemeTokens.bodyLarge.copyWith(fontSize: 14.5))),
            Text("CHANGE", style: ThemeTokens.labelSmall.copyWith(color: ThemeTokens.primary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class OpsStateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Widget? action;

  const OpsStateMessage({super.key, required this.icon, required this.title, required this.body, this.action});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: ThemeTokens.textLight, size: 34),
            const SizedBox(height: 14.0),
            Text(title, style: ThemeTokens.headingMedium.copyWith(fontSize: 16), textAlign: TextAlign.center),
            const SizedBox(height: 8.0),
            Text(body, style: ThemeTokens.bodyMedium, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 16.0), action!],
          ],
        ),
      ),
    );
  }
}

Color classificationColor(String classification) {
  switch (classification) {
    case 'EXCELLENT':
      return ThemeTokens.success;
    case 'GOOD':
      return ThemeTokens.primary;
    case 'MARGINAL':
      return ThemeTokens.warning;
    case 'LOW':
    case 'CRITICAL':
      return ThemeTokens.error;
    default:
      return ThemeTokens.textSecondary;
  }
}
