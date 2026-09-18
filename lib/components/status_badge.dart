import 'package:flutter/material.dart';
import '../utils/theme_tokens.dart';

/// Understated status - a small marker dot + tracked-out uppercase micro-label.
/// No filled pill; luxury keeps status quiet.
class StatusBadge extends StatelessWidget {
  final bool active;
  final String activeLabel;
  final String inactiveLabel;

  const StatusBadge({
    super.key,
    required this.active,
    this.activeLabel = "Active",
    this.inactiveLabel = "Inactive",
  });

  @override
  Widget build(BuildContext context) {
    final Color color = active ? ThemeTokens.success : ThemeTokens.textLight;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 5, height: 5, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 7.0),
        Text(
          (active ? activeLabel : inactiveLabel).toUpperCase(),
          style: ThemeTokens.labelSmall.copyWith(color: color, fontSize: 10, letterSpacing: 1.2),
        ),
      ],
    );
  }
}
