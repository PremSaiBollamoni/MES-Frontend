import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../components/app_button.dart' show AppPrimaryButton;
import '../components/app_text_field.dart';
import '../components/custom_toast.dart';
import '../models/factory_detail.dart';
import '../services/employee_export_api_service.dart';
import '../utils/error_messages.dart';
import '../utils/web_download.dart';
import '../utils/theme_tokens.dart';

/// SUPER_ADMIN-only: export one factory's employees as a spreadsheet (S.NO, name, username,
/// temporary password), or email it. Passwords are one-way hashes, so the sheet can only
/// show a password after giving the employee a new one - the old password stops working.
class EmployeeExportScreen extends StatefulWidget {
  final FactoryDetail factory;
  const EmployeeExportScreen({super.key, required this.factory});

  @override
  State<EmployeeExportScreen> createState() => _EmployeeExportScreenState();
}

class _EmployeeExportScreenState extends State<EmployeeExportScreen> {
  final _service = EmployeeExportApiService();
  final _recipientController = TextEditingController();
  bool _resetPasswords = true;
  bool _downloading = false;
  bool _sending = false;

  @override
  void dispose() {
    _recipientController.dispose();
    super.dispose();
  }

  Future<void> _download() async {
    setState(() => _downloading = true);
    try {
      final bytes = await _service.downloadEmployees(widget.factory.factoryId, resetPasswords: _resetPasswords);
      final safeName = widget.factory.factoryName.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '-');
      final filename = '$safeName-employees.xlsx';

      if (kIsWeb) {
        await downloadFileInBrowser(bytes, '$safeName-employees.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        if (!mounted) return;
        CustomToast.show(context, 'Download started');
      } else if (Platform.isWindows) {
        final dir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
        final file = File('${dir.path}\\$filename');
        await file.writeAsBytes(bytes);
        if (!mounted) return;
        CustomToast.show(context, 'Saved to ${file.path}');
      } else {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$filename');
        await file.writeAsBytes(bytes);
        if (!mounted) return;
        await Share.shareXFiles([XFile(file.path)]);
      }
    } catch (e) {
      if (!mounted) return;
      CustomToast.show(context, ErrorMessages.translate(context, e), isError: true);
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  Future<void> _email() async {
    final recipients = _recipientController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (recipients.isEmpty) {
      CustomToast.show(context, "Enter at least one recipient", isError: true);
      return;
    }
    setState(() => _sending = true);
    try {
      await _service.emailEmployees(widget.factory.factoryId, resetPasswords: _resetPasswords, recipients: recipients);
      if (!mounted) return;
      CustomToast.show(context, "Employee list sent to ${recipients.join(', ')}", isError: false);
    } catch (e) {
      if (!mounted) return;
      CustomToast.show(context, ErrorMessages.translate(context, e), isError: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Widget _card({required String title, required String subtitle, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeTokens.surfaceSolid,
        borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
        border: Border.all(color: ThemeTokens.hairline),
        boxShadow: ThemeTokens.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: ThemeTokens.headingMedium),
          const SizedBox(height: 4),
          Text(subtitle, style: ThemeTokens.caption),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      appBar: AppBar(
        backgroundColor: ThemeTokens.background,
        elevation: 0,
        title: Text("Export employees", style: ThemeTokens.headingMedium.copyWith(fontSize: 17)),
        iconTheme: const IconThemeData(color: ThemeTokens.textPrimary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(widget.factory.factoryName, style: ThemeTokens.bodyLarge),
          const SizedBox(height: 16),
          _card(
            title: "Passwords",
            subtitle: "Passwords are stored as one-way hashes, so the real ones cannot be exported.",
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Give every employee a new temporary password"),
                subtitle: Text(
                  _resetPasswords
                      ? "The sheet shows each new password. Current passwords stop working."
                      : "The sheet lists usernames only. No passwords change.",
                  style: ThemeTokens.caption,
                ),
                value: _resetPasswords,
                onChanged: (v) => setState(() => _resetPasswords = v),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _card(
            title: "Download",
            subtitle: "Save the list as an Excel file.",
            children: [
              AppPrimaryButton(label: "Download Excel", onPressed: _downloading ? null : _download, isLoading: _downloading),
            ],
          ),
          const SizedBox(height: 16),
          _card(
            title: "Email",
            subtitle: "Send the list as an attachment. Separate several addresses with commas.",
            children: [
              AppTextField(
                controller: _recipientController,
                label: "Recipients",
                hint: "name@example.com",
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 18),
              AppPrimaryButton(label: "Send Email", onPressed: _sending ? null : _email, isLoading: _sending),
            ],
          ),
        ],
      ),
    );
  }
}
