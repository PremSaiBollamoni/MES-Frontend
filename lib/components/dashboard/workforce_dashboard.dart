import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../app_button.dart';
import '../../models/dashboard_summary.dart';
import '../../services/dashboard_api_service.dart';
import '../../utils/theme_tokens.dart';
import 'breakdown_block.dart';
import 'ledger_hero.dart';
import 'recent_joiners.dart';

/// Factory Manager / HR Manager dashboard - the full workforce composition
/// view (headcount, role/department split, recent joiners). These are the
/// only two roles whose PALMS responsibilities are genuinely "see everyone".
class WorkforceDashboard extends StatefulWidget {
  const WorkforceDashboard({super.key});

  @override
  State<WorkforceDashboard> createState() => _WorkforceDashboardState();
}

class _WorkforceDashboardState extends State<WorkforceDashboard> {
  final DashboardApiService _apiService = DashboardApiService();

  bool _isLoading = true;
  String? _errorMessage;
  DashboardSummary? _summary;

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
      final summary = await _apiService.getSummary(forceRefresh: forceRefresh);
      if (!mounted) return;
      setState(() {
        _summary = summary;
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

  String _formatRole(String role) {
    return role.split('_').map((word) {
      if (word.isEmpty) return '';
      return word[0] + word.substring(1).toLowerCase();
    }).join(' ');
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
              SizedBox(width: 180, child: AppPrimaryButton(label: L10n.of(context).retry, onPressed: _load)),
            ],
          ),
        ),
      );
    }

    final summary = _summary!;
    final maxRole = summary.employeesByRole.values.fold(1, (a, b) => a > b ? a : b);
    final maxDept = summary.employeesByDepartment.values.fold(1, (a, b) => a > b ? a : b);

    return RefreshIndicator(
      color: ThemeTokens.primary,
      onRefresh: () => _load(forceRefresh: true),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        children: [
          LedgerHero(
            eyebrow: L10n.of(context).totalWorkforce,
            value: "${summary.totalEmployees}",
            stats: [
              (value: "${summary.activeEmployees}", label: L10n.of(context).active),
              (value: "${summary.inactiveEmployees}", label: L10n.of(context).inactive),
            ],
          ),
          const SizedBox(height: 28.0),
          if (summary.employeesByRole.isNotEmpty) ...[
            BreakdownBlock(title: L10n.of(context).compositionByRole, entries: summary.employeesByRole, maxValue: maxRole, labeller: _formatRole),
            const SizedBox(height: 28.0),
          ],
          if (summary.employeesByDepartment.isNotEmpty) ...[
            BreakdownBlock(title: L10n.of(context).compositionByDepartment, entries: summary.employeesByDepartment, maxValue: maxDept),
            const SizedBox(height: 28.0),
          ],
          if (summary.recentJoiners.isNotEmpty) RecentJoiners(joiners: summary.recentJoiners),
        ],
      ),
    );
  }
}
