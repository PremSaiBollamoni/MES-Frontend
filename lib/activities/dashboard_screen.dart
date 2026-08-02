import 'package:flutter/material.dart';
import '../utils/employee_names.dart';
import '../l10n/app_localizations.dart';
import '../components/dashboard/attendance_dashboard.dart';
import '../components/dashboard/minimal_dashboard.dart';
import '../components/dashboard/my_production_dashboard.dart';
import '../components/dashboard/sam_dashboard.dart';
import '../components/dashboard/workforce_dashboard.dart';
import '../models/user_model.dart';
import '../utils/theme_tokens.dart';

/// Dashboard - a thin router. Each role sees a genuinely different body built
/// from the data that's actually relevant to their PALMS responsibilities
/// (§5), not one generic workforce view for everyone:
///   Factory Manager / HR Manager -> workforce composition (their real scope)
///   Production Supervisor        -> live attendance (their real scope)
///   IE / SAM Analyst              -> stations, SAM, live bottleneck (§9 rule)
///   Operator / QC / Store Keeper  -> honest "not built yet" placeholder,
///                                    since their PALMS modules (piece count,
///                                    defect log, stock) don't exist as data yet.
class DashboardScreen extends StatelessWidget {
  final UserModel user;

  const DashboardScreen({super.key, required this.user});

  String _formatRole(String role) {
    return role.split('_').map((word) {
      if (word.isEmpty) return '';
      return word[0] + word.substring(1).toLowerCase();
    }).join(' ');
  }

  String _greeting(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 12) return L10n.of(context).goodMorning;
    if (hour < 17) return L10n.of(context).goodAfternoon;
    return L10n.of(context).goodEvening;
  }

  Widget _bodyForRole(BuildContext context) {
    switch (user.role) {
      case 'FACTORY_MANAGER':
      case 'HR_MANAGER':
        return const WorkforceDashboard();
      case 'PRODUCTION_SUPERVISOR':
        return const AttendanceDashboard();
      case 'IE_ANALYST':
        return const SamDashboard();
      case 'OPERATOR':
        return user.canAccess('MY_PRODUCTION')
            ? const MyProductionDashboard()
            : MinimalDashboard(
                message: L10n.of(context).yourPieceCountAndShift,
              );
      case 'QC_INSPECTOR':
        return MinimalDashboard(
          message: L10n.of(context).defectLoggingAndQcVerification,
        );
      case 'STORE_KEEPER':
        return MinimalDashboard(
          message: L10n.of(context).packingRtmAndDispatchStock,
        );
      default:
        return MinimalDashboard(
          message: L10n.of(context).yourDashboardWillAppearHere,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only the header gets its own padding - each role body below owns a
    // ListView with its own horizontal padding, so wrapping this whole Column
    // in padding too would double it up (48px instead of 24px) and squeeze
    // every card in narrower than intended.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_greeting(context).toUpperCase(), style: ThemeTokens.labelSmall),
              const SizedBox(height: 6.0),
              Text(EmployeeNames.display(context, user.name).split(' ').first, style: ThemeTokens.headingDisplay),
              const SizedBox(height: 4.0),
              Text(_formatRole(user.role), style: ThemeTokens.bodyMedium),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
        Expanded(child: _bodyForRole(context)),
      ],
    );
  }
}
