import 'package:flutter/material.dart';
import '../../utils/theme_tokens.dart';

/// Espresso "ledger" hero - a headline figure in gold serif over a
/// hairline-divided row of secondary stats. Shared across every role
/// dashboard so they all read as the same product with different data.
class LedgerHero extends StatelessWidget {
  final String eyebrow;
  final String value;
  final List<({String value, String label})> stats;

  const LedgerHero({super.key, required this.eyebrow, required this.value, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28.0),
      decoration: BoxDecoration(color: ThemeTokens.ink, borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(eyebrow.toUpperCase(), style: ThemeTokens.labelSmall.copyWith(color: ThemeTokens.textLight)),
          const SizedBox(height: 10.0),
          Text(value, style: ThemeTokens.headingDisplay.copyWith(color: ThemeTokens.accentLight, fontSize: 52)),
          if (stats.isNotEmpty) ...[
            const SizedBox(height: 22.0),
            const Divider(color: ThemeTokens.inkDivider, height: 1),
            const SizedBox(height: 18.0),
            Row(
              children: [
                for (var i = 0; i < stats.length; i++) ...[
                  if (i > 0) Container(width: 1, height: 34, color: ThemeTokens.inkDivider, margin: const EdgeInsets.only(right: 16.0)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(stats[i].value, style: ThemeTokens.headingLarge.copyWith(color: ThemeTokens.onInk, fontSize: 22)),
                        const SizedBox(height: 2.0),
                        Text(stats[i].label.toUpperCase(), style: ThemeTokens.labelSmall.copyWith(color: ThemeTokens.textLight, fontSize: 10)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
