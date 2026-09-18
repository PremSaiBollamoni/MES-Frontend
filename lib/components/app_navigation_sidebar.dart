import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/theme_tokens.dart';
import 'app_drawer.dart';

/// The wide-window equivalent of AppDrawer - the same header/menu/account content,
/// but docked permanently at the side instead of hidden behind a hamburger tap. On a
/// window this wide there's no reason to make navigation something the user has to
/// go find first.
class AppNavigationSidebar extends StatelessWidget {
  final UserModel user;
  final List<DrawerDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onLogout;
  final VoidCallback? onSwitchRole;

  const AppNavigationSidebar({
    super.key,
    required this.user,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelect,
    required this.onLogout,
    this.onSwitchRole,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 290,
      decoration: const BoxDecoration(
        color: ThemeTokens.background,
        border: Border(right: BorderSide(color: ThemeTokens.hairline)),
      ),
      child: AppDrawerBody(
        user: user,
        destinations: destinations,
        selectedIndex: selectedIndex,
        onSelect: onSelect,
        onLogout: onLogout,
        onSwitchRole: onSwitchRole,
        closeOnSelect: false,
      ),
    );
  }
}
