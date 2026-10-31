import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/operation_names.dart';
import '../../utils/theme_tokens.dart';

/// The station/pieces/time inputs for [EditProductionEntryDialog], split out to keep both
/// files under the project's 200-line convention.
class EditProductionEntryForm extends StatelessWidget {
  final TextEditingController piecesController;
  final TextEditingController colourController;
  final String? stationNumber;
  final String? operationName;
  final bool isLoadingStations;
  final VoidCallback onPickStation;
  final bool hasTimes;
  final TimeOfDay? start;
  final TimeOfDay? end;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final String? error;

  const EditProductionEntryForm({
    super.key,
    required this.piecesController,
    required this.colourController,
    required this.stationNumber,
    required this.operationName,
    required this.isLoadingStations,
    required this.onPickStation,
    required this.hasTimes,
    required this.start,
    required this.end,
    required this.onPickStart,
    required this.onPickEnd,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    final t = L10n.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: isLoadingStations ? null : onPickStation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: ThemeTokens.surfaceSolid,
              borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
              border: Border.all(color: ThemeTokens.hairline),
            ),
            child: Row(
              children: [
                const Icon(Icons.factory_rounded, size: 18, color: ThemeTokens.primary),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Text(
                    stationNumber == null
                        ? t.select
                        : '$stationNumber · ${OperationNames.display(context, operationName!)}',
                    style: ThemeTokens.bodyLarge.copyWith(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12.0),
        TextField(
          controller: piecesController,
          keyboardType: TextInputType.number,
          style: ThemeTokens.headingMedium.copyWith(fontSize: 22),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            labelText: t.piecesProduced.toUpperCase(),
            labelStyle: ThemeTokens.labelSmall.copyWith(fontSize: 9.5),
            filled: true,
            fillColor: ThemeTokens.surfaceSolid,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium)),
          ),
        ),
        const SizedBox(height: 12.0),
        TextField(
          controller: colourController,
          textCapitalization: TextCapitalization.words,
          style: ThemeTokens.bodyLarge.copyWith(fontSize: 15),
          decoration: InputDecoration(
            labelText: "${t.colour.toUpperCase()} *",
            labelStyle: ThemeTokens.labelSmall.copyWith(fontSize: 9.5),
            filled: true,
            fillColor: ThemeTokens.surfaceSolid,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium)),
          ),
        ),
        if (hasTimes) ...[
          const SizedBox(height: 12.0),
          Row(
            children: [
              Expanded(child: _timeField(t.startTime, start, onPickStart)),
              const SizedBox(width: 10.0),
              Expanded(child: _timeField(t.endTime, end, onPickEnd)),
            ],
          ),
        ],
        if (error != null) ...[
          const SizedBox(height: 12.0),
          Text(error!, style: ThemeTokens.caption.copyWith(color: ThemeTokens.error), textAlign: TextAlign.center),
        ],
      ],
    );
  }

  static Widget actions({
    required BuildContext context,
    required bool isSaving,
    required VoidCallback onCancel,
    required VoidCallback onSave,
  }) {
    final t = L10n.of(context);
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: isSaving ? null : onCancel,
            child: Text(t.cancel),
          ),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: ElevatedButton(
            onPressed: isSaving ? null : onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeTokens.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium)),
            ),
            child: isSaving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(t.save, style: ThemeTokens.buttonText),
          ),
        ),
      ],
    );
  }

  Widget _timeField(String label, TimeOfDay? time, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: ThemeTokens.surfaceSolid,
          borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
          border: Border.all(color: ThemeTokens.hairline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: ThemeTokens.labelSmall.copyWith(fontSize: 8.5)),
            const SizedBox(height: 3.0),
            Row(
              children: [
                const Icon(Icons.schedule_rounded, size: 15, color: ThemeTokens.primary),
                const SizedBox(width: 6.0),
                Text(
                  time == null ? '--:--' : '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                  style: ThemeTokens.bodyLarge.copyWith(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
