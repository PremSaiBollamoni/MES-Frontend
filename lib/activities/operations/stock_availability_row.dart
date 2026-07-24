import 'package:flutter/material.dart';
import '../../models/stock_availability.dart';
import '../../utils/theme_tokens.dart';

/// One station's stock row: computed AVAILABLE/NO_STOCK/NOT_CHECKED status
/// plus the logged quantity vs the configured minimum, so the Supervisor can
/// see at a glance why a station is flagged without opening anything.
class StockAvailabilityRow extends StatelessWidget {
  final StockAvailability item;
  final bool isUpdating;
  final VoidCallback onTap;

  const StockAvailabilityRow({super.key, required this.item, required this.isUpdating, required this.onTap});

  Color get _statusColor {
    switch (item.status) {
      case 'AVAILABLE':
        return ThemeTokens.success;
      case 'LOW_STOCK':
        return ThemeTokens.warning;
      case 'HIGH_STOCK':
        return ThemeTokens.accent;
      case 'NO_STOCK':
        return ThemeTokens.error;
      default:
        return ThemeTokens.textLight;
    }
  }

  String get _quantityCaption {
    final hasMax = item.maxStockThreshold > 0;
    return hasMax
        ? "${item.currentStockQty} · min ${item.minStockThreshold} · max ${item.maxStockThreshold}"
        : "${item.currentStockQty} / ${item.minStockThreshold} min";
  }

  @override
  Widget build(BuildContext context) {
    final noThresholdSet = item.minStockThreshold == 0 && item.maxStockThreshold == 0;
    return InkWell(
      onTap: isUpdating ? null : onTap,
      borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10.0),
        padding: const EdgeInsets.all(16.0),
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
                  Text(item.operationName, style: ThemeTokens.headingMedium.copyWith(fontSize: 15), overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4.0),
                  Text("${item.stationNumber} · ${item.status}", style: ThemeTokens.caption.copyWith(color: _statusColor)),
                  const SizedBox(height: 2.0),
                  Text(
                    _quantityCaption,
                    style: ThemeTokens.caption.copyWith(color: ThemeTokens.textSecondary),
                  ),
                  if (noThresholdSet)
                    Text("no threshold set", style: ThemeTokens.caption.copyWith(color: ThemeTokens.textLight, fontSize: 11)),
                ],
              ),
            ),
            if (isUpdating)
              const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: ThemeTokens.primary))
            else
              const Icon(Icons.edit_note_rounded, color: ThemeTokens.primary),
          ],
        ),
      ),
    );
  }
}
