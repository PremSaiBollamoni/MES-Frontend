import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../components/custom_toast.dart';
import '../models/login_result.dart';
import '../services/api_service.dart';
import '../utils/role_icon.dart';
import '../utils/theme_tokens.dart';
import 'main_shell_screen.dart';

/// Shown after login when an employee holds more than one active role - they
/// pick which one to sign in as. A single-role employee never sees this screen
/// (login goes straight to MainShellScreen).
class RoleSelectionScreen extends StatefulWidget {
  final RoleSelectionRequired pending;

  const RoleSelectionScreen({super.key, required this.pending});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  final ApiService _apiService = ApiService();
  String? _selectingRole;

  String _formatRole(String role) {
    return role.split('_').map((word) {
      if (word.isEmpty) return '';
      return word[0] + word.substring(1).toLowerCase();
    }).join(' ');
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(L10n.of(context).signInAs, style: ThemeTokens.labelSmall),
                  const SizedBox(height: 8.0),
                  Text("Hi, ${widget.pending.name.split(' ').first}", style: ThemeTokens.headingDisplay.copyWith(fontSize: 28)),
                  const SizedBox(height: 8.0),
                  Text(
                    L10n.of(context).yourAccountHoldsMoreThan,
                    style: ThemeTokens.bodyMedium,
                  ),
                  const SizedBox(height: 32.0),
                  ...widget.pending.roles.map((role) {
                    final isSelecting = _selectingRole == role.roleName;
                    final isDisabled = _selectingRole != null && !isSelecting;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
                          onTap: isDisabled || _selectingRole != null ? null : () => _choose(role.roleName),
                          child: Container(
                            padding: const EdgeInsets.all(18.0),
                            decoration: BoxDecoration(
                              color: ThemeTokens.surfaceSolid,
                              borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
                              border: Border.all(color: ThemeTokens.hairline),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: ThemeTokens.background,
                                    borderRadius: BorderRadius.circular(ThemeTokens.radiusSmall),
                                    border: Border.all(color: ThemeTokens.hairline),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(RoleIcon.forRole(role.roleName), size: 20, color: ThemeTokens.primary),
                                ),
                                const SizedBox(width: 16.0),
                                Expanded(
                                  child: Text(_formatRole(role.roleName), style: ThemeTokens.headingMedium.copyWith(fontSize: 16)),
                                ),
                                if (isSelecting)
                                  const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: ThemeTokens.primary),
                                  )
                                else
                                  Icon(Icons.chevron_right_rounded, color: ThemeTokens.textLight),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
