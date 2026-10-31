import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../components/app_drawer.dart';
import '../components/app_navigation_sidebar.dart';
import '../components/custom_toast.dart';
import '../components/switch_role_dialog.dart';
import '../models/user_model.dart';
import '../services/api_client.dart';
import '../services/auth_session.dart';
import '../utils/theme_tokens.dart';
import 'attendance_screen.dart';
import 'dashboard_screen.dart';
import 'employee_list_screen.dart';
import 'employees_factory_picker_screen.dart';
import 'factory_list_screen.dart';
import 'login_screen.dart';
import 'my_daily_production_screen.dart';
import 'operations/operations_hub_screen.dart';
import 'payroll_screen.dart';
import 'profile_screen.dart';
import 'reports_screen.dart';
import 'role_list_screen.dart';
import 'super_admin_overview_screen.dart';
import 'station_list_screen.dart';
import 'support_chat_screen.dart';
import 'ai_settings_screen.dart';
import 'mail_settings_screen.dart';
import 'support_tickets_screen.dart';

class _ShellTab {
  /// Resolves the tab's label against the current language. Stored as a function
  /// rather than a plain String so the drawer re-labels itself when the language
  /// changes, instead of keeping whatever text was current when tabs were built.
  final String Function(L10n) title;
  final IconData icon;
  final Widget content;

  const _ShellTab({required this.title, required this.icon, required this.content});
}

class MainShellScreen extends StatefulWidget {
  final UserModel user;

