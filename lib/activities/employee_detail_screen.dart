import 'package:flutter/material.dart';
import '../utils/employee_names.dart';
import '../l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import '../components/confirm_dialog.dart';
import '../components/custom_toast.dart';
import '../components/app_button.dart';
import '../components/info_row.dart';
import '../components/profile_hero_card.dart';
import '../components/section_card.dart';
import '../components/status_badge.dart';
import '../components/tag_chip.dart';
import '../models/employee_detail.dart';
import '../services/employee_api_service.dart';
import '../utils/role_display.dart';
import '../utils/role_icon.dart';
import '../utils/theme_tokens.dart';
import 'assign_roles_screen.dart';
import 'employee_form_screen.dart';

class EmployeeDetailScreen extends StatefulWidget {
  final int employeeId;

  const EmployeeDetailScreen({super.key, required this.employeeId});

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  final EmployeeApiService _apiService = EmployeeApiService();

  bool _isLoading = true;
  bool _isUpdatingStatus = false;
  bool _isDeleting = false;
  bool _isUploadingFace = false;
  String? _errorMessage;
  EmployeeDetail? _employee;
  bool _dataChanged = false;

  @override
  void initState() {
    super.initState();
    _loadEmployee();
  }

  Future<void> _loadEmployee() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // Always bypass the cache here: this is the one screen someone opens
      // specifically to check current truth (username, active status, HRMS sync) -
      // a stale cached response (from before an admin action like Fix Usernames)
      // showing the wrong username is worse than the extra network round trip.
      final employee = await _apiService.getEmployee(widget.employeeId, forceRefresh: true);
      if (!mounted) return;
      setState(() {
        _employee = employee;
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

  Future<void> _toggleActive() async {
    final employee = _employee;
    if (employee == null) return;

    setState(() => _isUpdatingStatus = true);
    try {
      if (employee.active) {
        await _apiService.deactivateEmployee(employee.id);
      } else {
        await _apiService.reactivateEmployee(employee.id);
      }
      _dataChanged = true;
      if (!mounted) return;
      CustomToast.show(context, employee.active ? L10n.of(context).employeeDeactivated : L10n.of(context).employeeReactivated);
      await _loadEmployee();
    } catch (e) {
      if (!mounted) return;
      CustomToast.show(context, e.toString().replaceAll("Exception: ", ""), isError: true);
    } finally {
      if (mounted) setState(() => _isUpdatingStatus = false);
    }
  }

  Future<void> _deleteEmployee() async {
    final employee = _employee;
    if (employee == null) return;

    final confirmed = await showConfirmDialog(
      context,
      title: L10n.of(context).deleteEmployee,
      message: "This will permanently delete ${employee.name} (${employee.username}). This cannot be undone.",
    );
    if (!confirmed) return;

    setState(() => _isDeleting = true);
    try {
      await _apiService.deleteEmployee(employee.id);
      if (!mounted) return;
      CustomToast.show(context, L10n.of(context).employeeDeleted);
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      CustomToast.show(context, e.toString().replaceAll("Exception: ", ""), isError: true);
      setState(() => _isDeleting = false);
    }
  }

  Future<void> _uploadFacePhoto() async {
    final employee = _employee;
    if (employee == null) return;

    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;

    setState(() => _isUploadingFace = true);
    try {
      final bytes = await picked.readAsBytes();
      await _apiService.enrollFace(employee.id, bytes, picked.name);
      if (!mounted) return;
      CustomToast.show(context, L10n.of(context).facePhotoEnrolledInHrms);
    } catch (e) {
      if (!mounted) return;
      CustomToast.show(context, e.toString().replaceAll("Exception: ", ""), isError: true);
    } finally {
      if (mounted) setState(() => _isUploadingFace = false);
    }
  }

  Future<void> _openEditForm() async {
    final employee = _employee;
    if (employee == null) return;
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => EmployeeFormScreen(existing: employee)),
    );
    if (updated == true) {
      _dataChanged = true;
      _loadEmployee();
    }
  }

