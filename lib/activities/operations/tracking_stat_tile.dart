import 'package:flutter/material.dart';
import '../../utils/theme_tokens.dart';

/// Single stat card used on the live tracking screen (timer, SAM, wages, ...).
class TrackingStatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const TrackingStatTile({super.key, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: ThemeTokens.surfaceSolid,
        borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
        border: Border.all(color: ThemeTokens.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: ThemeTokens.labelSmall),
          const SizedBox(height: 8.0),
          Text(
            value,
            style: ThemeTokens.headingLarge.copyWith(fontSize: 22, color: valueColor ?? ThemeTokens.textPrimary),
          ),
        ],
      ),
    );
  }
}
