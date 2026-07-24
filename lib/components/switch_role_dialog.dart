import 'package:flutter/material.dart';
import '../activities/main_shell_screen.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../utils/role_icon.dart';
import '../utils/theme_tokens.dart';
import 'custom_toast.dart';

/// "Switch Role" picker - lists every active role the current employee holds
/// and swaps the session to whichever one is tapped, no password re-entry.
Future<void> showSwitchRoleDialog(BuildContext context, UserModel user) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: ThemeTokens.background,
    isScrollControlled: true,
    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(ThemeTokens.radiusLarge))),
    builder: (context) => _SwitchRoleSheet(user: user),
  );
}

class _SwitchRoleSheet extends StatefulWidget {
  final UserModel user;
  const _SwitchRoleSheet({required this.user});

  @override
  State<_SwitchRoleSheet> createState() => _SwitchRoleSheetState();
}

class _SwitchRoleSheetState extends State<_SwitchRoleSheet> {
  final ApiService _apiService = ApiService();
  String? _switchingTo;

  String _formatRole(String role) {
    return role.split('_').map((word) {
      if (word.isEmpty) return '';
      return word[0] + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Future<void> _choose(String roleName) async {
    if (roleName == widget.user.role) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _switchingTo = roleName);
    try {
      final newUser = await _apiService.switchRole(roleName);
      if (!mounted) return;
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MainShellScreen(user: newUser)),
      );
    } catch (e) {
      if (!mounted) return;
      CustomToast.show(context, e.toString().replaceAll("Exception: ", ""), isError: true);
      setState(() => _switchingTo = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("SWITCH ROLE", style: ThemeTokens.labelSmall),
            const SizedBox(height: 4.0),
            Text("Choose which role to use for this session.", style: ThemeTokens.bodyMedium),
            const SizedBox(height: 20.0),
            ...widget.user.availableRoles.map((roleName) {
              final isCurrent = roleName == widget.user.role;
              final isSwitching = _switchingTo == roleName;
              final isDisabled = _switchingTo != null && !isSwitching;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
                    onTap: isDisabled || _switchingTo != null ? null : () => _choose(roleName),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: isCurrent ? ThemeTokens.surfaceSunken : ThemeTokens.surfaceSolid,
                        borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
                        border: Border.all(color: isCurrent ? ThemeTokens.primary : ThemeTokens.hairline),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: ThemeTokens.background,
                              borderRadius: BorderRadius.circular(ThemeTokens.radiusSmall),
                              border: Border.all(color: ThemeTokens.hairline),
                            ),
                            alignment: Alignment.center,
                            child: Icon(RoleIcon.forRole(roleName), size: 18, color: ThemeTokens.primary),
                          ),
                          const SizedBox(width: 14.0),
                          Expanded(
                            child: Text(_formatRole(roleName), style: ThemeTokens.headingMedium.copyWith(fontSize: 15)),
                          ),
                          if (isSwitching)
                            const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: ThemeTokens.primary))
                          else if (isCurrent)
                            Text("CURRENT", style: ThemeTokens.labelSmall.copyWith(color: ThemeTokens.primary, fontSize: 10))
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
    );
  }
}
