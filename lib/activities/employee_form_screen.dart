import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../components/app_date_field.dart';
import '../components/app_dropdown_field.dart';
import '../components/app_text_field.dart';
import '../components/custom_toast.dart';
import '../components/section_card.dart';
import '../models/employee_detail.dart';
import '../models/employee_request.dart';
import '../models/role_model.dart';
import '../services/employee_api_service.dart';
import '../utils/theme_tokens.dart';

/// Single screen for both creating and editing an employee.
/// Pass [existing] to edit; omit it to create a new employee.
class EmployeeFormScreen extends StatefulWidget {
  final EmployeeDetail? existing;

  const EmployeeFormScreen({super.key, this.existing});

  bool get isEditMode => existing != null;

  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  // Mirrors EmployeeService.DEFAULT_PASSWORD on the backend - the account every employee
  // gets unless HR sets a custom password, and what the reset shortcut fills in.
  static const _defaultPassword = "MES2K26";

  final _formKey = GlobalKey<FormState>();
  final EmployeeApiService _apiService = EmployeeApiService();

  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _employeeCodeController = TextEditingController();
  final _departmentController = TextEditingController();
  final _designationController = TextEditingController();
  final _shiftController = TextEditingController(text: "GENERAL");
  final _bloodGroupController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyNumberController = TextEditingController();
  final _emergencyRelationshipController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _bankAccountNumberController = TextEditingController();
  final _ifscCodeController = TextEditingController();

  String? _selectedRole;
  String? _selectedGender;
  DateTime? _dateOfJoining;
  DateTime? _dateOfBirth;
  bool _active = true;

  bool _isLoadingRoles = true;
  bool _isSaving = false;
  String? _loadError;
  List<RoleModel> _roles = [];

  @override
  void initState() {
    super.initState();
    _prefillFromExisting();
    _loadRoles();
  }

  void _prefillFromExisting() {
    final existing = widget.existing;
    if (existing == null) return;
    _nameController.text = existing.name;
    _employeeCodeController.text = existing.employeeCode;
    _departmentController.text = existing.department ?? "";
    _designationController.text = existing.designation ?? "";
    _shiftController.text = existing.shift ?? "GENERAL";
    _bloodGroupController.text = existing.bloodGroup ?? "";
    _addressController.text = existing.address ?? "";
    _emergencyNameController.text = existing.emergencyContactName ?? "";
    _emergencyNumberController.text = existing.emergencyContactNumber ?? "";
    _emergencyRelationshipController.text = existing.emergencyContactRelationship ?? "";
    _bankNameController.text = existing.bankName ?? "";
    _bankAccountNumberController.text = existing.bankAccountNumber ?? "";
    _ifscCodeController.text = existing.ifscCode ?? "";
    _selectedRole = existing.roleCode;
    _selectedGender = existing.gender;
    _dateOfJoining = existing.dateOfJoining;
    _dateOfBirth = existing.dateOfBirth;
    _active = existing.active;
  }

