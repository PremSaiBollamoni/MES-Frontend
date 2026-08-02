import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../components/app_dropdown_field.dart';
import '../components/app_text_field.dart';
import '../components/custom_toast.dart';
import '../models/hrms_employee.dart';
import '../models/import_from_hrms_request.dart';
import '../services/employee_api_service.dart';
import '../services/hrms_api_service.dart';
import '../utils/theme_tokens.dart';

/// Lists employees that exist in HRMS (created there directly, e.g. by whoever
/// administers the biometric device) but have no linked record in this app yet,
/// and lets HR pull one in - assigning it a role and a local employee code, both
/// concepts HRMS itself doesn't track.
class HrmsImportScreen extends StatefulWidget {
  const HrmsImportScreen({super.key});

  @override
  State<HrmsImportScreen> createState() => _HrmsImportScreenState();
}

class _HrmsImportScreenState extends State<HrmsImportScreen> {
  final HrmsApiService _hrmsApiService = HrmsApiService();
  final EmployeeApiService _employeeApiService = EmployeeApiService();

  bool _isLoading = true;
  String? _errorMessage;
  List<HrmsUnlinkedEmployee> _unlinked = [];
  bool _anyImported = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // Deliberately entering this screen is the one place a user actually wants a
      // fresh HRMS check, unlike the badge/banner on the Employees list.
      final unlinked = await _hrmsApiService.getUnlinkedEmployees(forceRefresh: true);
      if (!mounted) return;
      setState(() {
        _unlinked = unlinked;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  Future<void> _openImportDialog(HrmsUnlinkedEmployee hrmsEmployee) async {
    final roles = await _employeeApiService.getRoles();
    if (!mounted) return;

    final employeeCodeController = TextEditingController(text: hrmsEmployee.employeeCode);
    final departmentController = TextEditingController(text: hrmsEmployee.departmentName ?? "");
    String? selectedRole;
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text("Import ${hrmsEmployee.name}", style: ThemeTokens.headingMedium.copyWith(fontSize: 18)),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppTextField(
                      label: L10n.of(context).employeeCode,
                      controller: employeeCodeController,
                      validator: (v) => (v == null || v.trim().isEmpty) ? L10n.of(context).required : null,
                    ),
                    const SizedBox(height: 16.0),
                    AppDropdownField<String>(
                      label: L10n.of(context).role,
                      value: selectedRole,
                      hint: L10n.of(context).selectARole,
                      items: roles.map((r) => DropdownMenuItem(value: r.roleCode, child: Text(r.displayName))).toList(),
                      onChanged: (v) => setDialogState(() => selectedRole = v),
                      validator: (v) => v == null ? L10n.of(context).required : null,
                    ),
                    const SizedBox(height: 16.0),
                    AppTextField(
                      label: L10n.of(context).department,
                      controller: departmentController,
                      hint: "e.g. Stitching, Cutting, Quality",
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text(L10n.of(context).cancel)),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setDialogState(() => isSubmitting = true);
                          try {
                            await _employeeApiService.importFromHrms(
                              ImportFromHrmsRequest(
                                hrmsEmployeeId: hrmsEmployee.id,
                                hrmsEmployeeCode: hrmsEmployee.employeeCode,
                                hrmsDeviceUserId: hrmsEmployee.deviceUserId,
                                name: hrmsEmployee.name,
                                designation: hrmsEmployee.designation,
                                department: departmentController.text.trim().isEmpty ? null : departmentController.text.trim(),
                                roleCode: selectedRole!,
                                employeeCode: employeeCodeController.text.trim(),
                              ),
                            );
                            if (!dialogContext.mounted) return;
                            Navigator.of(dialogContext).pop();
                            _anyImported = true;
                            if (!mounted) return;
                            CustomToast.show(context, "${hrmsEmployee.name} imported successfully");
                            _load();
                          } catch (e) {
                            setDialogState(() => isSubmitting = false);
                            if (!dialogContext.mounted) return;
                            CustomToast.show(dialogContext, e.toString().replaceAll("Exception: ", ""), isError: true);
                          }
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: ThemeTokens.primary, foregroundColor: Colors.white),
                  child: isSubmitting
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(L10n.of(context).import),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _syncAll() async {
    final roles = await _employeeApiService.getRoles();
    if (!mounted) return;

    String? selectedRole;
    final departmentController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(L10n.of(context).syncAll, style: ThemeTokens.headingMedium.copyWith(fontSize: 18)),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      L10n.of(context).importsAllUnlinked(_unlinked.length),
                      style: ThemeTokens.bodyMedium,
                    ),
                    const SizedBox(height: 16.0),
                    AppDropdownField<String>(
                      label: L10n.of(context).defaultRole,
                      value: selectedRole,
                      hint: L10n.of(context).selectARole,
                      items: roles.map((r) => DropdownMenuItem(value: r.roleCode, child: Text(r.displayName))).toList(),
                      onChanged: (v) => setDialogState(() => selectedRole = v),
                      validator: (v) => v == null ? L10n.of(context).required : null,
                    ),
                    const SizedBox(height: 16.0),
                    AppTextField(
                      label: L10n.of(context).defaultDepartmentOptional,
                      controller: departmentController,
                      hint: L10n.of(context).leaveBlankToKeepEach,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text(L10n.of(context).cancel)),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setDialogState(() => isSubmitting = true);
                          try {
                            final department = departmentController.text.trim();
                            final result = await _employeeApiService.importAllFromHrms(
                              selectedRole!,
                              defaultDepartment: department.isEmpty ? null : department,
                            );
                            if (!dialogContext.mounted) return;
                            Navigator.of(dialogContext).pop();
                            _anyImported = result.importedCount > 0;
                            if (!mounted) return;
                            final message = result.failed.isEmpty
                                ? "Imported ${result.importedCount} employee(s)"
                                : "Imported ${result.importedCount}, ${result.failed.length} failed (duplicate codes?)";
                            CustomToast.show(context, message, isError: result.failed.isNotEmpty);
                            _load();
                          } catch (e) {
                            setDialogState(() => isSubmitting = false);
                            if (!dialogContext.mounted) return;
                            CustomToast.show(dialogContext, e.toString().replaceAll("Exception: ", ""), isError: true);
                          }
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: ThemeTokens.primary, foregroundColor: Colors.white),
                  child: isSubmitting
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(L10n.of(context).syncAll),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(_anyImported);
      },
      child: Scaffold(
        backgroundColor: ThemeTokens.background,
        appBar: AppBar(
          backgroundColor: ThemeTokens.surfaceSolid,
          elevation: 0,
          title: Text(L10n.of(context).importFromHrms, style: ThemeTokens.headingMedium.copyWith(color: ThemeTokens.textPrimary)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: ThemeTokens.textSecondary),
            onPressed: () => Navigator.of(context).pop(_anyImported),
          ),
          actions: [
            if (_unlinked.isNotEmpty)
              TextButton.icon(
                onPressed: _syncAll,
                icon: const Icon(Icons.sync_alt_rounded, color: ThemeTokens.primary, size: 20),
                label: Text(L10n.of(context).syncAll, style: ThemeTokens.bodyMedium.copyWith(color: ThemeTokens.primary, fontWeight: FontWeight.w700)),
              ),
          ],
        ),
        body: SafeArea(child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: ThemeTokens.primary));
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(_errorMessage!, style: ThemeTokens.bodyMedium, textAlign: TextAlign.center),
        ),
      );
    }
    if (_unlinked.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline_rounded, color: ThemeTokens.success, size: 40),
              const SizedBox(height: 12.0),
              Text(L10n.of(context).everythingSInSync, style: ThemeTokens.headingMedium.copyWith(fontSize: 16)),
              const SizedBox(height: 6.0),
              Text(
                L10n.of(context).everyHrmsEmployeeIsAlready,
                style: ThemeTokens.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: ThemeTokens.primary,
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        itemCount: _unlinked.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10.0),
        itemBuilder: (context, index) {
          final employee = _unlinked[index];
          return InkWell(
            borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
            onTap: () => _openImportDialog(employee),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: ThemeTokens.surfaceSolid,
                borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
                border: Border.all(color: ThemeTokens.glassBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(employee.name, style: ThemeTokens.bodyLarge.copyWith(color: ThemeTokens.textPrimary, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4.0),
                        Text("${employee.employeeCode} · device #${employee.deviceUserId}", style: ThemeTokens.caption),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: ThemeTokens.textLight),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
