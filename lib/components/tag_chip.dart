import 'package:flutter/material.dart';
import '../utils/theme_tokens.dart';

/// Understated metadata tag - hairline outline, small icon + label. No filled
/// color background; the outline + restraint is the luxury signal.
class TagChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const TagChip({super.key, required this.icon, required this.label, this.color = ThemeTokens.textSecondary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 5.0),
      decoration: BoxDecoration(
        border: Border.all(color: ThemeTokens.hairline),
        borderRadius: BorderRadius.circular(ThemeTokens.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 6.0),
          Flexible(
            child: Text(
              label,
              style: ThemeTokens.caption.copyWith(color: ThemeTokens.textSecondary, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
