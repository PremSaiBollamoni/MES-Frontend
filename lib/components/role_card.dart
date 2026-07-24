import 'package:flutter/material.dart';
import '../models/role_detail.dart';
import '../utils/role_icon.dart';
import '../utils/theme_tokens.dart';
import 'status_badge.dart';

/// Mirrors EmployeeCard's luxury row-tile - ivory surface, hairline border,
/// gold monogram square (role icon), serif name, understated activity line.
class RoleCard extends StatelessWidget {
  final RoleDetail role;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool selectionMode;
  final bool selected;

  const RoleCard({
    super.key,
    required this.role,
    required this.onTap,
    this.onLongPress,
    this.selectionMode = false,
    this.selected = false,
  });

  String _formatRole(String role) {
    return role.split('_').map((word) {
      if (word.isEmpty) return '';
      return word[0] + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final icon = RoleIcon.forRole(role.roleName);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
      child: InkWell(
        borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: selected ? ThemeTokens.surfaceSunken : ThemeTokens.surfaceSolid,
            borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
            border: Border.all(color: selected ? ThemeTokens.primary : ThemeTokens.hairline),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (selectionMode)
                Padding(
                  padding: const EdgeInsets.only(right: 14.0),
                  child: Icon(
                    selected ? Icons.check_circle : Icons.circle_outlined,
                    color: selected ? ThemeTokens.primary : ThemeTokens.textMuted,
                    size: 22,
                  ),
                )
              else
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: ThemeTokens.background,
                    borderRadius: BorderRadius.circular(ThemeTokens.radiusSmall),
                    border: Border.all(color: ThemeTokens.hairline),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 20, color: role.isActive ? ThemeTokens.primary : ThemeTokens.textLight),
                ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_formatRole(role.roleName), style: ThemeTokens.headingMedium.copyWith(fontSize: 16), overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4.0),
                    Text("${role.activities.length} activities permitted", style: ThemeTokens.caption),
                  ],
                ),
              ),
              const SizedBox(width: 12.0),
              StatusBadge(active: role.isActive),
            ],
          ),
        ),
      ),
    );
  }
}
