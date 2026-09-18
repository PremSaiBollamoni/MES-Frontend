import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/scanned_page.dart';
import '../../models/station.dart';
import '../../utils/operation_names.dart';
import '../../utils/theme_tokens.dart';
import 'entry_pickers.dart';
import 'scan_widgets.dart';

/// One reviewable hour from a scanned page.
///
/// Rows needing attention are outlined rather than merely tinted: at a fortnight of pages the
/// supervisor is scanning for the exceptions, and those have to be findable without reading.
class ScanRowCard extends StatelessWidget {
  final ScannedRow row;
  final List<Station> stations;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  const ScanRowCard({
    super.key,
    required this.row,
    required this.stations,
    required this.onChanged,
    required this.onRemove,
  });

  Future<void> _pickStation(BuildContext context) async {
    final chosen = await pickStation(context, stations, row.stationId);
    if (chosen == null) return;
    row.stationId = chosen.id;
    row.stationName = chosen.operationName;
    onChanged();
  }

  Future<void> _editPieces(BuildContext context) async {
    final controller = TextEditingController(text: row.pieces.join(', '));
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(L10n.of(context).piecesProduced),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            helperText: 'Separate several counts with a comma',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(L10n.of(context).cancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(L10n.of(context).save),
          ),
        ],
      ),
    );
    if (result == null) return;
    // Anything that isn't a positive number is dropped rather than saved as zero - a count the
    // supervisor mistyped should disappear and be re-entered, not silently become nothing.
    row.pieces = result
        .split(',')
        .map((p) => int.tryParse(p.trim()))
        .whereType<int>()
        .where((p) => p > 0)
        .toList();
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final needsAttention = row.needsAttention;
    final hourLabel = row.hour >= 1 && row.hour <= kShiftHourLabels.length
        ? kShiftHourLabels[row.hour - 1]
        : 'Hour ${row.hour}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      decoration: BoxDecoration(
        color: ThemeTokens.surfaceSolid,
        borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
        border: Border.all(
          color: needsAttention ? ThemeTokens.warning : ThemeTokens.hairline,
          width: needsAttention ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: ThemeTokens.ink,
                    borderRadius: BorderRadius.circular(ThemeTokens.radiusSmall),
                  ),
                  child: Text('${row.hour}',
                      style: ThemeTokens.labelSmall.copyWith(color: Colors.white, fontSize: 11)),
                ),
                const SizedBox(width: 10.0),
                Expanded(child: Text(hourLabel, style: ThemeTokens.caption)),
                if (row.carriedForward)
                  Text('carried', style: ThemeTokens.caption.copyWith(fontSize: 10)),
                InkWell(
                  onTap: onRemove,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(Icons.close_rounded, size: 16, color: ThemeTokens.textLight),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: InkWell(
                    onTap: () => _pickStation(context),
                    child: ScanFieldChip(
                      label: L10n.of(context).station,
                      value: row.stationName == null
                          ? 'Tap to choose'
                          : OperationNames.display(context, row.stationName!),
                      missing: row.stationId == null,
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  flex: 2,
                  child: InkWell(
                    onTap: () => _editPieces(context),
                    child: ScanFieldChip(
                      label: L10n.of(context).piecesProduced,
                      value: row.pieces.isEmpty ? '—' : row.pieces.join(' + '),
                      missing: row.pieces.isEmpty,
                    ),
                  ),
                ),
              ],
            ),
            if (row.rawStyle != null && row.stationId == null) ...[
              const SizedBox(height: 8.0),
              Text('Written: "${row.rawStyle}"',
                  style: ThemeTokens.caption.copyWith(fontSize: 10.5)),
            ],
            if (row.note != null) ...[
              const SizedBox(height: 8.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, size: 14, color: ThemeTokens.warning),
                  const SizedBox(width: 6.0),
                  Expanded(
                    child: Text(row.note!,
                        style: ThemeTokens.caption
                            .copyWith(fontSize: 10.5, color: ThemeTokens.warning)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

}
