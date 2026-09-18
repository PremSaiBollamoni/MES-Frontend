import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/production_entry.dart';
import '../utils/operation_names.dart';
import '../utils/theme_tokens.dart';
import 'operations/operations_widgets.dart';

/// The date being viewed, with previous/next arrows and a tap-to-pick calendar. Next is
/// disabled once the date reaches today - there is never a reason to look ahead at work not
/// yet done.
class DailyProductionDateBar extends StatelessWidget {
  final DateTime date;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;
  final VoidCallback onPickDate;

  const DailyProductionDateBar({
    super.key,
    required this.date,
    required this.onPrevious,
    required this.onNext,
    required this.onPickDate,
  });

  @override
  Widget build(BuildContext context) {
    final label = DateFormat.yMMMEd(Localizations.localeOf(context).languageCode).format(date);
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
      decoration: const BoxDecoration(
        color: ThemeTokens.background,
        border: Border(bottom: BorderSide(color: ThemeTokens.hairline)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left_rounded, color: ThemeTokens.textSecondary),
          ),
          Expanded(
            child: InkWell(
              onTap: onPickDate,
              borderRadius: BorderRadius.circular(ThemeTokens.radiusSmall),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 15, color: ThemeTokens.primary),
                    const SizedBox(width: 8.0),
                    Text(label, style: ThemeTokens.bodyLarge.copyWith(fontSize: 15)),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onNext,
            icon: Icon(Icons.chevron_right_rounded,
                color: onNext == null ? ThemeTokens.hairline : ThemeTokens.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Totals for the entries on the currently viewed date - answers "how was that day" before
/// the reader scrolls into the individual entries below it.
class DailyProductionTotals extends StatelessWidget {
  final List<ProductionEntry> entries;

  const DailyProductionTotals({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    final t = L10n.of(context);
    final pieces = entries.fold<int>(0, (sum, e) => sum + e.piecesProduced);
    final wages = entries.fold<double>(0, (sum, e) => sum + e.wagesEarned);
    final avgEfficiency =
        entries.fold<double>(0, (sum, e) => sum + e.efficiencyPct) / entries.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: ThemeTokens.ink,
        borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.dayTotal.toUpperCase(),
                    style: ThemeTokens.labelSmall.copyWith(fontSize: 9, color: ThemeTokens.textLight)),
                const SizedBox(height: 4.0),
                Text('₹${wages.toStringAsFixed(0)}',
                    style: ThemeTokens.headingLarge.copyWith(color: ThemeTokens.accentLight, fontSize: 24)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$pieces', style: ThemeTokens.headingMedium.copyWith(color: Colors.white, fontSize: 18)),
              Text(t.piecesProduced, style: ThemeTokens.caption.copyWith(fontSize: 9.5)),
            ],
          ),
          const SizedBox(width: 16.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${avgEfficiency.toStringAsFixed(0)}%',
                  style: ThemeTokens.headingMedium.copyWith(color: Colors.white, fontSize: 18)),
              Text(t.efficiency, style: ThemeTokens.caption.copyWith(fontSize: 9.5)),
            ],
          ),
        ],
      ),
    );
  }
}

/// One production entry for the day, tappable through to the same full-detail dialog used
/// elsewhere in the app - one consistent place that explains a figure, not a second copy of it.
class DailyProductionRow extends StatelessWidget {
  final ProductionEntry entry;
  final VoidCallback onTap;

  const DailyProductionRow({super.key, required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = classificationColor(entry.classification);
    final times = entry.startLabel == null ? null : '${entry.startLabel} – ${entry.endLabel}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ThemeTokens.radiusSmall),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: ThemeTokens.surfaceSolid,
            borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
            border: Border.all(color: ThemeTokens.hairline),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.stationNumber} · ${OperationNames.display(context, entry.operationName)}',
                      style: ThemeTokens.bodyMedium.copyWith(fontSize: 13.5),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3.0),
                    Text(
                      times == null
                          ? '${entry.piecesProduced} pcs  ·  ₹${entry.wagesEarned.toStringAsFixed(0)}'
                          : '$times  ·  ${entry.piecesProduced} pcs  ·  ₹${entry.wagesEarned.toStringAsFixed(0)}',
                      style: ThemeTokens.caption.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10.0),
              Text('${entry.efficiencyPct.round()}%',
                  style: ThemeTokens.headingMedium.copyWith(fontSize: 15, color: color)),
              const SizedBox(width: 4.0),
              const Icon(Icons.chevron_right_rounded, size: 16, color: ThemeTokens.textLight),
            ],
          ),
        ),
      ),
    );
  }
}
