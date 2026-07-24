import 'package:flutter/material.dart';
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
  final String title;
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
      tabs.add(_ShellTab(title: "Dashboard", icon: Icons.grid_view_rounded, content: DashboardScreen(user: user)));
    }
    if (user.canAccess('EMPLOYEE_LIST')) {
      tabs.add(const _ShellTab(title: "Employees", icon: Icons.groups_rounded, content: EmployeeListScreen()));
    }
    if (user.canAccess('ROLE_LIST')) {
      tabs.add(const _ShellTab(title: "Roles", icon: Icons.shield_rounded, content: RoleListScreen()));
    }
    if (user.canAccess('STATION_LIST')) {
      tabs.add(const _ShellTab(title: "Stations", icon: Icons.factory_rounded, content: StationListScreen()));
    }
    if (user.canAccess('ATTENDANCE')) {
      tabs.add(const _ShellTab(title: "Attendance", icon: Icons.fingerprint_rounded, content: AttendanceScreen()));
    }
    if (user.canAccess('OPERATIONS')) {
      tabs.add(const _ShellTab(title: "Operations", icon: Icons.precision_manufacturing_rounded, content: OperationsHubScreen()));
    }
    if (user.canAccess('REPORTS')) {
      tabs.add(const _ShellTab(title: "Reports", icon: Icons.summarize_rounded, content: ReportsScreen()));
    }
    if (user.canAccess('PROFILE')) {
      tabs.add(const _ShellTab(title: "Profile", icon: Icons.person_rounded, content: ProfileScreen()));
    }
    return tabs;
  }

  Future<void> _logout() async {
    await AuthSession().clear();
    if (!mounted) return;
    CustomToast.show(context, "Logged out successfully");
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
          title: Text("MES", style: ThemeTokens.headingMedium),
          actions: [
            IconButton(icon: const Icon(Icons.logout_rounded, color: ThemeTokens.textSecondary), onPressed: _logout),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text("No modules are assigned to your role yet.", style: ThemeTokens.bodyMedium, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ThemeTokens.background,
      appBar: AppBar(
        title: Text(_tabs[_index].title, style: ThemeTokens.headingLarge.copyWith(fontSize: 21)),
      ),
      drawer: AppDrawer(
        user: widget.user,
        selectedIndex: _index,
        destinations: _tabs.map((tab) => DrawerDestination(title: tab.title, icon: tab.icon)).toList(),
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
