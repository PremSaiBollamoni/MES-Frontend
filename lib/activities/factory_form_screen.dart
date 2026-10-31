import 'dart:convert';
import 'package:flutter/material.dart';
import '../components/app_button.dart';
import '../components/app_text_field.dart';
import '../components/confirm_dialog.dart';
import '../components/custom_toast.dart';
import '../components/section_card.dart';
import '../models/factory_detail.dart';
import '../services/factory_api_service.dart';
import '../utils/theme_tokens.dart';

/// SUPER_ADMIN only. Creates a new factory, or edits an existing one's details
/// and its HRMS connection - either the factory's own external HRMS, or the
/// HRMS this app's operator provides to factories that don't have one. Leaving
/// HRMS entirely off is also valid for a factory that doesn't use it at all.
class FactoryFormScreen extends StatefulWidget {
  final FactoryDetail? existing;

  const FactoryFormScreen({super.key, this.existing});

  bool get isEditMode => existing != null;

  @override
  State<FactoryFormScreen> createState() => _FactoryFormScreenState();
}

class _FactoryFormScreenState extends State<FactoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FactoryApiService _apiService = FactoryApiService();

  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _locationController = TextEditingController();
  final _hrmsUrlController = TextEditingController();
  final _hrmsUsernameController = TextEditingController();
  final _hrmsPasswordController = TextEditingController();

  bool _active = true;
  bool _hrmsEnabled = true;
  bool _isSaving = false;
  bool _isTestingConnection = false;
  HrmsConnectionTestResult? _lastTestResult;
  bool _isFixingUsernames = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _applyFactoryData(existing);
      _refreshFromServer(existing.factoryId);
    }
  }

  void _applyFactoryData(FactoryDetail factory) {
    _nameController.text = factory.factoryName;
    _codeController.text = factory.factoryCode;
    _locationController.text = factory.location ?? '';
    _active = factory.active;
    _hrmsEnabled = factory.hrmsEnabled;
    final configJson = factory.hrmsConfigJson;
    if (configJson != null && configJson.isNotEmpty) {
      try {
        final config = HrmsFactoryConfig.fromJson(json.decode(configJson) as Map<String, dynamic>);
        _hrmsUrlController.text = config.baseUrl;
        _hrmsUsernameController.text = config.username;
        _hrmsPasswordController.text = config.password;
      } catch (_) {
        // Malformed or legacy config - leave the fields blank rather than crash the form.
      }
    }
  }

  /// The list this screen was opened from may be showing a cached, stale copy (e.g.
  /// right after Fix Usernames or another admin action changed this factory
  /// elsewhere). Silently re-fetches fresh and repopulates the form if anything
  /// differs - the initial render still shows the passed-in data immediately.
  Future<void> _refreshFromServer(int factoryId) async {
    try {
      final fresh = await _apiService.getFactory(factoryId, forceRefresh: true);
      if (!mounted) return;
      setState(() => _applyFactoryData(fresh));
    } catch (_) {
      // Keep showing what was passed in - a failed background refresh is no worse.
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _locationController.dispose();
    _hrmsUrlController.dispose();
    _hrmsUsernameController.dispose();
    _hrmsPasswordController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    final baseUrl = _hrmsUrlController.text.trim();
    final username = _hrmsUsernameController.text.trim();
    final password = _hrmsPasswordController.text;
    if (baseUrl.isEmpty || username.isEmpty || password.isEmpty) {
      CustomToast.show(context, "Fill in URL, username and password first", isError: true);
      return;
    }

    setState(() {
      _isTestingConnection = true;
      _lastTestResult = null;
    });
    try {
      final result = await _apiService.testHrmsConnection(
        HrmsFactoryConfig(baseUrl: baseUrl, username: username, password: password),
      );
      if (!mounted) return;
      setState(() => _lastTestResult = result);
      CustomToast.show(context, result.message, isError: !result.success);
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceAll("Exception: ", "");
      setState(() => _lastTestResult = HrmsConnectionTestResult(success: false, message: message, employeeCount: 0));
      CustomToast.show(context, message, isError: true);
    } finally {
      if (mounted) setState(() => _isTestingConnection = false);
    }
  }

  Future<void> _fixUsernames() async {
    final existing = widget.existing;
    if (existing == null) return;

    final confirmed = await showConfirmDialog(
      context,
      title: "Fix usernames for ${existing.factoryName}?",
      message: "This renumbers EVERY employee in this factory to ${existing.factoryCode}001, "
          "${existing.factoryCode}002, etc. This changes real login usernames immediately - "
          "affected employees will need their new username to log in. This cannot be undone "
          "automatically. Continue?",
      confirmLabel: "Fix Usernames",
    );
    if (!confirmed) return;

    setState(() => _isFixingUsernames = true);
    try {
      final changes = await _apiService.fixUsernames(existing.factoryId);
      if (!mounted) return;
      if (changes.isEmpty) {
        CustomToast.show(context, "All usernames already match - nothing to change");
      } else {
        await _showUsernameChangesDialog(changes);
      }
    } catch (e) {
      if (!mounted) return;
      CustomToast.show(context, e.toString().replaceAll("Exception: ", ""), isError: true);
    } finally {
      if (mounted) setState(() => _isFixingUsernames = false);
    }
  }

  Future<void> _showUsernameChangesDialog(List<UsernameChange> changes) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text("${changes.length} username(s) changed", style: ThemeTokens.headingMedium.copyWith(fontSize: 18)),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Give each employee their new username below - their old one no longer works.",
                style: ThemeTokens.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12.0),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: changes.length,
                  itemBuilder: (context, index) {
                    final c = changes[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: Text(c.employeeName, style: ThemeTokens.bodyMedium)),
                          Expanded(child: Text(c.oldUsername, style: ThemeTokens.caption)),
                          const Icon(Icons.arrow_forward_rounded, size: 14, color: ThemeTokens.textLight),
                          const SizedBox(width: 6.0),
                          Expanded(
                            child: Text(c.newUsername, style: ThemeTokens.bodyMedium.copyWith(fontWeight: FontWeight.w700, color: ThemeTokens.success)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: ThemeTokens.primary, foregroundColor: Colors.white),
            child: const Text("Done"),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      FactoryDetail saved;
      if (widget.isEditMode) {
        saved = await _apiService.updateFactory(
          widget.existing!.factoryId,
          FactoryUpdateRequest(
            factoryName: _nameController.text.trim(),
            factoryCode: _codeController.text.trim().toUpperCase(),
            location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
            hrmsEnabled: _hrmsEnabled,
            isActive: _active,
          ),
        );
      } else {
        saved = await _apiService.createFactory(
          FactoryCreateRequest(
            factoryName: _nameController.text.trim(),
            factoryCode: _codeController.text.trim().toUpperCase(),
            location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
          ),
        );
      }

      // HRMS connection details are saved separately (their own endpoint) so a
      // factory with no HRMS at all never has to touch this step.
      if (_hrmsEnabled && _hrmsUrlController.text.trim().isNotEmpty) {
        await _apiService.updateHrmsConfig(
          saved.factoryId,
          HrmsFactoryConfig(
            baseUrl: _hrmsUrlController.text.trim(),
            username: _hrmsUsernameController.text.trim(),
            password: _hrmsPasswordController.text,
          ),
        );
      }

      if (!mounted) return;
      CustomToast.show(context, widget.isEditMode ? "Factory updated" : "Factory created");
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      CustomToast.show(context, e.toString().replaceAll("Exception: ", ""), isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      appBar: AppBar(
        backgroundColor: ThemeTokens.surfaceSolid,
        elevation: 0,
        title: Text(
          widget.isEditMode ? "Edit Factory" : "Add Factory",
          style: ThemeTokens.headingMedium.copyWith(color: ThemeTokens.textPrimary),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionCard(
                  title: "Factory Details",
                  icon: Icons.factory_outlined,
                  child: Column(
                    children: [
                      AppTextField(
                        label: "Factory Name",
                        controller: _nameController,
                        hint: "e.g. GramTarang Berhampur",
                        validator: (v) => (v == null || v.trim().isEmpty) ? "Factory name is required" : null,
                      ),
                      const SizedBox(height: 16.0),
                      AppTextField(
                        label: "Factory Code",
                        controller: _codeController,
                        hint: "e.g. GTGBZA",
                        validator: (v) => (v == null || v.trim().isEmpty) ? "Factory code is required" : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          "Used as the prefix for new employees' usernames in this factory (e.g. GTGBZA001).",
                          style: ThemeTokens.caption,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      AppTextField(label: "Location", controller: _locationController, hint: "e.g. Berhampur, Odisha"),
                      if (widget.isEditMode) ...[
                        const SizedBox(height: 16.0),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _active,
                          onChanged: (v) => setState(() => _active = v),
                          activeThumbColor: ThemeTokens.primary,
                          title: Text("Active", style: ThemeTokens.labelSmall),
                        ),
                        const SizedBox(height: 8.0),
                        AppGhostButton(
                          label: "Fix Usernames",
                          icon: Icons.badge_outlined,
                          color: ThemeTokens.error,
                          onPressed: _isFixingUsernames ? null : _fixUsernames,
                          isLoading: _isFixingUsernames,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            "Renumbers every employee here to match the factory code above. Changes real login usernames.",
                            style: ThemeTokens.caption,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
                SectionCard(
                  title: "HRMS Configuration",
                  icon: Icons.badge_outlined,
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _hrmsEnabled,
                        onChanged: (v) => setState(() => _hrmsEnabled = v),
                        activeThumbColor: ThemeTokens.primary,
                        title: Text("HRMS Enabled", style: ThemeTokens.labelSmall),
                        subtitle: Text(
                          "Turn off for a factory with no biometric attendance / HR system at all.",
                          style: ThemeTokens.caption,
                        ),
                      ),
                      if (_hrmsEnabled) ...[
                        const SizedBox(height: 12.0),
                        Text(
                          "Point this at the factory's own HRMS, or the shared HRMS this app's "
                          "operator provides to factories that don't have one.",
                          style: ThemeTokens.caption,
                        ),
                        const SizedBox(height: 16.0),
                        AppTextField(
                          label: "HRMS Base URL",
                          controller: _hrmsUrlController,
                          hint: "https://hrms.example.com",
                          keyboardType: TextInputType.url,
                        ),
                        const SizedBox(height: 16.0),
                        AppTextField(label: "HRMS Username", controller: _hrmsUsernameController),
                        const SizedBox(height: 16.0),
                        AppTextField(
                          label: "HRMS Password",
                          controller: _hrmsPasswordController,
                          obscureText: true,
                        ),
                        const SizedBox(height: 16.0),
                        AppGhostButton(
                          label: "Test Connection",
                          icon: Icons.wifi_tethering_rounded,
                          onPressed: _isTestingConnection ? null : _testConnection,
                          isLoading: _isTestingConnection,
                        ),
                        if (_lastTestResult != null) ...[
                          const SizedBox(height: 12.0),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                _lastTestResult!.success ? Icons.check_circle_rounded : Icons.error_rounded,
                                size: 18,
                                color: _lastTestResult!.success ? ThemeTokens.success : ThemeTokens.error,
                              ),
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: Text(
                                  _lastTestResult!.message,
                                  style: ThemeTokens.caption.copyWith(
                                    color: _lastTestResult!.success ? ThemeTokens.success : ThemeTokens.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),
                AppPrimaryButton(
                  label: widget.isEditMode ? "Save Changes" : "Create Factory",
                  onPressed: _isSaving ? null : _submit,
                  isLoading: _isSaving,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
