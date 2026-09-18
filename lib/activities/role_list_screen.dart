import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../components/app_button.dart';
import '../components/custom_toast.dart';
import '../components/role_card.dart';
import '../models/role_detail.dart';
import '../services/role_api_service.dart';
import '../utils/theme_tokens.dart';
import 'role_form_screen.dart';

class RoleListScreen extends StatefulWidget {
  const RoleListScreen({super.key});

  @override
  State<RoleListScreen> createState() => _RoleListScreenState();
}

class _RoleListScreenState extends State<RoleListScreen> {
  final RoleApiService _apiService = RoleApiService();

  bool _isLoading = true;
  String? _errorMessage;
  List<RoleDetail> _roles = [];

  bool _selectionMode = false;
  bool _isDeleting = false;
  final Set<int> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final roles = await _apiService.listRoles(forceRefresh: forceRefresh);
      if (!mounted) return;
      setState(() {
        _roles = roles;
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

  Future<void> _openCreateForm() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const RoleFormScreen()),
    );
    if (created == true) {
      if (!mounted) return;
      CustomToast.show(context, L10n.of(context).roleCreatedSuccessfully);
      _load();
    }
  }

  Future<void> _openEditForm(RoleDetail role) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => RoleFormScreen(existing: role)),
    );
    if (updated == true) _load();
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

  void _selectAll() {
    setState(() => _selectedIds.addAll(_roles.map((r) => r.roleId)));
  }

  Future<void> _confirmBulkDelete() async {
    final count = _selectedIds.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text("Delete $count role(s)?", style: ThemeTokens.headingMedium.copyWith(fontSize: 18)),
        content: Text(
          L10n.of(context).thisPermanentlyRemovesTheSelected2,
          style: ThemeTokens.bodyMedium,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(L10n.of(context).cancel)),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(L10n.of(context).delete, style: TextStyle(color: ThemeTokens.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isDeleting = true);
    try {
      final result = await _apiService.bulkDeleteRoles(_selectedIds.toList());
      if (!mounted) return;
      final message = result.failed.isEmpty
          ? "Deleted ${result.deletedCount} role(s)"
          : "Deleted ${result.deletedCount}, ${result.failed.length} skipped (still assigned to employees)";
      CustomToast.show(context, message, isError: result.failed.isNotEmpty);
      _exitSelectionMode();
      _load();
    } catch (e) {
      if (!mounted) return;
      CustomToast.show(context, e.toString().replaceAll("Exception: ", ""), isError: true);
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      floatingActionButton: _selectionMode
          ? null
          : FloatingActionButton(
              heroTag: "role_list_fab",
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
            if (_selectionMode) _buildSelectionBar(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsStrip() {
    final total = _roles.length;
    final active = _roles.where((r) => r.isActive).length;
    final totalActivities = _roles.fold<int>(0, (sum, r) => sum + r.activities.length);

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
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: ThemeTokens.hairline))),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            children: [
              stat(L10n.of(context).totalRoles, "$total"),
              stat(L10n.of(context).active, "$active"),
              stat(L10n.of(context).activities, "$totalActivities"),
            ],
          ),
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
            onPressed: _isDeleting ? null : _selectAll,
            child: Text(L10n.of(context).selectAll, style: ThemeTokens.bodyMedium.copyWith(color: ThemeTokens.primary, fontWeight: FontWeight.w700)),
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
              Text(_errorMessage!, style: ThemeTokens.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 16.0),
              AppPrimaryButton(label: L10n.of(context).retry, onPressed: _load),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: ThemeTokens.primary,
      onRefresh: () => _load(forceRefresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
        itemCount: _roles.length,
        itemBuilder: (context, index) {
          final role = _roles[index];
          return RoleCard(
            role: role,
            selectionMode: _selectionMode,
            selected: _selectedIds.contains(role.roleId),
            onTap: _selectionMode ? () => _toggleSelection(role.roleId) : () => _openEditForm(role),
            onLongPress: _selectionMode ? null : () => _enterSelectionMode(role.roleId),
          );
        },
      ),
    );
  }
}
