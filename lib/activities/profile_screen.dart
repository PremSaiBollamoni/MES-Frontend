import 'package:flutter/material.dart';
import '../components/app_date_field.dart';
import '../components/app_dropdown_field.dart';
import '../components/app_text_field.dart';
import '../components/custom_toast.dart';
import '../components/app_button.dart';
import '../components/info_row.dart';
import '../components/profile_hero_card.dart';
import '../components/section_card.dart';
import '../models/employee_detail.dart';
import '../utils/role_icon.dart';
import '../models/profile_request.dart';
import '../services/profile_api_service.dart';
import '../utils/theme_tokens.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileApiService _apiService = ProfileApiService();

  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  String? _errorMessage;
  EmployeeDetail? _profile;

  final _nameController = TextEditingController();
  final _bloodGroupController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyNumberController = TextEditingController();
  final _emergencyRelationshipController = TextEditingController();
  String? _selectedGender;
  DateTime? _dateOfBirth;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bloodGroupController.dispose();
    _addressController.dispose();
    _emergencyNameController.dispose();
    _emergencyNumberController.dispose();
    _emergencyRelationshipController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final profile = await _apiService.getProfile();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
      _resetFormFromProfile();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  void _resetFormFromProfile() {
    final profile = _profile;
    if (profile == null) return;
    _nameController.text = profile.name;
    _bloodGroupController.text = profile.bloodGroup ?? "";
    _addressController.text = profile.address ?? "";
    _emergencyNameController.text = profile.emergencyContactName ?? "";
    _emergencyNumberController.text = profile.emergencyContactNumber ?? "";
    _emergencyRelationshipController.text = profile.emergencyContactRelationship ?? "";
    _selectedGender = profile.gender;
    _dateOfBirth = profile.dateOfBirth;
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      final updated = await _apiService.updateProfile(
        ProfileUpdateRequest(
          name: _nameController.text.trim(),
          dateOfBirth: _dateOfBirth,
          gender: _selectedGender,
          bloodGroup: _bloodGroupController.text.trim(),
          address: _addressController.text.trim(),
          emergencyContactName: _emergencyNameController.text.trim(),
          emergencyContactNumber: _emergencyNumberController.text.trim(),
          emergencyContactRelationship: _emergencyRelationshipController.text.trim(),
        ),
      );
      if (!mounted) return;
      setState(() {
        _profile = updated;
        _isEditing = false;
      });
      CustomToast.show(context, "Profile updated");
    } catch (e) {
      if (!mounted) return;
      CustomToast.show(context, e.toString().replaceAll("Exception: ", ""), isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _openChangePasswordDialog() async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text("Change Password", style: ThemeTokens.headingMedium.copyWith(fontSize: 18)),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppTextField(
                      label: "Current Password",
                      controller: currentController,
                      obscureText: true,
                      validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
                    ),
                    const SizedBox(height: 16.0),
                    AppTextField(
                      label: "New Password",
                      controller: newController,
                      obscureText: true,
                      validator: (v) => (v == null || v.length < 6) ? "At least 6 characters" : null,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text("Cancel")),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setDialogState(() => isSubmitting = true);
                          try {
                            await _apiService.changePassword(
                              ChangePasswordRequest(
                                currentPassword: currentController.text,
                                newPassword: newController.text,
                              ),
                            );
                            if (!dialogContext.mounted) return;
                            Navigator.of(dialogContext).pop();
                            if (!mounted) return;
                            CustomToast.show(context, "Password changed successfully");
                          } catch (e) {
                            setDialogState(() => isSubmitting = false);
                            if (!dialogContext.mounted) return;
                            CustomToast.show(dialogContext, e.toString().replaceAll("Exception: ", ""), isError: true);
                          }
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: ThemeTokens.primary, foregroundColor: Colors.white),
                  child: isSubmitting
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text("Change Password"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatRole(String role) {
    return role.split('_').map((word) {
      if (word.isEmpty) return '';
      return word[0] + word.substring(1).toLowerCase();
    }).join(' ');
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "—";
    return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: ThemeTokens.primary));
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_errorMessage!, style: ThemeTokens.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 16.0),
              AppPrimaryButton(label: "Retry", onPressed: _load),
            ],
          ),
        ),
      );
    }

    final profile = _profile!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileHeroCard(
            name: profile.name,
            subtitle: "${profile.username} · ${_formatRole(profile.roleCode)}",
            badgeIcon: RoleIcon.forRole(profile.roleCode),
          ),
          const SizedBox(height: 16.0),
          SectionCard(
            title: "Work Details",
            icon: Icons.badge_outlined,
            child: Column(
              children: [
                InfoRow(label: "Employee Code", value: profile.employeeCode),
                InfoRow(label: "Department", value: profile.department ?? "—"),
                InfoRow(label: "Designation", value: profile.designation ?? "—"),
                InfoRow(label: "Shift", value: profile.shift ?? "—"),
                InfoRow(label: "Date of Joining", value: _formatDate(profile.dateOfJoining)),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          SectionCard(
            title: "Personal & Emergency Contact",
            icon: Icons.person_outline_rounded,
            child: _isEditing ? _buildEditForm() : _buildReadOnlyPersonal(profile),
          ),
          const SizedBox(height: 16.0),
          if (_isEditing)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving
                        ? null
                        : () {
                            _resetFormFromProfile();
                            setState(() => _isEditing = false);
                          },
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: AppPrimaryButton(label: "Save", onPressed: _saveProfile, isLoading: _isSaving),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _isEditing = true),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text("Edit Profile"),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openChangePasswordDialog,
                    icon: const Icon(Icons.lock_outline_rounded),
                    label: const Text("Change Password"),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyPersonal(EmployeeDetail profile) {
    return Column(
      children: [
        InfoRow(label: "Date of Birth", value: _formatDate(profile.dateOfBirth)),
        InfoRow(label: "Gender", value: profile.gender ?? "—"),
        InfoRow(label: "Blood Group", value: profile.bloodGroup ?? "—"),
        InfoRow(label: "Address", value: profile.address ?? "—"),
        InfoRow(label: "Emergency Contact", value: profile.emergencyContactName ?? "—"),
        InfoRow(label: "Emergency Number", value: profile.emergencyContactNumber ?? "—"),
        InfoRow(label: "Relationship", value: profile.emergencyContactRelationship ?? "—"),
      ],
    );
  }

  Widget _buildEditForm() {
    return Column(
      children: [
        AppTextField(label: "Full Name", controller: _nameController),
        const SizedBox(height: 16.0),
        AppDateField(
          label: "Date of Birth",
          value: _dateOfBirth,
          lastDate: DateTime.now(),
          onChanged: (v) => setState(() => _dateOfBirth = v),
        ),
        const SizedBox(height: 16.0),
        AppDropdownField<String>(
          label: "Gender",
          value: _selectedGender,
          hint: "Select gender",
          items: const [
            DropdownMenuItem(value: "MALE", child: Text("Male")),
            DropdownMenuItem(value: "FEMALE", child: Text("Female")),
            DropdownMenuItem(value: "OTHER", child: Text("Other")),
          ],
          onChanged: (v) => setState(() => _selectedGender = v),
        ),
        const SizedBox(height: 16.0),
        AppTextField(label: "Blood Group", controller: _bloodGroupController, hint: "e.g. O+"),
        const SizedBox(height: 16.0),
        AppTextField(label: "Address", controller: _addressController, maxLines: 3),
        const SizedBox(height: 16.0),
        AppTextField(label: "Emergency Contact Name", controller: _emergencyNameController),
        const SizedBox(height: 16.0),
        AppTextField(label: "Emergency Contact Number", controller: _emergencyNumberController, keyboardType: TextInputType.phone),
        const SizedBox(height: 16.0),
        AppTextField(label: "Relationship", controller: _emergencyRelationshipController, hint: "e.g. Father, Spouse"),
      ],
    );
  }
}
