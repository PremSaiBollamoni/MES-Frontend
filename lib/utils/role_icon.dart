import 'package:flutter/material.dart';

/// Maps a role code to one representative icon, used everywhere a role shows up
/// (Role Management cards, the role tag on Employee cards, Role Selection, etc.)
/// so the same role always reads as the same icon instead of every role looking
/// identical. Exact-matches the real role set first; a role created later through
/// Role Management that isn't one of these falls back to a loose keyword guess.
class RoleIcon {
  static IconData forRole(String roleCode) {
    final upper = roleCode.toUpperCase();
    switch (upper) {
      case 'FACTORY_MANAGER':
        return Icons.factory_rounded;
      case 'PRODUCTION_SUPERVISOR':
        return Icons.precision_manufacturing_rounded;
      case 'IE_ANALYST':
        return Icons.insights_rounded;
      case 'QC_INSPECTOR':
        return Icons.fact_check_rounded;
      case 'STORE_KEEPER':
        return Icons.inventory_2_rounded;
      case 'OPERATOR':
        return Icons.engineering_rounded;
      case 'HR_MANAGER':
        return Icons.badge_rounded;
    }

    if (upper.contains('ADMIN')) return Icons.admin_panel_settings_rounded;
    if (upper.contains('HR')) return Icons.badge_rounded;
    if (upper.contains('QUALITY') || upper.contains('QC') || upper.contains('INSPECT')) return Icons.fact_check_rounded;
    if (upper.contains('STORE') || upper.contains('STOCK') || upper.contains('WAREHOUSE')) return Icons.inventory_2_rounded;
    if (upper.contains('ANALYST') || upper.contains('ENGINEER')) return Icons.insights_rounded;
    if (upper.contains('MANAGER') || upper.contains('SUPERVISOR')) return Icons.supervisor_account_rounded;
    if (upper.contains('ACCOUNT') || upper.contains('FINANCE')) return Icons.account_balance_rounded;
    if (upper.contains('OPERATOR') || upper.contains('WORKER') || upper.contains('STAFF')) return Icons.engineering_rounded;
    return Icons.security_rounded;
  }
}
