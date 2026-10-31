import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../components/app_text_field.dart';
import '../components/confirm_dialog.dart';
import '../components/custom_toast.dart';
import '../components/section_card.dart';
import '../models/role_detail.dart';
import '../models/role_request.dart';
import '../services/role_api_service.dart';
import '../utils/activity_catalog.dart';
import '../utils/theme_tokens.dart';

class RoleFormScreen extends StatefulWidget {
  final RoleDetail? existing;

  const RoleFormScreen({super.key, this.existing});

  bool get isEditMode => existing != null;

  @override
  State<RoleFormScreen> createState() => _RoleFormScreenState();
}

class _RoleFormScreenState extends State<RoleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final RoleApiService _apiService = RoleApiService();
  final _roleNameController = TextEditingController();

  final Set<String> _selectedActivities = {};
  bool _active = true;
  bool _isSaving = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _roleNameController.text = existing.roleName;
      _selectedActivities.addAll(existing.activities);
      _active = existing.isActive;
      _refreshFromServer(existing.roleId);
    }
  }

  /// The list this screen was opened from may itself be showing a cached, stale copy
  /// (e.g. right after another admin action changed this role elsewhere). Silently
  /// re-fetches this one role fresh and repopulates the form if anything differs -
  /// the initial render still shows the passed-in data immediately, this just corrects
  /// it a moment later rather than leaving the edit form editing stale values.
  Future<void> _refreshFromServer(int roleId) async {
    try {
      final fresh = await _apiService.getRole(roleId, forceRefresh: true);
      if (!mounted) return;
      setState(() {
        _roleNameController.text = fresh.roleName;
        _selectedActivities
          ..clear()
          ..addAll(fresh.activities);
        _active = fresh.isActive;
      });
    } catch (_) {
      // Keep showing what was passed in - a failed background refresh is no worse.
    }
  }

  @override
  void dispose() {
    _roleNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedActivities.isEmpty) {
      CustomToast.show(context, L10n.of(context).selectAtLeastOneActivity, isError: true);
      return;
    }

    setState(() => _isSaving = true);
    try {
      if (widget.isEditMode) {
        await _apiService.updateRole(
          widget.existing!.roleId,
          RoleUpdateRequest(
            roleName: _roleNameController.text.trim().toUpperCase(),
            activities: _selectedActivities.toList(),
            status: _active ? 'ACTIVE' : 'INACTIVE',
          ),
        );
      } else {
        await _apiService.createRole(
          RoleCreateRequest(
            roleName: _roleNameController.text.trim().toUpperCase(),
            activities: _selectedActivities.toList(),
          ),
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      CustomToast.show(context, e.toString().replaceAll("Exception: ", ""), isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteRole() async {
    final existing = widget.existing;
    if (existing == null) return;

    final confirmed = await showConfirmDialog(
      context,
      title: L10n.of(context).deleteRole,
      message: "This will permanently delete the ${existing.roleName} role. This cannot be undone.",
    );
    if (!confirmed) return;

    setState(() => _isDeleting = true);
    try {
      await _apiService.deleteRole(existing.roleId);
      if (!mounted) return;
      CustomToast.show(context, L10n.of(context).roleDeleted);
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      CustomToast.show(context, e.toString().replaceAll("Exception: ", ""), isError: true);
      setState(() => _isDeleting = false);
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
          widget.isEditMode ? L10n.of(context).editRole : L10n.of(context).addRole,
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
                  title: L10n.of(context).roleDetails,
                  icon: Icons.shield_outlined,
                  child: Column(
                    children: [
                      AppTextField(
                        label: L10n.of(context).roleName,
                        controller: _roleNameController,
                        hint: "e.g. HR_MANAGER",
                        validator: (v) => (v == null || v.trim().isEmpty) ? L10n.of(context).roleNameIsRequired : null,
                      ),
                      if (widget.isEditMode) ...[
                        const SizedBox(height: 16.0),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _active,
                          onChanged: (v) => setState(() => _active = v),
                          activeThumbColor: ThemeTokens.primary,
                          title: Text(L10n.of(context).active, style: ThemeTokens.labelSmall),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
                SectionCard(
                  title: L10n.of(context).accessibleActivities,
                  icon: Icons.checklist_outlined,
                  child: Column(
                    children: ActivityCatalog.all.map((activity) {
                      final checked = _selectedActivities.contains(activity.code);
                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: checked,
                        onChanged: (v) {
                          setState(() {
                            if (v == true) {
                              _selectedActivities.add(activity.code);
                            } else {
                              _selectedActivities.remove(activity.code);
                            }
                          });
                        },
                        activeColor: ThemeTokens.primary,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(activity.label, style: ThemeTokens.bodyMedium.copyWith(color: ThemeTokens.textPrimary)),
                        subtitle: Text(activity.code, style: ThemeTokens.caption),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: _isSaving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeTokens.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                        )
                      : Text(widget.isEditMode ? L10n.of(context).saveChanges : L10n.of(context).createRole, style: ThemeTokens.buttonText),
                ),
                if (widget.isEditMode) ...[
                  const SizedBox(height: 12.0),
                  ElevatedButton.icon(
                    onPressed: _isDeleting ? null : _deleteRole,
                    icon: _isDeleting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                          )
                        : const Icon(Icons.delete_outline_rounded),
                    label: Text(L10n.of(context).deleteRole),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeTokens.error,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
