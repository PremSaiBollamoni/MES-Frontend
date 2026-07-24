import 'package:flutter/material.dart';
import '../models/employee_summary.dart';
import '../utils/role_icon.dart';
import '../utils/theme_tokens.dart';
import 'status_badge.dart';

/// Luxury row-tile: ivory surface, hairline border, restrained radius. A gold
/// serif monogram, the name set in the display serif, an understated role line,
/// and a quiet status marker. No bright fills, no gradients.
class EmployeeCard extends StatelessWidget {
  final EmployeeSummary employee;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool selectionMode;
  final bool selected;

  const EmployeeCard({
    super.key,
    required this.employee,
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
    final roleIcon = RoleIcon.forRole(employee.roleCode);
    final extraRoles = employee.hasMultipleRoles ? employee.roleCodes.length - 1 : 0;
    final subtitleParts = [
      extraRoles > 0 ? "${_formatRole(employee.roleCode)} +$extraRoles" : _formatRole(employee.roleCode),
      if (employee.department != null) employee.department!,
    ];

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
                  child: Text(
                    employee.name.isNotEmpty ? employee.name[0].toUpperCase() : "?",
                    style: ThemeTokens.headingMedium.copyWith(fontSize: 18, color: employee.active ? ThemeTokens.primary : ThemeTokens.textLight),
                  ),
                ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(employee.name, style: ThemeTokens.headingMedium.copyWith(fontSize: 16), overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        Icon(roleIcon, size: 12, color: ThemeTokens.textLight),
                        const SizedBox(width: 6.0),
                        Expanded(
                          child: Text(subtitleParts.join('  ·  '), style: ThemeTokens.caption, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12.0),
              StatusBadge(active: employee.active),
            ],
          ),
        ),
      ),
    );
  }
}
