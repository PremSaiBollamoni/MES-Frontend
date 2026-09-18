import 'package:flutter/material.dart';
import '../components/custom_toast.dart';
import '../models/login_result.dart';
import '../services/api_service.dart';
import '../utils/theme_tokens.dart';
import 'login_brand_panel.dart';
import 'main_shell_screen.dart';
import 'role_selection_hero.dart';
import 'role_selection_tile.dart';

/// Shown after login when an employee holds more than one active role - they
/// pick which one to sign in as. A single-role employee never sees this screen
/// (login goes straight to MainShellScreen). Shares the login screen's wide-window
/// brand panel, so the two feel like one continuous sign-in flow rather than a
/// polished screen followed by a plain one.
class RoleSelectionScreen extends StatefulWidget {
  final RoleSelectionRequired pending;

  const RoleSelectionScreen({super.key, required this.pending});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  final ApiService _apiService = ApiService();
  String? _selectingRole;

  Future<void> _choose(String roleName) async {
    setState(() => _selectingRole = roleName);
    try {
      final user = await _apiService.selectRole(widget.pending.preAuthToken, roleName);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MainShellScreen(user: user)),
      );
    } catch (e) {
      if (!mounted) return;
      CustomToast.show(context, e.toString().replaceAll("Exception: ", ""), isError: true);
      setState(() => _selectingRole = null);
    }
  }

  String get _initial {
    final name = widget.pending.name.trim();
    return name.isEmpty ? "?" : name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 900) return _RoleSelectionContent(pending: widget.pending, initial: _initial, selectingRole: _selectingRole, onChoose: _choose);
          return Row(
            children: [
              // No entrance animation requested for this screen - always-complete
              // animation renders the panel fully visible immediately.
              Expanded(flex: 5, child: LoginBrandPanel(entrance: kAlwaysCompleteAnimation)),
              Expanded(
                flex: 4,
                child: _RoleSelectionContent(pending: widget.pending, initial: _initial, selectingRole: _selectingRole, onChoose: _choose),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RoleSelectionContent extends StatelessWidget {
  final RoleSelectionRequired pending;
  final String initial;
  final String? selectingRole;
  final ValueChanged<String> onChoose;

  const _RoleSelectionContent({required this.pending, required this.initial, required this.selectingRole, required this.onChoose});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RoleSelectionHero(name: pending.name, initial: initial),
                const SizedBox(height: 28.0),
                Wrap(
                  spacing: 14.0,
                  runSpacing: 14.0,
                  children: pending.roles.map((role) {
                    final isSelecting = selectingRole == role.roleName;
                    final isDisabled = selectingRole != null;
                    return SizedBox(
                      width: 148,
                      child: RoleSelectionTile(
                        roleName: role.roleName,
                        isSelecting: isSelecting,
                        isDisabled: isDisabled,
                        onTap: () => onChoose(role.roleName),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
