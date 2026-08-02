import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../utils/theme_tokens.dart';

/// One editorial attendance row with a hairline separator. Shared across the
/// Live / Daily / Monthly attendance screens.
class AttendanceRow extends StatelessWidget {
  final String? leading;
  final String name;
  final String subtitle;
  final String times;
  final String status;
  final bool late;

  const AttendanceRow({
    super.key,
    this.leading,
    required this.name,
    required this.subtitle,
    required this.times,
    required this.status,
    required this.late,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: ThemeTokens.hairline))),
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Row(
        children: [
          if (leading != null) SizedBox(width: 42, child: Text(leading!, style: ThemeTokens.caption)),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: ThemeTokens.bodyLarge.copyWith(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2.0),
                Text(subtitle, style: ThemeTokens.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 10.0),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(times, style: ThemeTokens.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2.0),
                Text(
                  status.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ThemeTokens.labelSmall.copyWith(fontSize: 10, color: late ? ThemeTokens.warning : ThemeTokens.success),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact search field - jump to one employee instead of scrolling the roster.
class AttendanceSearchField extends StatelessWidget {
  final TextEditingController controller;
  const AttendanceSearchField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: ThemeTokens.inputText,
      cursorColor: ThemeTokens.primary,
      decoration: InputDecoration(
        hintText: L10n.of(context).searchByNameOrCode,
        hintStyle: ThemeTokens.hintText,
        prefixIcon: const Icon(Icons.search_rounded, size: 19, color: ThemeTokens.textLight),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(icon: const Icon(Icons.close_rounded, size: 18, color: ThemeTokens.textLight), onPressed: controller.clear),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
        filled: true,
        fillColor: ThemeTokens.surfaceSolid,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium), borderSide: const BorderSide(color: ThemeTokens.hairline)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium), borderSide: const BorderSide(color: ThemeTokens.hairline)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium), borderSide: const BorderSide(color: ThemeTokens.primary, width: 1.5)),
      ),
    );
  }
}

/// Dark ink panel with up to three hairline-divided figures. Used for the live
/// present/absent/late summary and monthly totals.
class SummaryPanel extends StatelessWidget {
  final String eyebrow;
  final List<({String value, String label, Color color})> figures;

  const SummaryPanel({super.key, required this.eyebrow, required this.figures});

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < figures.length; i++) {
      final f = figures[i];
      children.add(Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(f.value, style: ThemeTokens.headingLarge.copyWith(color: ThemeTokens.onInk, fontSize: 26)),
            const SizedBox(height: 3.0),
            Row(
              children: [
                Container(width: 5, height: 5, decoration: BoxDecoration(color: f.color, shape: BoxShape.circle)),
                const SizedBox(width: 6.0),
                Flexible(child: Text(f.label.toUpperCase(), style: ThemeTokens.labelSmall.copyWith(color: ThemeTokens.textLight, fontSize: 10), overflow: TextOverflow.ellipsis)),
              ],
            ),
          ],
        ),
      ));
      if (i != figures.length - 1) {
        children.add(Container(width: 1, height: 40, color: ThemeTokens.inkDivider, margin: const EdgeInsets.only(right: 16.0)));
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22.0),
      decoration: BoxDecoration(color: ThemeTokens.ink, borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(eyebrow.toUpperCase(), style: ThemeTokens.labelSmall.copyWith(color: ThemeTokens.textLight, fontSize: 10)),
          const SizedBox(height: 18.0),
          Row(children: children),
        ],
      ),
    );
  }
}

/// Shared empty / message state for the attendance list screens.
class AttendanceMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Widget? action;

  const AttendanceMessage({super.key, required this.icon, required this.title, required this.body, this.action});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: ThemeTokens.textLight, size: 38),
            const SizedBox(height: 14.0),
            Text(title, style: ThemeTokens.headingMedium.copyWith(fontSize: 16), textAlign: TextAlign.center),
            const SizedBox(height: 6.0),
            Text(body, style: ThemeTokens.bodyMedium, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 20.0), action!],
          ],
        ),
      ),
    );
  }
}
