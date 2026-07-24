import 'package:flutter/material.dart';
import '../utils/theme_tokens.dart';

/// A label/value row used across detail screens (e.g. employee, and future
/// PALMS modules) to keep read-only detail layouts consistent.
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const InfoRow({super.key, required this.label, required this.value, this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: ThemeTokens.textLight),
            const SizedBox(width: 12.0),
          ],
          SizedBox(
            width: 130,
            child: Text(label, style: ThemeTokens.caption.copyWith(fontSize: 12)),
          ),
          Expanded(
            child: Text(
              value,
              style: ThemeTokens.bodyMedium.copyWith(color: ThemeTokens.textPrimary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
