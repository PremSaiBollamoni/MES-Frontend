import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/theme_tokens.dart';
import 'production_entry_screen.dart';
import 'station_allocation_list_screen.dart';
import 'station_status_screen.dart';
import 'stock_availability_screen.dart';
import 'stock_position_screen.dart';
import 'wip_bundle_screen.dart';

/// Operations hub - a menu of tiles into each Production Supervisor tool
/// (allocation, station status, stock, production entry, WIP), matching the
/// AttendanceScreen hub pattern so the shell reads as one product.
class OperationsHubScreen extends StatelessWidget {
  const OperationsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      children: [
        Text(L10n.of(context).chooseAView, style: ThemeTokens.bodyMedium),
        const SizedBox(height: 20.0),
        _Tile(
          icon: Icons.assignment_ind_rounded,
          title: L10n.of(context).operatorAllocation,
          subtitle: L10n.of(context).assignOperatorsToStationsFor,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StationAllocationListScreen())),
        ),
        const SizedBox(height: 14.0),
        _Tile(
          icon: Icons.dashboard_customize_rounded,
          title: L10n.of(context).stationStatus,
          subtitle: L10n.of(context).liveMannedUnmannedBoardWith,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StationStatusScreen())),
        ),
        const SizedBox(height: 14.0),
        _Tile(
          icon: Icons.inventory_2_rounded,
          title: L10n.of(context).stockAvailability,
          subtitle: L10n.of(context).preShiftCheckIsFabric,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StockAvailabilityScreen())),
        ),
        const SizedBox(height: 14.0),
        _Tile(
          icon: Icons.stacked_line_chart_rounded,
          title: L10n.of(context).dailyStockPosition,
          subtitle: L10n.of(context).openingAdditionsDispatchedByPost,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StockPositionScreen())),
        ),
        const SizedBox(height: 14.0),
        _Tile(
          icon: Icons.speed_rounded,
          title: L10n.of(context).productionEntry,
          subtitle: L10n.of(context).logPiecesProducedOnBehalf,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProductionEntryScreen())),
        ),
        const SizedBox(height: 14.0),
        _Tile(
          icon: Icons.move_down_rounded,
          title: L10n.of(context).wipBundleTracking,
          subtitle: L10n.of(context).createBundlesMoveBetweenStations,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WipBundleScreen())),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _Tile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
      child: InkWell(
        borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: ThemeTokens.surfaceSolid,
            borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
            border: Border.all(color: ThemeTokens.hairline),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: ThemeTokens.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 23, color: ThemeTokens.primary),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: ThemeTokens.headingMedium.copyWith(fontSize: 16), overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4.0),
                    Text(subtitle, style: ThemeTokens.caption, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: ThemeTokens.textLight, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
