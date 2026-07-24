import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';
import '../../utils/theme_tokens.dart';

/// Opens a downloaded report response - normally a PDF preview, but the
/// backend occasionally falls back to raw HTML if the AI output didn't
/// render cleanly, so that rare case is shown as plain text instead.
Future<void> openReportResponse(BuildContext context, http.Response response, String filename) async {
  final contentType = response.headers['content-type'] ?? '';
  if (contentType.contains('application/pdf')) {
    await Printing.layoutPdf(onLayout: (_) async => response.bodyBytes, name: filename);
    return;
  }

  if (!context.mounted) return;
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: ThemeTokens.surfaceSolid,
      title: Text("Report (HTML fallback)", style: ThemeTokens.headingMedium.copyWith(fontSize: 16)),
      content: SingleChildScrollView(
        child: Text(response.body, style: ThemeTokens.bodyMedium),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Close")),
      ],
    ),
  );
}
