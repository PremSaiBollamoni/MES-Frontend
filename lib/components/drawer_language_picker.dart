import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../utils/locale_controller.dart';
import '../utils/theme_tokens.dart';

/// Language chooser, sat in the drawer/sidebar above the account actions.
///
/// Each language is written in its own script, so someone who only reads Telugu can
/// find "తెలుగు" without needing to read the English word "Telugu" first.
class DrawerLanguagePicker extends StatelessWidget {
  const DrawerLanguagePicker({super.key});

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
