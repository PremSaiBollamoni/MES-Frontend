import 'package:flutter/material.dart';
import '../../models/scanned_page.dart';
import '../../utils/theme_tokens.dart';

/// Header for a scanned page: the shift date (tappable, because a misread year is the one error
/// that hides the whole import) alongside the totals about to be written.
class ScanPageSummary extends StatelessWidget {
  final ScannedPage page;
  final VoidCallback onPickDate;

  const ScanPageSummary({super.key, required this.page, required this.onPickDate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: ThemeTokens.ink,
        borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onPickDate,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SHIFT DATE',
                      style: ThemeTokens.labelSmall
                          .copyWith(fontSize: 8.5, color: ThemeTokens.textLight)),
                  const SizedBox(height: 3.0),
                  Row(
                    children: [
                      Text(page.shiftDate ?? 'Not read — tap to set',
                          style: ThemeTokens.headingMedium.copyWith(
                              color: page.shiftDate == null ? ThemeTokens.warning : Colors.white,
                              fontSize: 17)),
                      const SizedBox(width: 6.0),
                      const Icon(Icons.edit_rounded, size: 13, color: ThemeTokens.textLight),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${page.totalPieces}',
                  style: ThemeTokens.headingLarge.copyWith(color: ThemeTokens.accentLight, fontSize: 24)),
              Text('pieces · ${page.entryCount} entries',
                  style: ThemeTokens.caption.copyWith(fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

/// The commit action. Nothing reaches the production log until this is pressed.
class ScanSaveBar extends StatelessWidget {
  final int entryCount;
  final bool isSaving;
  final VoidCallback onSave;

  const ScanSaveBar({
    super.key,
    required this.entryCount,
    required this.isSaving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: ThemeTokens.background,
        border: Border(top: BorderSide(color: ThemeTokens.hairline)),
      ),
      child: ElevatedButton(
        onPressed: isSaving ? null : onSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeTokens.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium)),
        ),
        child: isSaving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text('Confirm & save $entryCount entries',
                style: ThemeTokens.buttonText),
      ),
    );
  }
}
