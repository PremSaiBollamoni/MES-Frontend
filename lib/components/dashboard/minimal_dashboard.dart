import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/theme_tokens.dart';

/// A quiet placeholder for roles whose real PALMS module isn't built yet
/// (Operator's own piece count/efficiency, QC's defect log, Store Keeper's
/// packing/RTM/dispatch stock all come with later PALMS phases). Deliberately
/// honest - no invented numbers standing in for a module that doesn't exist.
class MinimalDashboard extends StatelessWidget {
  final String message;

  const MinimalDashboard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hourglass_empty_rounded, color: ThemeTokens.textLight, size: 34),
            const SizedBox(height: 16.0),
            Text(L10n.of(context).nothingToShowYet, style: ThemeTokens.headingMedium.copyWith(fontSize: 16), textAlign: TextAlign.center),
            const SizedBox(height: 8.0),
            Text(message, style: ThemeTokens.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
