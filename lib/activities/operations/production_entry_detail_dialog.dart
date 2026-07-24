import 'package:flutter/material.dart';
import '../../models/production_entry.dart';
import '../../utils/theme_tokens.dart';
import 'operations_widgets.dart';
import 'tracking_stat_tile.dart';

/// Read-only full-detail view for a single logged production entry, opened
/// from a tap on its row in Production Entry (the row itself only shows a
/// truncated subset).
Future<void> showProductionEntryDetailDialog(BuildContext context, ProductionEntry entry) {
  final color = classificationColor(entry.classification);
  return showDialog(
    context: context,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.employeeName, style: ThemeTokens.headingMedium.copyWith(fontSize: 18), overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4.0),
                      Text("${entry.stationNumber} · ${entry.operationName}", style: ThemeTokens.caption, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                  decoration: BoxDecoration(color: color.withOpacity(0.14), borderRadius: BorderRadius.circular(ThemeTokens.radiusPill)),
                  child: Text(entry.classification, style: ThemeTokens.labelSmall.copyWith(color: color, fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 4.0),
            Text(entry.shiftDate, style: ThemeTokens.caption.copyWith(color: ThemeTokens.textLight)),
            const SizedBox(height: 20.0),
            Row(
              children: [
                Expanded(child: TrackingStatTile(label: "Pieces Produced", value: "${entry.piecesProduced}")),
                const SizedBox(width: 12.0),
                Expanded(child: TrackingStatTile(label: "Time on Machine", value: "${entry.timeOnMachineMinutes.toStringAsFixed(1)} min")),
              ],
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(child: TrackingStatTile(label: "Efficiency", value: "${entry.efficiencyPct.toStringAsFixed(1)}%", valueColor: color)),
                const SizedBox(width: 12.0),
                Expanded(child: TrackingStatTile(label: "Wages Earned", value: "₹${entry.wagesEarned.toStringAsFixed(2)}", valueColor: ThemeTokens.success)),
              ],
            ),
            const SizedBox(height: 20.0),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Close")),
            ),
          ],
        ),
      ),
    ),
  );
}
