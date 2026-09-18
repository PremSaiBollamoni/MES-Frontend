import 'package:flutter/material.dart';
import '../utils/employee_names.dart';
import '../l10n/app_localizations.dart';
import '../models/user_model.dart';
import '../utils/role_display.dart';
import '../utils/theme_tokens.dart';
import 'drawer_language_picker.dart';

class DrawerDestination {
  final String title;
  final IconData icon;

  const DrawerDestination({required this.title, required this.icon});
}

/// The drawer's content, shared between two hosts: an overlay [Drawer] on a phone-width
/// window (tap a destination and it should close), and a permanent side panel on a wide
/// window (there's nothing to close - it never goes away). [closeOnSelect] is what tells
/// this body which situation it's in.
class AppDrawerBody extends StatelessWidget {
  final UserModel user;
  final List<DrawerDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onLogout;
  final VoidCallback? onSwitchRole;
  final bool closeOnSelect;

  const AppDrawerBody({
    super.key,
    required this.user,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelect,
    required this.onLogout,
    this.onSwitchRole,
    required this.closeOnSelect,
  });

  void _dismiss(BuildContext context) {
    if (closeOnSelect) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 28),
          color: ThemeTokens.ink,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ThemeTokens.radiusSmall),
                  border: Border.all(color: ThemeTokens.primary, width: 1.2),
                ),
                alignment: Alignment.center,
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : "?",
                  style: ThemeTokens.headingLarge.copyWith(color: ThemeTokens.accentLight, fontSize: 22),
                ),
              ),
              const SizedBox(height: 16.0),
              Text(EmployeeNames.display(context, user.name), style: ThemeTokens.headingMedium.copyWith(color: ThemeTokens.onInk, fontSize: 17), overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3.0),
              Text(
                "${user.username}  ·  ${RoleDisplay.name(user.role)}",
                style: ThemeTokens.caption.copyWith(color: ThemeTokens.textLight),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20.0),
        Padding(
          padding: const EdgeInsets.only(left: 24.0, bottom: 12.0),
          child: Text("MENU", style: ThemeTokens.labelSmall.copyWith(color: ThemeTokens.textLight)),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: destinations.length,
            itemBuilder: (context, index) {
              final destination = destinations[index];
              final selected = index == selectedIndex;
              return InkWell(
                onTap: () {
                  _dismiss(context);
                  onSelect(index);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 15.0),
                  decoration: BoxDecoration(
                    color: selected ? ThemeTokens.primary.withValues(alpha: 0.08) : null,
                    border: Border(left: BorderSide(color: selected ? ThemeTokens.primary : Colors.transparent, width: 2.5)),
                  ),
                  child: Row(
                    children: [
                      Icon(destination.icon, size: 19, color: selected ? ThemeTokens.primary : ThemeTokens.textLight),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Text(
                          destination.title,
                          overflow: TextOverflow.ellipsis,
                          style: selected
                              ? ThemeTokens.headingMedium.copyWith(fontSize: 15.5)
                              : ThemeTokens.bodyLarge.copyWith(color: ThemeTokens.textSecondary, fontSize: 14.5),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const Divider(color: ThemeTokens.hairline, height: 1),
        const DrawerLanguagePicker(),
        if (user.hasMultipleRoles && onSwitchRole != null)
          InkWell(
            onTap: () {
              _dismiss(context);
              onSwitchRole!();
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
              child: Row(
                children: [
                  Icon(Icons.sync_alt_rounded, size: 18, color: ThemeTokens.primary),
                  const SizedBox(width: 16.0),
                  Text(L10n.of(context).switchRole3, style: ThemeTokens.bodyLarge.copyWith(color: ThemeTokens.primary, fontSize: 14.5)),
                ],
              ),
            ),
          ),
        InkWell(
          onTap: () {
            _dismiss(context);
            onLogout();
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
            child: Row(
              children: [
                Icon(Icons.logout_rounded, size: 18, color: ThemeTokens.error),
                const SizedBox(width: 16.0),
                Text(L10n.of(context).signOut, style: ThemeTokens.bodyLarge.copyWith(color: ThemeTokens.error, fontSize: 14.5)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Luxury side drawer - an espresso-ink header block with a gold serif monogram,
/// then understated nav rows where the active row is marked by a gold rule and
/// serif weight (not a filled pill). Used as the overlay drawer on phone-width windows;
/// see AppNavigationSidebar for the permanent wide-window equivalent.
class AppDrawer extends StatelessWidget {
  final UserModel user;
  final List<DrawerDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onLogout;
  final VoidCallback? onSwitchRole;

  const AppDrawer({
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
    return Drawer(
      backgroundColor: ThemeTokens.background,
      width: 290,
      child: AppDrawerBody(
        user: user,
        destinations: destinations,
        selectedIndex: selectedIndex,
        onSelect: onSelect,
        onLogout: onLogout,
        onSwitchRole: onSwitchRole,
        closeOnSelect: true,
      ),
    );
  }
}
