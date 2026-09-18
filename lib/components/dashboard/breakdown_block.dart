import 'package:flutter/material.dart';
import '../../utils/theme_tokens.dart';

/// A refined breakdown - each row is a label, a right-aligned count, and a thin
/// full-width rule whose gold-filled portion shows the proportion. Not a chart.
/// Shared across role dashboards.
class BreakdownBlock extends StatelessWidget {
  final String title;
  final Map<String, int> entries;
  final int maxValue;
  final String Function(String)? labeller;
  final String Function(int)? valueFormatter;

  const BreakdownBlock({
    super.key,
    required this.title,
    required this.entries,
    required this.maxValue,
    this.labeller,
    this.valueFormatter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 18, height: 2, color: ThemeTokens.primary),
            const SizedBox(width: 10.0),
            Flexible(child: Text(title.toUpperCase(), style: ThemeTokens.labelSmall, overflow: TextOverflow.ellipsis)),
          ],
        ),
        const SizedBox(height: 18.0),
        ...entries.entries.map((e) {
          final label = labeller != null ? labeller!(e.key) : e.key;
          final displayValue = valueFormatter != null ? valueFormatter!(e.value) : "${e.value}";
          final fraction = maxValue == 0 ? 0.0 : (e.value / maxValue).clamp(0.0, 1.0);
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: Text(label, style: ThemeTokens.bodyLarge.copyWith(fontSize: 14))),
                    Text(displayValue, style: ThemeTokens.headingMedium.copyWith(fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 8.0),
                ClipRRect(
                  borderRadius: BorderRadius.circular(ThemeTokens.radiusPill),
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 3,
                    backgroundColor: ThemeTokens.hairline,
                    valueColor: const AlwaysStoppedAnimation<Color>(ThemeTokens.primary),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
