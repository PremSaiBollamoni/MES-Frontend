import 'package:flutter/material.dart';
import '../components/app_button.dart';
import '../components/factory_card.dart';
import '../models/factory_detail.dart';
import '../services/factory_api_service.dart';
import '../utils/theme_tokens.dart';
import 'employee_export_screen.dart';
import 'factory_form_screen.dart';

/// SUPER_ADMIN only - lists every factory (company/tenant) this app serves, with
/// entry points to create a new one or edit an existing one's details and HRMS config.
class FactoryListScreen extends StatefulWidget {
  const FactoryListScreen({super.key});

  @override
  State<FactoryListScreen> createState() => _FactoryListScreenState();
}

class _FactoryListScreenState extends State<FactoryListScreen> {
  final FactoryApiService _apiService = FactoryApiService();

  bool _isLoading = true;
  String? _errorMessage;
  List<FactoryDetail> _factories = [];

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
      final factories = await _apiService.listFactories(forceRefresh: forceRefresh);
      if (!mounted) return;
      setState(() {
        _factories = factories;
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
      MaterialPageRoute(builder: (context) => const FactoryFormScreen()),
    );
    if (created == true) _load();
  }

  Future<void> _openEditForm(FactoryDetail factory) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => FactoryFormScreen(existing: factory)),
    );
    if (updated == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      floatingActionButton: FloatingActionButton(
        heroTag: "factory_list_fab",
        onPressed: _openCreateForm,
        backgroundColor: ThemeTokens.primary,
        elevation: 2,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildStatsStrip(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsStrip() {
    final total = _factories.length;
    final active = _factories.where((f) => f.active).length;
    final hrmsOn = _factories.where((f) => f.hrmsEnabled).length;

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
              stat("Total factories", "$total"),
              stat("Active", "$active"),
              stat("HRMS enabled", "$hrmsOn"),
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
              Text(_errorMessage!, style: ThemeTokens.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 16.0),
              AppPrimaryButton(label: "Retry", onPressed: _load),
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
        itemCount: _factories.length,
        itemBuilder: (context, index) {
          final factory = _factories[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Row(
              children: [
                Expanded(child: FactoryCard(factory: factory, onTap: () => _openEditForm(factory))),
                IconButton(
                  tooltip: "Export employees",
                  icon: const Icon(Icons.download_for_offline_rounded, color: ThemeTokens.primaryDark),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => EmployeeExportScreen(factory: factory)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
