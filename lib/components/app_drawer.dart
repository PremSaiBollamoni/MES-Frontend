import 'package:flutter/material.dart';
import '../utils/employee_names.dart';
import '../l10n/app_localizations.dart';
import '../models/user_model.dart';
import '../utils/locale_controller.dart';
import '../utils/theme_tokens.dart';

class DrawerDestination {
  final String title;
  final IconData icon;

  const DrawerDestination({required this.title, required this.icon});
}

/// Luxury side drawer - an espresso-ink header block with a gold serif monogram,
/// then understated nav rows where the active row is marked by a gold rule and
/// serif weight (not a filled pill). Restraint over decoration.
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

  String _formatRole(String role) {
    return role.split('_').map((word) {
      if (word.isEmpty) return '';
      return word[0] + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: ThemeTokens.background,
      width: 290,
      child: Column(
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
                  "${user.username}  ·  ${_formatRole(user.role)}",
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
                    Navigator.of(context).pop();
                    onSelect(index);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 15.0),
                    decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: selected ? ThemeTokens.primary : Colors.transparent, width: 2.5)),
                    ),
                    child: Row(
                      children: [
                        Icon(destination.icon, size: 19, color: selected ? ThemeTokens.primary : ThemeTokens.textLight),
                        const SizedBox(width: 16.0),
                        Text(
                          destination.title,
                          style: selected
                              ? ThemeTokens.headingMedium.copyWith(fontSize: 15.5)
                              : ThemeTokens.bodyLarge.copyWith(color: ThemeTokens.textSecondary, fontSize: 14.5),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(color: ThemeTokens.hairline, height: 1),
          const _LanguagePicker(),
          if (user.hasMultipleRoles && onSwitchRole != null)
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
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
              Navigator.of(context).pop();
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
      ),
    );
  }
}

/// Language chooser, sat in the drawer above the account actions.
///
/// Each language is written in its own script, so someone who only reads Telugu can
/// find "తెలుగు" without needing to read the English word "Telugu" first.
class _LanguagePicker extends StatelessWidget {
  const _LanguagePicker();

  @override
  Widget build(BuildContext context) {
    final controller = LocaleController();
    return ValueListenableBuilder<Locale>(
      valueListenable: controller.locale,
      builder: (context, current, _) {
        // Label above, options below rather than all on one row: the drawer is only
        // 290px wide, and a translated label plus both pills overflowed it. Wrap also
        // means a third language later reflows instead of breaking the layout.
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.translate_rounded, size: 18, color: ThemeTokens.textSecondary),
                  const SizedBox(width: 16.0),
                  Flexible(
                    child: Text(
                      L10n.of(context).language,
                      style: ThemeTokens.bodyLarge.copyWith(color: ThemeTokens.textSecondary, fontSize: 14.5),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.only(left: 34.0),
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: LocaleController.supported.map((locale) {
                    final selected = locale.languageCode == current.languageCode;
                    return InkWell(
                      borderRadius: BorderRadius.circular(ThemeTokens.radiusPill),
                      onTap: () => controller.setLocale(locale),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 7.0),
                        decoration: BoxDecoration(
                          color: selected ? ThemeTokens.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(ThemeTokens.radiusPill),
                          border: Border.all(
                            color: selected ? ThemeTokens.primary : ThemeTokens.hairline,
                          ),
                        ),
                        child: Text(
                          LocaleController.nameOf(locale),
                          style: ThemeTokens.caption.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: selected ? Colors.white : ThemeTokens.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
