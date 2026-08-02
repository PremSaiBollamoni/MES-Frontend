import 'package:flutter/material.dart';
import '../../utils/operation_names.dart';
import '../../l10n/app_localizations.dart';
import '../../models/bundle.dart';
import '../../utils/theme_tokens.dart';
import 'operations_widgets.dart';

/// Active-bundles tab body for WipBundleScreen - split out to keep the
/// screen file under the 200-line limit.
class BundleListView extends StatelessWidget {
  final List<Bundle> bundles;
  final Future<void> Function() onRefresh;
  final ValueChanged<Bundle> onMove;
  final ValueChanged<Bundle> onComplete;

  const BundleListView({super.key, required this.bundles, required this.onRefresh, required this.onMove, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    if (bundles.isEmpty) {
      return OpsStateMessage(icon: Icons.move_down_outlined, title: L10n.of(context).noActiveBundles, body: L10n.of(context).tapToCreateOne);
    }
    return RefreshIndicator(
      color: ThemeTokens.primary,
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 96),
        itemCount: bundles.length,
        itemBuilder: (context, index) {
          final b = bundles[index];
          return Container(
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
                      Text("${b.bundleRef}  ·  ${b.quantity} pcs", style: ThemeTokens.headingMedium.copyWith(fontSize: 15)),
                      const SizedBox(height: 4.0),
                      Text(b.currentStationNumber != null ? "At ${b.currentStationNumber} · ${b.currentOperationName}" : b.status, style: ThemeTokens.caption),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.arrow_forward_rounded, color: ThemeTokens.primary), onPressed: () => onMove(b)),
                IconButton(icon: const Icon(Icons.check_circle_outline_rounded, color: ThemeTokens.success), onPressed: () => onComplete(b)),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Station-queues tab body for WipBundleScreen.
class StationQueueListView extends StatelessWidget {
  final List<StationWipSummary> summary;
  final Future<void> Function() onRefresh;

  const StationQueueListView({super.key, required this.summary, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (summary.isEmpty) {
      return OpsStateMessage(icon: Icons.dashboard_customize_outlined, title: L10n.of(context).noQueueData, body: L10n.of(context).moveSomeBundlesToSee);
    }
    return RefreshIndicator(
      color: ThemeTokens.primary,
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        itemCount: summary.length,
        itemBuilder: (context, index) {
          final s = summary[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 10.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: ThemeTokens.surfaceSolid,
              borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
              border: Border.all(color: s.alertTriggered ? ThemeTokens.error.withOpacity(0.5) : ThemeTokens.hairline),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(OperationNames.display(context, s.operationName), style: ThemeTokens.headingMedium.copyWith(fontSize: 15), overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4.0),
                      Text(s.stationNumber, style: ThemeTokens.caption),
                    ],
                  ),
                ),
                Text(
                  "${s.bundleCount}",
                  style: ThemeTokens.headingLarge.copyWith(fontSize: 20, color: s.alertTriggered ? ThemeTokens.error : ThemeTokens.textPrimary),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
