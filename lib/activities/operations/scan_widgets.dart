import 'package:flutter/material.dart';
import '../../utils/theme_tokens.dart';

/// Shared presentation pieces for the book-scanning flow.

/// The eight shift slots each numbered book hour maps onto. Mirrors ShiftHours on the server.
const List<String> kShiftHourLabels = [
  '09:00 - 10:00', '10:00 - 11:00', '11:00 - 12:00', '12:00 - 13:00',
  '13:30 - 14:30', '14:30 - 15:30', '15:30 - 16:30', '16:30 - 17:30',
];

/// Running tally while working through a book, so progress is visible without counting pages.
class ScanProgressBanner extends StatelessWidget {
  final int pagesSaved;
  final int entriesSaved;

  const ScanProgressBanner({super.key, required this.pagesSaved, required this.entriesSaved});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: ThemeTokens.ink,
        borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded, color: ThemeTokens.success, size: 20),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text('$pagesSaved page(s) saved  ·  $entriesSaved entries',
                style: ThemeTokens.bodyLarge.copyWith(color: Colors.white, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

/// Photography guidance. Reading accuracy depends more on how the page is shot than on anything
/// else, so the advice sits in front of the supervisor rather than in a manual.
class ScanGuidanceCard extends StatelessWidget {
  const ScanGuidanceCard({super.key});

  static const List<String> _tips = [
    'Lay the page flat and shoot square-on',
    'Good light, no shadow across the table',
    'Fit the whole table in frame, including the date',
    'Keep fingers off the printed area',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: ThemeTokens.surfaceSolid,
        borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('FOR A GOOD READ', style: ThemeTokens.labelSmall.copyWith(fontSize: 9)),
          const SizedBox(height: 10.0),
          ..._tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 5.0),
                      child: Icon(Icons.circle, size: 5, color: ThemeTokens.primary),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                        child: Text(tip, style: ThemeTokens.bodyMedium.copyWith(fontSize: 12.5))),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

/// Large tap target for capture actions - used one-handed while holding a book open.
class ScanActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool primary;
  final VoidCallback onTap;

  const ScanActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18.0),
        decoration: BoxDecoration(
          color: primary ? ThemeTokens.primary : ThemeTokens.surfaceSolid,
          borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
          border: primary ? null : Border.all(color: ThemeTokens.hairline),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: primary ? Colors.white : ThemeTokens.textSecondary, size: 20),
            const SizedBox(width: 12.0),
            Text(label,
                style: ThemeTokens.buttonText
                    .copyWith(color: primary ? Colors.white : ThemeTokens.textPrimary)),
          ],
        ),
      ),
    );
  }
}

/// Anything the supervisor must resolve before saving - an unread date, unmatched rows.
class ScanWarningBanner extends StatelessWidget {
  final String message;

  const ScanWarningBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10.0),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 11.0),
      decoration: BoxDecoration(
        color: ThemeTokens.warning.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(ThemeTokens.radiusSmall),
        border: Border.all(color: ThemeTokens.warning.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, size: 16, color: ThemeTokens.warning),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(message,
                style:
                    ThemeTokens.bodyMedium.copyWith(fontSize: 12, color: ThemeTokens.textPrimary)),
          ),
        ],
      ),
    );
  }
}

/// A tappable value chip inside a scanned row. Missing values are amber and bold so an
/// unresolved row reads as unfinished at a glance.
class ScanFieldChip extends StatelessWidget {
  final String label;
  final String value;
  final bool missing;

  const ScanFieldChip({
    super.key,
    required this.label,
    required this.value,
    required this.missing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: ThemeTokens.surfaceSunken,
        borderRadius: BorderRadius.circular(ThemeTokens.radiusSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: ThemeTokens.labelSmall.copyWith(fontSize: 8.5)),
          const SizedBox(height: 3.0),
          Text(
            value,
            style: ThemeTokens.bodyMedium.copyWith(
              fontSize: 13,
              color: missing ? ThemeTokens.warning : ThemeTokens.textPrimary,
              fontWeight: missing ? FontWeight.w700 : FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