  Future<void> _openAssignRoles() async {
    final employee = _employee;
    if (employee == null) return;
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => AssignRolesScreen(employee: employee)),
    );
    if (updated == true) {
      _dataChanged = true;
      _loadEmployee();
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "—";
    return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(_dataChanged);
      },
      child: Scaffold(
        backgroundColor: ThemeTokens.background,
        appBar: AppBar(
          backgroundColor: ThemeTokens.surfaceSolid,
          elevation: 0,
          title: Text(L10n.of(context).employeeDetails, style: ThemeTokens.headingMedium.copyWith(color: ThemeTokens.textPrimary)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: ThemeTokens.textSecondary),
            onPressed: () => Navigator.of(context).pop(_dataChanged),
          ),
          actions: [
            if (_employee != null)
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: ThemeTokens.textSecondary),
                onPressed: _openEditForm,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: ThemeTokens.error, size: 40),
              const SizedBox(height: 12.0),
              Text(_errorMessage!, style: ThemeTokens.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 16.0),
              AppPrimaryButton(label: L10n.of(context).retry, onPressed: _loadEmployee),
            ],
          ),
        ),
      );
    }

    final employee = _employee!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileHeroCard(
            name: EmployeeNames.display(context, employee.name),
            subtitle: employee.employeeCode,
            badgeIcon: RoleIcon.forRole(employee.roleCode),
            trailing: StatusBadge(active: employee.active),
          ),
          const SizedBox(height: 16.0),
          SectionCard(
            title: L10n.of(context).workDetails,
            icon: Icons.badge_outlined,
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(L10n.of(context).roles, style: ThemeTokens.caption.copyWith(fontSize: 12)),
                    const SizedBox(height: 8.0),
                    Wrap(
                      spacing: 6.0,
                      runSpacing: 6.0,
                      children: employee.roleCodes.isEmpty
                          ? [Text(RoleDisplay.name(employee.roleCode), style: ThemeTokens.bodyMedium.copyWith(color: ThemeTokens.textPrimary, fontWeight: FontWeight.w600))]
                          : employee.roleCodes
                              .map((r) => TagChip(icon: RoleIcon.forRole(r), label: RoleDisplay.name(r), color: ThemeTokens.primary))
                              .toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _openAssignRoles,
                    icon: const Icon(Icons.manage_accounts_outlined, size: 18, color: ThemeTokens.primary),
                    label: Text(L10n.of(context).assignRoles, style: ThemeTokens.labelSmall.copyWith(color: ThemeTokens.primary)),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  ),
                ),
                const Divider(color: ThemeTokens.hairline, height: 24),
                InfoRow(label: L10n.of(context).username, value: employee.username),
                InfoRow(label: L10n.of(context).department, value: employee.department ?? "—"),
                InfoRow(label: L10n.of(context).designation, value: employee.designation ?? "—"),
                InfoRow(label: L10n.of(context).shift, value: employee.shift ?? "—"),
                InfoRow(label: L10n.of(context).dateOfJoining, value: _formatDate(employee.dateOfJoining)),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          SectionCard(
            title: L10n.of(context).biometricHrms,
            icon: Icons.fingerprint_rounded,
            child: Column(
              children: [
                InfoRow(label: L10n.of(context).syncStatus, value: employee.hrmsSyncStatus),
                if (employee.hrmsEmployeeCode != null) InfoRow(label: L10n.of(context).hrmsCode, value: employee.hrmsEmployeeCode!),
                if (employee.hrmsDeviceUserId != null)
                  InfoRow(label: L10n.of(context).deviceUserId, value: employee.hrmsDeviceUserId!),
                if (!employee.isSyncedToHrms)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      L10n.of(context).notYetSyncedToHrmsFull,
                      style: ThemeTokens.hintText,
                    ),
                  ),
                if (employee.isSyncedToHrms) ...[
                  const SizedBox(height: 12.0),
                  OutlinedButton.icon(
                    onPressed: _isUploadingFace ? null : _uploadFacePhoto,
                    icon: _isUploadingFace
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.face_retouching_natural_rounded),
                    label: Text(L10n.of(context).uploadFacePhoto),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ThemeTokens.primary,
                      side: const BorderSide(color: ThemeTokens.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  Text(
                    L10n.of(context).fingerprintAndRfidStillRequire,
                    style: ThemeTokens.hintText,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          SectionCard(
            title: L10n.of(context).personalDetails,
            icon: Icons.person_outline_rounded,
            child: Column(
              children: [
                InfoRow(label: L10n.of(context).dateOfBirth, value: _formatDate(employee.dateOfBirth)),
                InfoRow(label: L10n.of(context).gender, value: employee.gender ?? "—"),
                InfoRow(label: L10n.of(context).bloodGroup, value: employee.bloodGroup ?? "—"),
                InfoRow(label: L10n.of(context).address, value: employee.address ?? "—"),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          SectionCard(
            title: L10n.of(context).emergencyContact,
            icon: Icons.emergency_outlined,
            child: Column(
              children: [
                InfoRow(label: L10n.of(context).name, value: employee.emergencyContactName ?? "—"),
                InfoRow(label: L10n.of(context).number, value: employee.emergencyContactNumber ?? "—"),
                InfoRow(label: L10n.of(context).relationship, value: employee.emergencyContactRelationship ?? "—"),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          SectionCard(
            title: "Bank Details",
            icon: Icons.account_balance_outlined,
            child: Column(
              children: [
                InfoRow(label: "Bank Name", value: employee.bankName ?? "—"),
                InfoRow(label: "Account Number", value: employee.bankAccountNumber ?? "—"),
                InfoRow(label: "IFSC Code", value: employee.ifscCode ?? "—"),
              ],
            ),
          ),
          const SizedBox(height: 24.0),
          OutlinedButton.icon(
            onPressed: _isUpdatingStatus ? null : _toggleActive,
            icon: _isUpdatingStatus
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(employee.active ? Icons.block_rounded : Icons.check_circle_outline_rounded),
            label: Text(employee.active ? L10n.of(context).deactivateEmployee : L10n.of(context).reactivateEmployee),
            style: OutlinedButton.styleFrom(
              foregroundColor: employee.active ? ThemeTokens.error : ThemeTokens.success,
              side: BorderSide(color: employee.active ? ThemeTokens.error : ThemeTokens.success),
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
          ),
          const SizedBox(height: 12.0),
          ElevatedButton.icon(
            onPressed: _isDeleting ? null : _deleteEmployee,
            icon: _isDeleting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                  )
                : const Icon(Icons.delete_outline_rounded),
            label: Text(L10n.of(context).deleteEmployee),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeTokens.error,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
          ),
        ],
      ),
    );
  }
}
