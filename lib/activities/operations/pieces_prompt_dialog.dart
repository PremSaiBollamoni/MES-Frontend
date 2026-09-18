import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/theme_tokens.dart';

/// Small numeric prompt reused for "pieces issued" (Start Tracking) and
/// "pieces completed" (Stop Tracking) - both are just "how many pieces?".
Future<int?> showPiecesPromptDialog(
  BuildContext context, {
  required String title,
  required String label,
  int? initialValue,
}) {
  final controller = TextEditingController(text: initialValue != null ? initialValue.toString() : "");
  String? error;

  return showDialog<int>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          void submit() {
            final value = int.tryParse(controller.text.trim());
            if (value == null || value <= 0) {
              setState(() => error = L10n.of(context).enterAWholeNumberGreater);
              return;
            }
            Navigator.of(dialogContext).pop(value);
          }

          return AlertDialog(
            title: Text(title, style: ThemeTokens.headingMedium.copyWith(fontSize: 18)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: label),
                  onSubmitted: (_) => submit(),
                ),
                if (error != null) ...[
                  const SizedBox(height: 10.0),
                  Text(error!, style: ThemeTokens.caption.copyWith(color: ThemeTokens.error)),
                ],
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text(L10n.of(context).cancel)),
              ElevatedButton(
                onPressed: submit,
                style: ElevatedButton.styleFrom(backgroundColor: ThemeTokens.primary, foregroundColor: Colors.white),
                child: Text(L10n.of(context).confirm),
              ),
            ],
          );
        },
      );
    },
  );
}