  Future<void> _loadRoles() async {
    setState(() {
      _isLoadingRoles = true;
      _loadError = null;
    });
    try {
      final roles = await _apiService.getRoles();
      if (!mounted) return;
      setState(() {
        _roles = roles;
        _isLoadingRoles = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString().replaceAll("Exception: ", "");
        _isLoadingRoles = false;
      });
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _nameController.dispose();
    _employeeCodeController.dispose();
    _departmentController.dispose();
    _designationController.dispose();
    _shiftController.dispose();
    _bloodGroupController.dispose();
    _addressController.dispose();
    _emergencyNameController.dispose();
    _emergencyNumberController.dispose();
    _emergencyRelationshipController.dispose();
    _bankNameController.dispose();
    _bankAccountNumberController.dispose();
    _ifscCodeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      if (widget.isEditMode) {
        await _apiService.updateEmployee(
          widget.existing!.id,
          EmployeeUpdateRequest(
            password: _passwordController.text.isEmpty ? null : _passwordController.text,
            name: _nameController.text.trim(),
            roleCode: _selectedRole,
            active: _active,
            employeeCode: _employeeCodeController.text.trim(),
            department: _departmentController.text.trim(),
            designation: _designationController.text.trim(),
            dateOfJoining: _dateOfJoining,
            shift: _shiftController.text.trim(),
            dateOfBirth: _dateOfBirth,
            gender: _selectedGender,
            bloodGroup: _bloodGroupController.text.trim(),
            address: _addressController.text.trim(),
            emergencyContactName: _emergencyNameController.text.trim(),
            emergencyContactNumber: _emergencyNumberController.text.trim(),
            emergencyContactRelationship: _emergencyRelationshipController.text.trim(),
            bankName: _bankNameController.text.trim(),
            bankAccountNumber: _bankAccountNumberController.text.trim(),
            ifscCode: _ifscCodeController.text.trim(),
          ),
        );
      } else {
        await _apiService.createEmployee(
          EmployeeCreateRequest(
            password: _passwordController.text.isEmpty ? null : _passwordController.text,
            name: _nameController.text.trim(),
            roleCode: _selectedRole!,
            employeeCode: _employeeCodeController.text.trim(),
            department: _departmentController.text.trim(),
            designation: _designationController.text.trim(),
            dateOfJoining: _dateOfJoining,
            shift: _shiftController.text.trim(),
            dateOfBirth: _dateOfBirth,
            gender: _selectedGender,
            bloodGroup: _bloodGroupController.text.trim(),
            address: _addressController.text.trim(),
            emergencyContactName: _emergencyNameController.text.trim(),
            emergencyContactNumber: _emergencyNumberController.text.trim(),
            emergencyContactRelationship: _emergencyRelationshipController.text.trim(),
            bankName: _bankNameController.text.trim(),
            bankAccountNumber: _bankAccountNumberController.text.trim(),
            ifscCode: _ifscCodeController.text.trim(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      appBar: AppBar(
        backgroundColor: ThemeTokens.surfaceSolid,
        elevation: 0,
        title: Text(
          widget.isEditMode ? L10n.of(context).editEmployee : L10n.of(context).addEmployee,
          style: ThemeTokens.headingMedium.copyWith(color: ThemeTokens.textPrimary),
        ),
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoadingRoles) {
      return const Center(child: CircularProgressIndicator(color: ThemeTokens.primary));
    }
    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_loadError!, style: ThemeTokens.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _loadRoles,
                style: ElevatedButton.styleFrom(backgroundColor: ThemeTokens.primary, foregroundColor: Colors.white),
                child: Text(L10n.of(context).retry),
              ),
            ],
          ),
        ),
      );
    }

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionCard(
              title: L10n.of(context).accountRole,
              icon: Icons.verified_user_outlined,
              child: Column(
                children: [
                  if (widget.isEditMode) ...[
                    Text(L10n.of(context).username, style: ThemeTokens.labelSmall),
                    const SizedBox(height: 8.0),
                    Text(widget.existing!.username, style: ThemeTokens.inputText),
                    const SizedBox(height: 16.0),
                  ] else ...[
                    Text(
                      L10n.of(context).aUsernameMesWillBe,
                      style: ThemeTokens.hintText,
                    ),
                    const SizedBox(height: 16.0),
                  ],
                  AppTextField(
                    label: widget.isEditMode
                        ? L10n.of(context).newPasswordLeaveBlankTo
                        : L10n.of(context).passwordLeaveBlankToUse,
                    controller: _passwordController,
                    obscureText: true,
                    suffixIcon: widget.isEditMode
                        ? IconButton(
                            tooltip: L10n.of(context).resetToDefaultPassword,
                            icon: const Icon(Icons.restart_alt_rounded, color: ThemeTokens.primary),
                            onPressed: () => setState(() => _passwordController.text = _defaultPassword),
                          )
                        : null,
                  ),
                  if (widget.isEditMode) ...[
                    const SizedBox(height: 6.0),
                    Text(
                      "${L10n.of(context).resettingPasswordAlsoClearsAnyAccountLockout} $_defaultPassword",
                      style: ThemeTokens.hintText,
                    ),
                  ],
                  const SizedBox(height: 16.0),
                  AppTextField(
                    label: L10n.of(context).fullName,
                    controller: _nameController,
                    validator: (v) => (v == null || v.trim().isEmpty) ? L10n.of(context).nameIsRequired : null,
                  ),
                  const SizedBox(height: 16.0),
                  if (widget.isEditMode)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        L10n.of(context).rolesAreManagedFromAssignRoles,
                        style: ThemeTokens.hintText,
                      ),
                    )
                  else
                    AppDropdownField<String>(
                      label: L10n.of(context).role,
                      value: _selectedRole,
                      hint: L10n.of(context).selectARole,
                      items: _roles
                          .map((r) => DropdownMenuItem(value: r.roleCode, child: Text(r.displayName)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedRole = v),
                      validator: (v) => v == null ? L10n.of(context).roleIsRequired : null,
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
              title: L10n.of(context).workDetails,
              icon: Icons.badge_outlined,
              child: Column(
                children: [
                  AppTextField(
                    label: L10n.of(context).employeeCode,
                    controller: _employeeCodeController,
                    validator: (v) => (v == null || v.trim().isEmpty) ? L10n.of(context).employeeCodeIsRequired : null,
                  ),
                  const SizedBox(height: 16.0),
                  AppTextField(label: L10n.of(context).department, controller: _departmentController),
                  const SizedBox(height: 16.0),
                  AppTextField(label: L10n.of(context).designation, controller: _designationController),
                  const SizedBox(height: 16.0),
                  AppDateField(
                    label: L10n.of(context).dateOfJoining,
                    value: _dateOfJoining,
                    lastDate: DateTime.now(),
                    onChanged: (v) => setState(() => _dateOfJoining = v),
                  ),
                  const SizedBox(height: 16.0),
                  AppTextField(label: L10n.of(context).shift, controller: _shiftController, hint: "e.g. GENERAL, MORNING, NIGHT"),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            SectionCard(
              title: L10n.of(context).personalDetails,
              icon: Icons.person_outline_rounded,
              child: Column(
                children: [
                  AppDateField(
                    label: L10n.of(context).dateOfBirth,
                    value: _dateOfBirth,
                    lastDate: DateTime.now(),
                    onChanged: (v) => setState(() => _dateOfBirth = v),
                  ),
                  const SizedBox(height: 16.0),
                  AppDropdownField<String>(
                    label: L10n.of(context).gender,
                    value: _selectedGender,
                    hint: L10n.of(context).selectGender,
                    items: [
                      DropdownMenuItem(value: "MALE", child: Text(L10n.of(context).male)),
                      DropdownMenuItem(value: "FEMALE", child: Text(L10n.of(context).female)),
                      DropdownMenuItem(value: "OTHER", child: Text(L10n.of(context).other)),
                    ],
                    onChanged: (v) => setState(() => _selectedGender = v),
                  ),
                  const SizedBox(height: 16.0),
                  AppTextField(label: L10n.of(context).bloodGroup, controller: _bloodGroupController, hint: "e.g. O+"),
                  const SizedBox(height: 16.0),
                  AppTextField(label: L10n.of(context).address, controller: _addressController, maxLines: 3),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            SectionCard(
              title: L10n.of(context).emergencyContact,
              icon: Icons.emergency_outlined,
              child: Column(
                children: [
                  AppTextField(label: L10n.of(context).contactName, controller: _emergencyNameController),
                  const SizedBox(height: 16.0),
                  AppTextField(
                    label: L10n.of(context).contactNumber,
                    controller: _emergencyNumberController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16.0),
                  AppTextField(label: L10n.of(context).relationship, controller: _emergencyRelationshipController, hint: "e.g. Father, Spouse"),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            SectionCard(
              title: "Bank Details",
              icon: Icons.account_balance_outlined,
              child: Column(
                children: [
                  AppTextField(label: "Bank Name", controller: _bankNameController),
                  const SizedBox(height: 16.0),
                  AppTextField(
                    label: "Bank Account Number",
                    controller: _bankAccountNumberController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16.0),
                  AppTextField(label: "IFSC Code", controller: _ifscCodeController, hint: "e.g. SBIN0001234"),
                ],
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
                  : Text(widget.isEditMode ? L10n.of(context).saveChanges : L10n.of(context).createEmployee, style: ThemeTokens.buttonText),
            ),
          ],
        ),
      ),
    );
  }
}
