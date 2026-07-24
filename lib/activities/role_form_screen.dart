import 'package:flutter/material.dart';
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
      CustomToast.show(context, "Select at least one activity", isError: true);
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
      title: "Delete Role",
      message: "This will permanently delete the ${existing.roleName} role. This cannot be undone.",
    );
    if (!confirmed) return;

    setState(() => _isDeleting = true);
    try {
      await _apiService.deleteRole(existing.roleId);
      if (!mounted) return;
      CustomToast.show(context, "Role deleted");
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
          widget.isEditMode ? "Edit Role" : "Add Role",
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
                  title: "Role Details",
                  icon: Icons.shield_outlined,
                  child: Column(
                    children: [
                      AppTextField(
                        label: "Role Name",
                        controller: _roleNameController,
                        hint: "e.g. HR_MANAGER",
                        validator: (v) => (v == null || v.trim().isEmpty) ? "Role name is required" : null,
                      ),
                      if (widget.isEditMode) ...[
                        const SizedBox(height: 16.0),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _active,
                          onChanged: (v) => setState(() => _active = v),
                          activeThumbColor: ThemeTokens.primary,
                          title: Text("Active", style: ThemeTokens.labelSmall),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
                SectionCard(
                  title: "Accessible Activities",
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
                      : Text(widget.isEditMode ? "Save Changes" : "Create Role", style: ThemeTokens.buttonText),
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
                    label: const Text("Delete Role"),
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
