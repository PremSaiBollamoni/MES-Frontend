import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../components/app_drawer.dart';
import '../components/custom_toast.dart';
import '../components/switch_role_dialog.dart';
import '../models/user_model.dart';
import '../services/auth_session.dart';
import '../utils/theme_tokens.dart';
import 'attendance_screen.dart';
import 'dashboard_screen.dart';
import 'employee_list_screen.dart';
import 'login_screen.dart';
import 'operations/operations_hub_screen.dart';
import 'profile_screen.dart';
import 'reports_screen.dart';
import 'role_list_screen.dart';
import 'station_list_screen.dart';

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
      tabs.add(_ShellTab(title: (t) => t.navDashboard, icon: Icons.grid_view_rounded, content: DashboardScreen(user: user)));
    }
    if (user.canAccess('EMPLOYEE_LIST')) {
      tabs.add(_ShellTab(title: (t) => t.navEmployees, icon: Icons.groups_rounded, content: const EmployeeListScreen()));
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
    if (user.canAccess('REPORTS')) {
      tabs.add(_ShellTab(title: (t) => t.navReports, icon: Icons.summarize_rounded, content: const ReportsScreen()));
    }
    if (user.canAccess('PROFILE')) {
      tabs.add(_ShellTab(title: (t) => t.navProfile, icon: Icons.person_rounded, content: const ProfileScreen()));
    }
    return tabs;
  }

  Future<void> _logout() async {
    await AuthSession().clear();
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

    return Scaffold(
      backgroundColor: ThemeTokens.background,
      appBar: AppBar(
        title: Text(_tabs[_index].title(L10n.of(context)), style: ThemeTokens.headingLarge.copyWith(fontSize: 21)),
      ),
      drawer: AppDrawer(
        user: widget.user,
        selectedIndex: _index,
        destinations: _tabs.map((tab) => DrawerDestination(title: tab.title(L10n.of(context)), icon: tab.icon)).toList(),
        onSelect: (index) => setState(() => _index = index),
        onLogout: _logout,
        onSwitchRole: () => showSwitchRoleDialog(context, widget.user),
      ),
      body: SafeArea(
        top: false,
        child: IndexedStack(
          index: _index,
          children: _tabs.map((tab) => tab.content).toList(),
        ),
      ),
    );
  }
}
