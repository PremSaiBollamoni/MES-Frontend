import 'package:flutter/material.dart';
import '../components/app_button.dart';
import '../components/custom_toast.dart';
import '../models/employee_detail.dart';
import '../models/role_model.dart';
import '../services/employee_api_service.dart';
import '../utils/role_icon.dart';
import '../utils/theme_tokens.dart';

/// Multi-select role assignment for one employee - the "Assign Roles" action
/// from the employee detail screen. Replaces the employee's full role set.
class AssignRolesScreen extends StatefulWidget {
  final EmployeeDetail employee;

  const AssignRolesScreen({super.key, required this.employee});

  @override
  State<AssignRolesScreen> createState() => _AssignRolesScreenState();
}

class _AssignRolesScreenState extends State<AssignRolesScreen> {
  final EmployeeApiService _apiService = EmployeeApiService();

  bool _isLoadingRoles = true;
  String? _loadError;
  bool _isSaving = false;
  List<RoleModel> _roles = [];
  late final Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.employee.roleCodes.toSet();
    _loadRoles();
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

  String _formatRole(String role) {
    return role.split('_').map((word) {
      if (word.isEmpty) return '';
      return word[0] + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Future<void> _save() async {
    if (_selected.isEmpty) {
      CustomToast.show(context, "Select at least one role", isError: true);
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _apiService.assignRoles(widget.employee.id, _selected.toList());
      if (!mounted) return;
      CustomToast.show(context, "Roles updated");
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
      appBar: AppBar(title: Text("Assign Roles", style: ThemeTokens.headingMedium.copyWith(fontSize: 17))),
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
              SizedBox(width: 180, child: AppPrimaryButton(label: "Retry", onPressed: _loadRoles)),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.employee.name, style: ThemeTokens.headingMedium.copyWith(fontSize: 17)),
              const SizedBox(height: 4.0),
              Text(
                "An employee can hold more than one role. Select every role this person should be able to sign in as.",
                style: ThemeTokens.bodyMedium,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            itemCount: _roles.length,
            itemBuilder: (context, index) {
              final role = _roles[index];
              final checked = _selected.contains(role.roleCode);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
                    onTap: () => setState(() {
                      if (checked) {
                        _selected.remove(role.roleCode);
                      } else {
                        _selected.add(role.roleCode);
                      }
                    }),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: checked ? ThemeTokens.surfaceSunken : ThemeTokens.surfaceSolid,
                        borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
                        border: Border.all(color: checked ? ThemeTokens.primary : ThemeTokens.hairline),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            checked ? Icons.check_circle : Icons.circle_outlined,
                            color: checked ? ThemeTokens.primary : ThemeTokens.textMuted,
                            size: 22,
                          ),
                          const SizedBox(width: 14.0),
                          Icon(RoleIcon.forRole(role.roleCode), size: 18, color: ThemeTokens.textSecondary),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: Text(_formatRole(role.roleCode), style: ThemeTokens.headingMedium.copyWith(fontSize: 15)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: AppPrimaryButton(label: "Save Roles", onPressed: _save, isLoading: _isSaving),
        ),
      ],
    );
  }
}
