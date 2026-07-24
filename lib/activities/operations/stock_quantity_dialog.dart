import 'package:flutter/material.dart';
import '../../utils/theme_tokens.dart';

/// Prompts the Supervisor for the current stock quantity on hand for a
/// station; AVAILABLE/NO_STOCK is then derived server-side against the
/// station's configured minimum threshold - the Supervisor never picks it.
Future<int?> showStockQuantityDialog(
  BuildContext context, {
  required String stationLabel,
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
            if (value == null || value < 0) {
              setState(() => error = "Enter a whole number, zero or more");
              return;
            }
            Navigator.of(dialogContext).pop(value);
          }

          return AlertDialog(
            title: Text("Log Stock", style: ThemeTokens.headingMedium.copyWith(fontSize: 18)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stationLabel, style: ThemeTokens.bodyMedium),
                const SizedBox(height: 12.0),
                TextField(
                  controller: controller,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Current stock on hand"),
                  onSubmitted: (_) => submit(),
                ),
                if (error != null) ...[
                  const SizedBox(height: 10.0),
                  Text(error!, style: ThemeTokens.caption.copyWith(color: ThemeTokens.error)),
                ],
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text("Cancel")),
              ElevatedButton(
                onPressed: submit,
                style: ElevatedButton.styleFrom(backgroundColor: ThemeTokens.primary, foregroundColor: Colors.white),
                child: const Text("Save"),
              ),
            ],
          );
        },
      );
    },
  );
}
