import 'package:flutter/material.dart';
import '../utils/theme_tokens.dart';

/// Bold dark rounded header tile - square avatar block, no divider line,
/// no gradient banner.
class ProfileHeroCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final IconData? badgeIcon;
  final Widget? trailing;

  const ProfileHeroCard({
    super.key,
    required this.name,
    required this.subtitle,
    this.badgeIcon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(color: ThemeTokens.surfaceSolid, borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge)),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: ThemeTokens.primary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium)),
            alignment: Alignment.center,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : "?",
              style: ThemeTokens.headingLarge.copyWith(fontSize: 22, color: ThemeTokens.primary),
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: ThemeTokens.headingMedium.copyWith(fontSize: 17)),
                const SizedBox(height: 4.0),
                Row(
                  children: [
                    if (badgeIcon != null) ...[
                      Icon(badgeIcon, size: 13, color: ThemeTokens.textLight),
                      const SizedBox(width: 4.0),
                    ],
                    Flexible(child: Text(subtitle, style: ThemeTokens.bodyMedium, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
