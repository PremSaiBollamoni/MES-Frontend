import 'package:flutter/material.dart';
import '../components/app_button.dart';
import '../components/custom_toast.dart';
import '../components/employee_card.dart';
import '../models/employee_summary.dart';
import '../services/employee_api_service.dart';
import '../services/hrms_api_service.dart';
import '../utils/theme_tokens.dart';
import 'employee_detail_screen.dart';
import 'employee_form_screen.dart';
import 'hrms_import_screen.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final EmployeeApiService _apiService = EmployeeApiService();
  final HrmsApiService _hrmsApiService = HrmsApiService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;
  List<EmployeeSummary> _employees = [];
  String _query = "";
  int _unlinkedHrmsCount = 0;

  bool _selectionMode = false;
  bool _isDeleting = false;
  final Set<int> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _loadEmployees();
    _loadUnlinkedCount();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final employees = await _apiService.listEmployees();
      if (!mounted) return;
      setState(() {
        _employees = employees;
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

  /// Best-effort - HRMS may be disabled/unreachable, in which case this just stays 0
  /// and the import banner never shows, rather than surfacing an error on this screen.
  Future<void> _loadUnlinkedCount() async {
    try {
      final unlinked = await _hrmsApiService.getUnlinkedEmployees();
      if (!mounted) return;
      setState(() => _unlinkedHrmsCount = unlinked.length);
    } catch (_) {
      // HRMS not configured or unreachable - silently skip the banner.
    }
  }

  List<EmployeeSummary> get _filteredEmployees {
    if (_query.isEmpty) return _employees;
    return _employees.where((e) {
      return e.name.toLowerCase().contains(_query) ||
          (e.employeeCode?.toLowerCase().contains(_query) ?? false) ||
          e.username.toLowerCase().contains(_query) ||
          (e.department?.toLowerCase().contains(_query) ?? false);
    }).toList();
  }

  Future<void> _openCreateForm() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const EmployeeFormScreen()),
    );
    if (created == true) {
      if (!mounted) return;
      CustomToast.show(context, "Employee added successfully");
      _loadEmployees();
    }
  }

  Future<void> _openDetail(EmployeeSummary employee) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => EmployeeDetailScreen(employeeId: employee.id)),
    );
    if (changed == true) {
      _loadEmployees();
    }
  }

  void _enterSelectionMode(int id) {
    setState(() {
      _selectionMode = true;
      _selectedIds.add(id);
    });
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
      if (_selectedIds.isEmpty) _selectionMode = false;
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  void _selectAllFiltered() {
    setState(() => _selectedIds.addAll(_filteredEmployees.map((e) => e.id)));
  }

  Future<void> _confirmBulkDelete() async {
    final count = _selectedIds.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text("Delete $count employee(s)?", style: ThemeTokens.headingMedium.copyWith(fontSize: 18)),
        content: Text(
          "This permanently removes the selected employee(s). Anyone with associated records elsewhere will be skipped automatically.",
          style: ThemeTokens.bodyMedium,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text("Delete", style: TextStyle(color: ThemeTokens.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isDeleting = true);
    try {
      final result = await _apiService.bulkDeleteEmployees(_selectedIds.toList());
      if (!mounted) return;
      final message = result.failed.isEmpty
          ? "Deleted ${result.deletedCount} employee(s)"
          : "Deleted ${result.deletedCount}, ${result.failed.length} skipped (still referenced elsewhere)";
      CustomToast.show(context, message, isError: result.failed.isNotEmpty);
      _exitSelectionMode();
      _loadEmployees();
    } catch (e) {
      if (!mounted) return;
      CustomToast.show(context, e.toString().replaceAll("Exception: ", ""), isError: true);
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  Future<void> _openHrmsImport() async {
    final imported = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const HrmsImportScreen()),
    );
    if (imported == true) {
      _loadEmployees();
    }
    _loadUnlinkedCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      floatingActionButton: _selectionMode
          ? null
          : FloatingActionButton(
              heroTag: "employee_list_fab",
              onPressed: _openCreateForm,
              backgroundColor: ThemeTokens.primary,
              elevation: 2,
              shape: const CircleBorder(),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
            ),
      body: SafeArea(
        child: Column(
          children: [
            if (!_selectionMode) _buildStatsStrip(),
            if (_selectionMode)
              _buildSelectionBar()
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                child: TextField(
                  controller: _searchController,
                  style: ThemeTokens.inputText,
                  decoration: InputDecoration(
                    hintText: "Search employees",
                    hintStyle: ThemeTokens.hintText,
                    prefixIcon: const Icon(Icons.search_rounded, size: 20, color: ThemeTokens.textLight),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.sync_rounded, size: 20, color: _unlinkedHrmsCount > 0 ? ThemeTokens.warning : ThemeTokens.textLight),
                      onPressed: _openHrmsImport,
                      tooltip: "Sync with HRMS",
                    ),
                    filled: true,
                    fillColor: ThemeTokens.surfaceSunken,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
                      borderSide: const BorderSide(color: ThemeTokens.primary, width: 1.5),
                    ),
                  ),
                ),
              ),
            if (!_selectionMode && _unlinkedHrmsCount > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: InkWell(
                  onTap: _openHrmsImport,
                  borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: ThemeTokens.warning.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
                      border: Border.all(color: ThemeTokens.warning.withOpacity(0.25)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.sync_alt_rounded, color: ThemeTokens.warning, size: 18),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: Text(
                            "$_unlinkedHrmsCount employee(s) in HRMS aren't linked here yet",
                            style: ThemeTokens.bodyMedium.copyWith(color: ThemeTokens.textPrimary, fontWeight: FontWeight.w700),
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: ThemeTokens.textLight, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: ThemeTokens.hairline))),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: ThemeTokens.textSecondary),
            onPressed: _isDeleting ? null : _exitSelectionMode,
          ),
          Expanded(
            child: Text(
              "${_selectedIds.length} selected",
              style: ThemeTokens.bodyMedium.copyWith(color: ThemeTokens.textPrimary, fontWeight: FontWeight.w700),
            ),
          ),
          TextButton(
            onPressed: _isDeleting ? null : _selectAllFiltered,
            child: Text("Select all", style: ThemeTokens.bodyMedium.copyWith(color: ThemeTokens.primary, fontWeight: FontWeight.w700)),
          ),
          IconButton(
            icon: _isDeleting
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: ThemeTokens.error))
                : const Icon(Icons.delete_outline_rounded, color: ThemeTokens.error),
            onPressed: (_isDeleting || _selectedIds.isEmpty) ? null : _confirmBulkDelete,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsStrip() {
    final total = _employees.length;
    final active = _employees.where((e) => e.active).length;
    final inactive = total - active;

    Widget stat(String label, String value) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: ThemeTokens.headingLarge.copyWith(fontSize: 22)),
            const SizedBox(height: 2.0),
            Text(label, style: ThemeTokens.caption),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: ThemeTokens.hairline))),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            children: [
              stat("Total", "$total"),
              stat("Active", "$active"),
              stat("Inactive", "$inactive"),
            ],
          ),
        ),
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
              const Icon(Icons.wifi_off_rounded, color: ThemeTokens.error, size: 40),
              const SizedBox(height: 12.0),
              Text("Couldn't load employees", style: ThemeTokens.headingMedium.copyWith(fontSize: 16)),
              const SizedBox(height: 6.0),
              Text(_errorMessage!, style: ThemeTokens.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 16.0),
              AppPrimaryButton(label: "Retry", onPressed: _loadEmployees),
            ],
          ),
        ),
      );
    }

    final filtered = _filteredEmployees;

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.groups_outlined, color: ThemeTokens.textLight, size: 40),
              const SizedBox(height: 12.0),
              Text(
                _employees.isEmpty ? "No employees yet" : "No employees match your search",
                style: ThemeTokens.headingMedium.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 6.0),
              Text(
                _employees.isEmpty ? "Tap \"Add Employee\" to create the first record." : "Try a different search term.",
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
      onRefresh: _loadEmployees,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final employee = filtered[index];
          return EmployeeCard(
            employee: employee,
            selectionMode: _selectionMode,
            selected: _selectedIds.contains(employee.id),
            onTap: _selectionMode ? () => _toggleSelection(employee.id) : () => _openDetail(employee),
            onLongPress: _selectionMode ? null : () => _enterSelectionMode(employee.id),
          );
        },
      ),
    );
  }
}
