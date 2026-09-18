import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/report.dart';
import '../../utils/theme_tokens.dart';

/// Claude/OpenRouter toggle shown on every report type, plus a free-text OpenRouter model
/// name field when that provider is selected - lets a report be generated against a
/// replacement model immediately (e.g. the usual one is deprecated/down on OpenRouter's
/// side) with no app update or backend redeploy.
class ReportProviderSelector extends StatelessWidget {
  final ReportProvider provider;
  final ValueChanged<ReportProvider> onProviderChanged;
  final TextEditingController modelController;

  const ReportProviderSelector({
    super.key,
    required this.provider,
    required this.onProviderChanged,
    required this.modelController,
  });

  @override
  Widget build(BuildContext context) {
    final t = L10n.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: _chip("Claude", ReportProvider.claude)),
            const SizedBox(width: 10.0),
            Expanded(child: _chip("OpenRouter", ReportProvider.openRouter)),
          ],
        ),
        if (provider == ReportProvider.openRouter) ...[
          const SizedBox(height: 10.0),
          TextField(
            controller: modelController,
            style: ThemeTokens.bodyLarge.copyWith(fontSize: 14),
            decoration: InputDecoration(
              labelText: t.openRouterModelName.toUpperCase(),
              labelStyle: ThemeTokens.labelSmall.copyWith(fontSize: 9.5),
              hintText: "e.g. nvidia/nemotron-3-ultra-550b-a55b:free",
              filled: true,
              fillColor: ThemeTokens.surfaceSolid,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium)),
            ),
          ),
          const SizedBox(height: 6.0),
          Text(t.openRouterModelHint, style: ThemeTokens.caption.copyWith(fontStyle: FontStyle.italic)),
        ],
      ],
    );
  }

  Widget _chip(String label, ReportProvider value) {
    final selected = provider == value;
    return GestureDetector(
      onTap: () => onProviderChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          color: selected ? ThemeTokens.primary : ThemeTokens.surfaceSolid,
          borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
          border: Border.all(color: selected ? ThemeTokens.primary : ThemeTokens.hairline),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: ThemeTokens.bodyLarge.copyWith(fontSize: 13.5, color: selected ? Colors.white : ThemeTokens.textPrimary),
        ),
      ),
    );
  }
}
