import 'package:flutter/material.dart';

/// Maps a role code to one representative icon, used everywhere a role shows up
/// (Role Management cards, the role tag on Employee cards, etc.) so the same role
/// always reads as the same icon instead of every role looking identical.
class RoleIcon {
  static IconData forRole(String roleCode) {
    final upper = roleCode.toUpperCase();
    if (upper.contains('ADMIN')) return Icons.admin_panel_settings_rounded;
    if (upper.contains('HR')) return Icons.badge_rounded;
    if (upper.contains('MANAGER') || upper.contains('SUPERVISOR')) return Icons.supervisor_account_rounded;
    if (upper.contains('QUALITY')) return Icons.verified_rounded;
    if (upper.contains('ACCOUNT') || upper.contains('FINANCE')) return Icons.account_balance_rounded;
    if (upper.contains('OPERATOR') || upper.contains('WORKER') || upper.contains('STAFF')) return Icons.engineering_rounded;
    return Icons.security_rounded;
  }
}
