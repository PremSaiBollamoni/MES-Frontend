import 'package:flutter/material.dart';
import '../../models/employee_day_activity.dart';
import '../../utils/theme_tokens.dart';
import 'operations_widgets.dart';

/// One card per employee on the Production Entry list - summarizes either
/// their live tracking session or their day's completed entries.
class EmployeeActivityCard extends StatelessWidget {
  final EmployeeDayActivity activity;
  final VoidCallback onTap;

  const EmployeeActivityCard({super.key, required this.activity, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final inProgress = activity.isInProgress;
    final color = inProgress
        ? ThemeTokens.warning
        : (activity.entries.isNotEmpty ? classificationColor(activity.entries.last.classification) : ThemeTokens.textSecondary);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
      child: InkWell(
        borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: inProgress ? ThemeTokens.warning.withOpacity(0.06) : ThemeTokens.surfaceSolid,
            borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
            border: Border.all(color: inProgress ? ThemeTokens.warning.withOpacity(0.4) : ThemeTokens.hairline),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(activity.employeeName, style: ThemeTokens.headingMedium.copyWith(fontSize: 15), overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4.0),
                    Text(activity.summaryLine, style: ThemeTokens.caption, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              if (inProgress)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: ThemeTokens.warning.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(ThemeTokens.radiusPill),
                  ),
                  child: Text("IN PROGRESS", style: ThemeTokens.labelSmall.copyWith(color: ThemeTokens.warning, fontSize: 9)),
                )
              else if (activity.entries.length == 1)
                Text(
                  "${activity.entries.first.efficiencyPct.toStringAsFixed(0)}%",
                  style: ThemeTokens.headingMedium.copyWith(fontSize: 16, color: color),
                )
              else
                Icon(Icons.chevron_right_rounded, color: ThemeTokens.textLight),
            ],
          ),
        ),
      ),
    );
  }
}
