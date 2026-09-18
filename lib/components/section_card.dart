import 'package:flutter/material.dart';
import '../utils/theme_tokens.dart';

/// Luxury section container - ivory surface, hairline border, a soft ambient shadow
/// for depth, an uppercase tracked eyebrow title marked by a short accent rule.
class SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const SectionCard({super.key, required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22.0),
      decoration: BoxDecoration(
        color: ThemeTokens.surfaceSolid,
        borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
        border: Border.all(color: ThemeTokens.hairline),
        boxShadow: ThemeTokens.cardShadow,
      ),
      child: Column(
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
          // A ListTile/CheckboxListTile/SwitchListTile paints its ink splashes on the
          // nearest Material ancestor - without this, this card's own solid background
          // sits directly between them and the Scaffold's Material, hiding the splashes.
          Material(type: MaterialType.transparency, child: child),
        ],
      ),
    );
  }
}
