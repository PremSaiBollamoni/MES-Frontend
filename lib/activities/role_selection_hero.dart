import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../utils/theme_tokens.dart';

/// Full-width gradient hero card greeting the employee by name - replaces a plain
/// text heading with a real colored moment at the top of the screen, matching the
/// gradient already used on primary buttons elsewhere in the app.
class RoleSelectionHero extends StatelessWidget {
  final String name;
  final String initial;

  const RoleSelectionHero({super.key, required this.name, required this.initial});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: ThemeTokens.primaryGradient,
        borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
        boxShadow: [BoxShadow(color: ThemeTokens.primary.withValues(alpha: 0.28), blurRadius: 24, offset: const Offset(0, 12))],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(initial, style: ThemeTokens.headingLarge.copyWith(color: ThemeTokens.primaryDark, fontSize: 22)),
          ),
          const SizedBox(width: 18.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  L10n.of(context).signInAs,
                  style: ThemeTokens.labelSmall.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 2.0),
                Text(
                  "Hi, ${name.split(' ').first}",
                  style: ThemeTokens.headingDisplay.copyWith(color: Colors.white, fontSize: 25),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6.0),
                Text(
                  L10n.of(context).yourAccountHoldsMoreThan,
                  style: ThemeTokens.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
