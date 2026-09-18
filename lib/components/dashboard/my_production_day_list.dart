import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/operation_names.dart';
import '../../utils/theme_tokens.dart';
import '../../activities/operations/operations_widgets.dart';
import '../../models/production_entry.dart';
import 'my_production_grouping.dart';

/// Recent entries grouped by day, each day collapsed to a summary row that expands to its
/// individual entries on tap. Replaces one long flat scroll - across 30 days an operator can
/// have 50+ rows, and finding "how did I do on the 9th" in a flat list means reading dates one
/// row at a time.
class MyProductionDayList extends StatelessWidget {
  final List<DayGroup> days;
  final int initialVisible;

  const MyProductionDayList({super.key, required this.days, this.initialVisible = 5});

  @override
  Widget build(BuildContext context) {
    return _ExpandableDayList(days: days, initialVisible: initialVisible);
  }
}

class _ExpandableDayList extends StatefulWidget {
  final List<DayGroup> days;
  final int initialVisible;
  const _ExpandableDayList({required this.days, required this.initialVisible});

  @override
  State<_ExpandableDayList> createState() => _ExpandableDayListState();
}

class _ExpandableDayListState extends State<_ExpandableDayList> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final t = L10n.of(context);
    final visible = _showAll ? widget.days : widget.days.take(widget.initialVisible).toList();
    final hidden = widget.days.length - visible.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...visible.map((day) => _DayTile(day: day)),
        if (hidden > 0)
          TextButton(
            onPressed: () => setState(() => _showAll = true),
            child: Text('${t.recentEntries.toLowerCase()} (+$hidden more)'.trim()),
          ),
      ],
    );
  }
}

class _DayTile extends StatefulWidget {
  final DayGroup day;
  const _DayTile({required this.day});

  @override
  State<_DayTile> createState() => _DayTileState();
}

class _DayTileState extends State<_DayTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final day = widget.day;
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: ThemeTokens.surfaceSolid,
        borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
        border: Border.all(color: ThemeTokens.hairline),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(day.date, style: ThemeTokens.bodyLarge.copyWith(fontSize: 14)),
                        const SizedBox(height: 2.0),
                        Text('${day.pieces} pcs  ·  ${day.entries.length} entries',
                            style: ThemeTokens.caption),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('₹${day.wages.toStringAsFixed(0)}',
                          style: ThemeTokens.headingMedium
                              .copyWith(fontSize: 15, color: ThemeTokens.success)),
                      Text('${day.avgEfficiency.toStringAsFixed(0)}% avg',
                          style: ThemeTokens.caption.copyWith(fontSize: 10)),
                    ],
                  ),
                  const SizedBox(width: 6.0),
                  Icon(_expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                      color: ThemeTokens.textLight, size: 20),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Column(
                children: day.entries.map((e) => _EntryLine(entry: e)).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _EntryLine extends StatelessWidget {
  final ProductionEntry entry;
  const _EntryLine({required this.entry});

  @override
  Widget build(BuildContext context) {
    final color = classificationColor(entry.classification);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: ThemeTokens.hairline)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${entry.stationNumber} · ${OperationNames.display(context, entry.operationName)} · ${entry.piecesProduced} pcs',
              style: ThemeTokens.caption.copyWith(fontSize: 11.5),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text('₹${entry.wagesEarned.toStringAsFixed(0)}',
              style: ThemeTokens.caption.copyWith(fontSize: 11, color: ThemeTokens.success)),
          const SizedBox(width: 8.0),
          Text('${entry.efficiencyPct.toStringAsFixed(0)}%',
              style: ThemeTokens.labelSmall.copyWith(color: color, fontSize: 10.5)),
        ],
      ),
    );
  }
}
