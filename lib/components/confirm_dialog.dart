import 'package:flutter/material.dart';
import '../utils/theme_tokens.dart';

/// Shows a destructive-action confirmation dialog. Returns true if confirmed.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = "Delete",
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(title, style: ThemeTokens.headingMedium.copyWith(fontSize: 18)),
        content: Text(message, style: ThemeTokens.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: ThemeTokens.error, foregroundColor: Colors.white),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