  const MainShellScreen({super.key, required this.user});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _index = 0;
  late final List<_ShellTab> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = _buildTabs();
  }

  List<_ShellTab> _buildTabs() {
    final tabs = <_ShellTab>[];
    final user = widget.user;

    if (user.canAccess('DASHBOARD')) {
      // SUPER_ADMIN belongs to no single factory, so their "Dashboard" is a
      // cross-factory KPI overview instead of one factory's workforce dashboard.
      final dashboardContent = user.isSuperAdmin ? const SuperAdminOverviewScreen() : DashboardScreen(user: user);
      tabs.add(_ShellTab(title: (t) => t.navDashboard, icon: Icons.grid_view_rounded, content: dashboardContent));
    }
    // SUPER_ADMIN-only: manage every factory (company/tenant) this app serves.
    // Not localized like the other tabs since SUPER_ADMIN is a system operator
    // role, not a factory-floor role the L10n catalogue is built around.
    if (user.canAccess('FACTORY_MANAGEMENT')) {
      tabs.add(_ShellTab(title: (t) => "Factories", icon: Icons.business_rounded, content: const FactoryListScreen()));
    }
    if (user.canAccess('EMPLOYEE_LIST')) {
      // SUPER_ADMIN belongs to no single factory, so "Employees" starts at a factory
      // picker instead of dumping every factory's staff into one merged list.
      final employeesContent = user.isSuperAdmin ? const EmployeesFactoryPickerScreen() : const EmployeeListScreen();
      tabs.add(_ShellTab(title: (t) => t.navEmployees, icon: Icons.groups_rounded, content: employeesContent));
    }
    if (user.canAccess('ROLE_LIST')) {
      tabs.add(_ShellTab(title: (t) => t.navRoles, icon: Icons.shield_rounded, content: const RoleListScreen()));
    }
    if (user.canAccess('STATION_LIST')) {
      tabs.add(_ShellTab(title: (t) => t.navStations, icon: Icons.factory_rounded, content: const StationListScreen()));
    }
    if (user.canAccess('ATTENDANCE')) {
      tabs.add(_ShellTab(title: (t) => t.navAttendance, icon: Icons.fingerprint_rounded, content: const AttendanceScreen()));
    }
    if (user.canAccess('OPERATIONS')) {
      tabs.add(_ShellTab(title: (t) => t.navOperations, icon: Icons.precision_manufacturing_rounded, content: const OperationsHubScreen()));
    }
    // Gated by the same activity as the My Production dashboard tile - this is a detail view
    // of the same data (day-by-day instead of month totals), not a new permission.
    if (user.canAccess('MY_PRODUCTION')) {
      tabs.add(_ShellTab(title: (t) => t.navDailyProduction, icon: Icons.event_note_rounded, content: const MyDailyProductionScreen()));
    }
    if (user.canAccess('REPORTS')) {
      tabs.add(_ShellTab(title: (t) => t.navReports, icon: Icons.summarize_rounded, content: const ReportsScreen()));
    }
    if (user.canAccess('PAYROLL')) {
      tabs.add(_ShellTab(title: (t) => t.navPayroll, icon: Icons.payments_rounded, content: const PayrollScreen()));
    }
    if (user.canAccess('PROFILE')) {
      tabs.add(_ShellTab(title: (t) => t.navProfile, icon: Icons.person_rounded, content: const ProfileScreen()));
    }
    // SUPER_ADMIN-only ticket inbox - granted to no other role. The chat itself
    // (everyone gets SUPPORT_CHAT, see V45 migration) is reached via the floating
    // chat button instead of a tab - see _buildFab.
    // SUPER_ADMIN-only: the SMTP account every automated email is sent from.
    if (user.canAccess('SMTP_CONFIGURATION')) {
      tabs.add(_ShellTab(title: (t) => "Email", icon: Icons.mark_email_read_rounded, content: const MailSettingsScreen()));
    }
    // SUPER_ADMIN-only: the AI provider used by the support chat and daily reports.
    if (user.canAccess('AI_CONFIGURATION')) {
      tabs.add(_ShellTab(title: (t) => "AI", icon: Icons.auto_awesome_rounded, content: const AiSettingsScreen()));
    }
    if (user.canAccess('SUPPORT_TICKETS_ADMIN')) {
      tabs.add(_ShellTab(title: (t) => "Tickets", icon: Icons.confirmation_number_rounded, content: const SupportTicketsScreen()));
    }
    return tabs;
  }

  Widget? _buildChatFab() {
    if (!widget.user.canAccess('SUPPORT_CHAT')) return null;
    return FloatingActionButton(
      backgroundColor: ThemeTokens.primary,
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const SupportChatScreen()),
      ),
      child: const Icon(Icons.support_agent_rounded, color: Colors.white),
    );
  }

  Future<void> _logout() async {
    await AuthSession().clear();
    // Otherwise the next employee to log in on this device could be served this
    // employee's cached self-scoped responses (e.g. My Production) for up to 15 minutes.
    ApiClient.invalidateCache();
    if (!mounted) return;
    CustomToast.show(context, L10n.of(context).loggedOut);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_tabs.isEmpty) {
      return Scaffold(
        backgroundColor: ThemeTokens.background,
        appBar: AppBar(
          title: Text(L10n.of(context).appName, style: ThemeTokens.headingMedium),
          actions: [
            IconButton(icon: const Icon(Icons.logout_rounded, color: ThemeTokens.textSecondary), onPressed: _logout),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(L10n.of(context).noModules, style: ThemeTokens.bodyMedium, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    final destinations = _tabs.map((tab) => DrawerDestination(title: tab.title(L10n.of(context)), icon: tab.icon)).toList();
    final content = SafeArea(
      top: false,
      child: IndexedStack(
        index: _index,
        children: _tabs.map((tab) => tab.content).toList(),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // Below this a hamburger drawer is the only thing that fits; above it there's
        // no reason to hide navigation behind a tap when the window has the width to
        // just show it permanently - same breakpoint the login/role-selection
        // screens use for their own wide-window layout.
        if (constraints.maxWidth < 900) {
          return Scaffold(
            backgroundColor: ThemeTokens.background,
            appBar: AppBar(
              title: Text(_tabs[_index].title(L10n.of(context)), style: ThemeTokens.headingLarge.copyWith(fontSize: 21)),
            ),
            drawer: AppDrawer(
              user: widget.user,
              selectedIndex: _index,
              destinations: destinations,
              onSelect: (index) => setState(() => _index = index),
              onLogout: _logout,
              onSwitchRole: () => showSwitchRoleDialog(context, widget.user),
            ),
            body: content,
            floatingActionButton: _buildChatFab(),
          );
        }

        return Scaffold(
          backgroundColor: ThemeTokens.background,
          body: Row(
            children: [
              AppNavigationSidebar(
                user: widget.user,
                selectedIndex: _index,
                destinations: destinations,
                onSelect: (index) => setState(() => _index = index),
                onLogout: _logout,
                onSwitchRole: () => showSwitchRoleDialog(context, widget.user),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 24, 28, 4),
                      child: Text(_tabs[_index].title(L10n.of(context)), style: ThemeTokens.headingLarge.copyWith(fontSize: 22)),
                    ),
                    Expanded(child: content),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: _buildChatFab(),
        );
      },
    );
  }
}
