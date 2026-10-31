import 'package:flutter/material.dart';
import '../components/app_button.dart' show AppPrimaryButton;
import '../components/app_text_field.dart';
import '../components/custom_toast.dart';
import '../services/mail_recipients_api_service.dart';
import '../services/mail_settings_api_service.dart';
import '../utils/error_messages.dart';
import '../utils/theme_tokens.dart';

/// SUPER_ADMIN-only: the SMTP account every automated email is sent from, the recipient list
/// (each person opts in per report type), and a test send. The password is never shown back -
/// a blank field keeps the one already saved.
class MailSettingsScreen extends StatefulWidget {
  const MailSettingsScreen({super.key});

  @override
  State<MailSettingsScreen> createState() => _MailSettingsScreenState();
}

class _MailSettingsScreenState extends State<MailSettingsScreen> {
  final _service = MailSettingsApiService();
  final _recipientsService = MailRecipientsApiService();
  final _hostController = TextEditingController();
  final _portController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _testRecipientController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _sendingTest = false;
  bool _passwordSet = false;
  bool _obscurePassword = true;
  List<MailRecipient> _recipients = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _testRecipientController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final view = await _service.get();
      final recipients = await _recipientsService.list();
      if (!mounted) return;
      setState(() {
        _hostController.text = view.smtpHost;
        _portController.text = view.smtpPort.toString();
        _usernameController.text = view.smtpUsername ?? '';
        _passwordSet = view.passwordSet;
        _recipients = recipients;
      });
    } catch (e) {
      if (mounted) CustomToast.show(context, ErrorMessages.translate(context, e), isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _reloadRecipients() async {
    try {
      final recipients = await _recipientsService.list();
      if (mounted) setState(() => _recipients = recipients);
    } catch (e) {
      if (mounted) CustomToast.show(context, ErrorMessages.translate(context, e), isError: true);
    }
  }

  Future<void> _save() async {
    final port = int.tryParse(_portController.text.trim());
    if (_hostController.text.trim().isEmpty || port == null) {
      CustomToast.show(context, "Host and port are required", isError: true);
      return;
    }
    setState(() => _saving = true);
    try {
      final view = await _service.save(
        host: _hostController.text.trim(),
        port: port,
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      setState(() {
        _passwordSet = view.passwordSet;
        _passwordController.clear();
      });
      CustomToast.show(context, "Email settings saved", isError: false);
    } catch (e) {
      if (mounted) CustomToast.show(context, ErrorMessages.translate(context, e), isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _sendTest() async {
    final recipient = _testRecipientController.text.trim();
    if (recipient.isEmpty) {
      CustomToast.show(context, "Enter a recipient for the test email", isError: true);
      return;
    }
    setState(() => _sendingTest = true);
    try {
      await _service.sendTest(recipient);
      if (mounted) CustomToast.show(context, "Test email sent to $recipient", isError: false);
    } catch (e) {
      if (mounted) CustomToast.show(context, ErrorMessages.translate(context, e), isError: true);
    } finally {
      if (mounted) setState(() => _sendingTest = false);
    }
  }

  Future<void> _openRecipientDialog({MailRecipient? existing}) async {
    final emailController = TextEditingController(text: existing?.email ?? '');
    final nameController = TextEditingController(text: existing?.name ?? '');
    bool payroll = existing?.receivesPayroll ?? true;
    bool attendance = existing?.receivesAttendance ?? true;
    bool production = existing?.receivesProduction ?? true;
    bool active = existing?.active ?? true;
    bool saving = false;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: ThemeTokens.surfaceSolid,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge)),
          title: Text(existing == null ? "Add recipient" : "Edit recipient", style: ThemeTokens.headingMedium),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(controller: nameController, label: "Name", hint: "e.g. Accounts team"),
                const SizedBox(height: 14),
                AppTextField(
                  controller: emailController,
                  label: "Email",
                  hint: "name@example.com",
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),
                Text("RECEIVES", style: ThemeTokens.labelSmall),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Payroll sheets"),
                  value: payroll,
                  onChanged: (v) => setDialogState(() => payroll = v ?? false),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Daily attendance"),
                  value: attendance,
                  onChanged: (v) => setDialogState(() => attendance = v ?? false),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Daily production"),
                  value: production,
                  onChanged: (v) => setDialogState(() => production = v ?? false),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Active"),
                  subtitle: const Text("Turn off to pause all emails to this address"),
                  value: active,
                  onChanged: (v) => setDialogState(() => active = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text("Cancel")),
            AppPrimaryButton(
              label: "Save",
              isLoading: saving,
              onPressed: saving
                  ? null
                  : () async {
                      final draft = MailRecipientDraft(
                        email: emailController.text.trim(),
                        name: nameController.text.trim(),
                        receivesPayroll: payroll,
                        receivesAttendance: attendance,
                        receivesProduction: production,
                        active: active,
                      );
                      setDialogState(() => saving = true);
                      try {
                        if (existing == null) {
                          await _recipientsService.create(draft);
                        } else {
                          await _recipientsService.update(existing.id, draft);
                        }
                        if (dialogContext.mounted) Navigator.of(dialogContext).pop(true);
                      } catch (e) {
                        setDialogState(() => saving = false);
                        if (dialogContext.mounted) {
                          CustomToast.show(dialogContext, ErrorMessages.translate(dialogContext, e), isError: true);
                        }
                      }
                    },
            ),
          ],
        ),
      ),
    );

    if (saved == true) {
      if (mounted) CustomToast.show(context, existing == null ? "Recipient added" : "Recipient updated", isError: false);
      _reloadRecipients();
    }
  }

  Future<void> _deleteRecipient(MailRecipient recipient) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: ThemeTokens.surfaceSolid,
        title: Text("Remove recipient?", style: ThemeTokens.headingMedium),
        content: Text("${recipient.email} will stop receiving SMO emails.", style: ThemeTokens.bodyMedium),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text("Remove")),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _recipientsService.delete(recipient.id);
      if (mounted) CustomToast.show(context, "Recipient removed", isError: false);
      _reloadRecipients();
    } catch (e) {
      if (mounted) CustomToast.show(context, ErrorMessages.translate(context, e), isError: true);
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

  Widget _tag(String label, bool on) {
    return Container(
      margin: const EdgeInsets.only(right: 6, top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: on ? ThemeTokens.primary.withValues(alpha: 0.15) : ThemeTokens.surfaceSunken,
        borderRadius: BorderRadius.circular(ThemeTokens.radiusPill),
      ),
      child: Text(
        label,
        style: ThemeTokens.caption.copyWith(
          color: on ? ThemeTokens.primaryDark : ThemeTokens.textLight,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _recipientTile(MailRecipient r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
      decoration: BoxDecoration(
        color: ThemeTokens.surfaceSunken,
        borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.name?.isNotEmpty == true ? r.name! : r.email,
                  style: ThemeTokens.bodyLarge.copyWith(fontSize: 14.5),
                ),
                if (r.name?.isNotEmpty == true) Text(r.email, style: ThemeTokens.caption),
                Wrap(
                  children: [
                    _tag("Payroll", r.receivesPayroll),
                    _tag("Attendance", r.receivesAttendance),
                    _tag("Production", r.receivesProduction),
                    if (!r.active) _tag("Paused", false),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: "Edit",
            onPressed: () => _openRecipientDialog(existing: r),
            icon: const Icon(Icons.edit_outlined, color: ThemeTokens.textSecondary),
          ),
          IconButton(
            tooltip: "Remove",
            onPressed: () => _deleteRecipient(r),
            icon: const Icon(Icons.delete_outline_rounded, color: ThemeTokens.error),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: ThemeTokens.primary));
    }
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _card(
          title: "Recipients",
          subtitle: "Who receives each email. Tick the reports each person should get.",
          children: [
            if (_recipients.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Text("No recipients yet. Add the first one below.", style: ThemeTokens.bodyMedium),
              ),
            ..._recipients.map(_recipientTile),
            const SizedBox(height: 6),
            AppPrimaryButton(label: "Add recipient", onPressed: () => _openRecipientDialog()),
          ],
        ),
        const SizedBox(height: 16),
        _card(
          title: "Sending account",
          subtitle: "Every automated email (payroll, daily attendance, daily production) is sent from this account.",
          children: [
            AppTextField(controller: _hostController, label: "SMTP host", hint: "smtp.gmail.com"),
            const SizedBox(height: 14),
            AppTextField(
              controller: _portController,
              label: "SMTP port",
              hint: "587",
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _usernameController,
              label: "Email address",
              hint: "name@example.com",
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _passwordController,
              label: "App password",
              hint: _passwordSet ? "Saved - leave blank to keep it" : "Gmail app password",
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 20,
                  color: ThemeTokens.textLight,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _passwordSet ? "A password is saved on the server." : "No password saved yet.",
              style: ThemeTokens.caption.copyWith(
                color: _passwordSet ? ThemeTokens.success : ThemeTokens.warning,
              ),
            ),
            const SizedBox(height: 18),
            AppPrimaryButton(label: "Save", onPressed: _saving ? null : _save, isLoading: _saving),
          ],
        ),
        const SizedBox(height: 16),
        _card(
          title: "Send a test email",
          subtitle: "Checks the saved settings by sending a short message to the address below.",
          children: [
            AppTextField(
              controller: _testRecipientController,
              label: "Recipient",
              hint: "name@example.com",
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 18),
            AppPrimaryButton(
              label: "Send Test Email",
              onPressed: _sendingTest ? null : _sendTest,
              isLoading: _sendingTest,
            ),
          ],
        ),
      ],
    );
  }
}
