import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/report.dart';
import '../../utils/theme_tokens.dart';

/// Daily/Monthly toggle for reports that support both (currently only Attendance), plus the
/// "this covers the whole month of X" caption shown whenever the selected period is monthly -
/// including for always-monthly reports (Earnings), which never show the toggle itself.
class ReportPeriodSelector extends StatelessWidget {
  final bool showToggle;
  final ReportPeriod period;
  final ValueChanged<ReportPeriod> onChanged;
  final String monthLabel;

  const ReportPeriodSelector({
    super.key,
    required this.showToggle,
    required this.period,
    required this.onChanged,
    required this.monthLabel,
  });

  @override
  Widget build(BuildContext context) {
    final t = L10n.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showToggle) ...[
          Row(
            children: [
              Expanded(child: _chip(t.periodDaily, ReportPeriod.daily)),
              const SizedBox(width: 10.0),
              Expanded(child: _chip(t.periodMonthly, ReportPeriod.monthly)),
            ],
          ),
          const SizedBox(height: 10.0),
        ],
        if (period == ReportPeriod.monthly)
          Text("${t.reportCoversFullMonth} $monthLabel", style: ThemeTokens.caption.copyWith(fontStyle: FontStyle.italic)),
      ],
    );
  }

  Widget _chip(String label, ReportPeriod value) {
    final selected = period == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          color: selected ? ThemeTokens.primary : ThemeTokens.surfaceSolid,
          borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
          border: Border.all(color: selected ? ThemeTokens.primary : ThemeTokens.hairline),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: ThemeTokens.bodyLarge.copyWith(fontSize: 13.5, color: selected ? Colors.white : ThemeTokens.textPrimary),
        ),
      ),
    );
  }
}
