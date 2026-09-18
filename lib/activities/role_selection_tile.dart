import 'package:flutter/material.dart';
import '../utils/role_display.dart';
import '../utils/role_icon.dart';
import '../utils/theme_tokens.dart';

/// One selectable role, as a square icon-forward grid tile (icon on top, name
/// below, centered) rather than a horizontal list row - reads as choosing a
/// destination/app rather than scanning down a settings-style list.
class RoleSelectionTile extends StatelessWidget {
  final String roleName;
  final bool isSelecting;
  final bool isDisabled;
  final VoidCallback onTap;

  const RoleSelectionTile({
    super.key,
    required this.roleName,
    required this.isSelecting,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
      child: InkWell(
        borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
        onTap: isDisabled ? null : onTap,
        child: Container(
          // Fixed height, not content-sized: role names range from one word to
          // two, and a Wrap (unlike a GridView) won't equalize row heights on its
          // own - without this, shorter names produce visibly shorter tiles.
          height: 158,
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
          decoration: BoxDecoration(
            color: ThemeTokens.surfaceSolid,
            borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
            border: Border.all(color: isSelecting ? ThemeTokens.primary : ThemeTokens.hairline, width: isSelecting ? 1.5 : 1),
            boxShadow: ThemeTokens.cardShadow,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: ThemeTokens.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: ThemeTokens.primary.withValues(alpha: 0.28), blurRadius: 12, offset: const Offset(0, 5))],
                ),
                alignment: Alignment.center,
                child: isSelecting
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Icon(RoleIcon.forRole(roleName), size: 22, color: Colors.white),
              ),
              const SizedBox(height: 12.0),
              SizedBox(
                height: 34, // room for exactly two lines, so 1-line and 2-line names align
                child: Text(
                  RoleDisplay.name(roleName),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: ThemeTokens.bodyLarge.copyWith(fontSize: 13.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
