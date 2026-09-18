import 'package:flutter/material.dart';
import '../../components/confirm_dialog.dart';
import '../../components/custom_toast.dart';
import '../../services/production_entry_api_service.dart';
import '../../utils/error_messages.dart';
import '../../utils/employee_names.dart';
import '../../utils/operation_names.dart';
import '../../l10n/app_localizations.dart';
import '../../models/production_entry.dart';
import '../../utils/theme_tokens.dart';
import 'edit_production_entry_dialog.dart';
import 'operations_widgets.dart';
import 'tracking_stat_tile.dart';

/// Read-only full-detail view for a single logged production entry, opened
/// from a tap on its row in Production Entry (the row itself only shows a
/// truncated subset).
Future<bool?> showProductionEntryDetailDialog(BuildContext context, ProductionEntry entry) {
  final color = classificationColor(entry.classification);
  return showDialog<bool>(
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
                      Text(EmployeeNames.display(context, entry.employeeName), style: ThemeTokens.headingMedium.copyWith(fontSize: 18), overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4.0),
                      Text("${entry.stationNumber} · ${OperationNames.display(context, entry.operationName)}", style: ThemeTokens.caption, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(ThemeTokens.radiusPill)),
                  child: Text(entry.classification, style: ThemeTokens.labelSmall.copyWith(color: color, fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 4.0),
            Text(
              // Show the clock times when the entry has them; older entries logged
              // before hourly slots existed only have a date.
              entry.startLabel == null
                  ? entry.shiftDate
                  : "${entry.shiftDate}   ·   ${entry.startLabel} - ${entry.endLabel}",
              style: ThemeTokens.caption.copyWith(color: ThemeTokens.textLight),
            ),
            if (entry.colour != null && entry.colour!.isNotEmpty) ...[
              const SizedBox(height: 4.0),
              Text("${L10n.of(context).colour}: ${entry.colour}", style: ThemeTokens.caption),
            ],
            const SizedBox(height: 20.0),
            Row(
              children: [
                Expanded(child: TrackingStatTile(label: L10n.of(context).piecesProduced, value: "${entry.piecesProduced}")),
                const SizedBox(width: 12.0),
                Expanded(child: TrackingStatTile(label: L10n.of(context).timeOnMachine, value: "${entry.timeOnMachineMinutes.toStringAsFixed(1)} min")),
              ],
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(child: TrackingStatTile(label: L10n.of(context).efficiency, value: "${entry.efficiencyPct.toStringAsFixed(1)}%", valueColor: color)),
                const SizedBox(width: 12.0),
                Expanded(child: TrackingStatTile(label: L10n.of(context).wagesEarned, value: "₹${entry.wagesEarned.toStringAsFixed(2)}", valueColor: ThemeTokens.success)),
              ],
            ),
            if (!entry.canEdit) ...[
              const SizedBox(height: 14.0),
              Text(L10n.of(context).correctionLimitReached,
                  style: ThemeTokens.caption.copyWith(color: ThemeTokens.textLight, fontSize: 10.5)),
            ],
            const SizedBox(height: 20.0),
            Row(
              children: [
                // Destructive, so it sits apart from Close and asks first. This is the only way
                // back from a scanned page confirmed against the wrong date or operator.
                TextButton(
                  onPressed: () => _deleteEntry(context, entry),
                  child: Text(L10n.of(context).delete,
                      style: const TextStyle(color: ThemeTokens.error)),
                ),
                if (entry.canEdit)
                  TextButton(
                    onPressed: () => _editEntry(context, entry),
                    child: Text('${L10n.of(context).editEntryLabel} (${entry.editsRemaining})'),
                  ),
                const Spacer(),
                TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(L10n.of(context).close)),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

/// Opens the correction form. Returns to the caller with true so the day totals refresh -
/// pieces, station or duration may all have just changed.
Future<void> _editEntry(BuildContext context, ProductionEntry entry) async {
  final edited = await showEditProductionEntryDialog(context, entry);
  if (edited == true && context.mounted) {
    Navigator.of(context).pop(true);
  }
}

/// Confirms, then removes the entry. Returns to the caller with true so the day totals refresh.
Future<void> _deleteEntry(BuildContext context, ProductionEntry entry) async {
  final confirmed = await showConfirmDialog(
    context,
    title: L10n.of(context).delete,
    message: '${entry.piecesProduced} pieces at ${entry.stationNumber} on ${entry.shiftDate}'
        ' will be removed from the production log.',
  );
  if (confirmed != true || !context.mounted) return;

  try {
    await ProductionEntryApiService().delete(entry.id);
    if (!context.mounted) return;
    Navigator.of(context).pop(true);
    CustomToast.show(context, 'Entry deleted');
  } catch (e) {
    if (!context.mounted) return;
    CustomToast.show(context, ErrorMessages.translate(context, e), isError: true);
  }
}
