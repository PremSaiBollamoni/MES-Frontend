import 'package:flutter/material.dart';
import '../components/app_button.dart';
import '../components/factory_card.dart';
import '../models/factory_detail.dart';
import '../services/factory_api_service.dart';
import '../utils/theme_tokens.dart';
import 'employee_list_screen.dart';

/// SUPER_ADMIN's entry point to Employees - since they don't belong to any single
/// factory, "Employees" starts here (pick a factory) rather than dumping every
/// factory's employees into one merged list. Tapping a factory drills into its
/// own EmployeeListScreen, scoped server-side to that factory only.
class EmployeesFactoryPickerScreen extends StatefulWidget {
  const EmployeesFactoryPickerScreen({super.key});

  @override
  State<EmployeesFactoryPickerScreen> createState() => _EmployeesFactoryPickerScreenState();
}

class _EmployeesFactoryPickerScreenState extends State<EmployeesFactoryPickerScreen> {
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

  void _openFactory(FactoryDetail factory) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EmployeeListScreen(viewFactoryId: factory.factoryId, factoryLabel: factory.factoryName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      body: SafeArea(child: _buildBody()),
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
    if (_factories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text("No factories yet - create one under the Factories tab first.", style: ThemeTokens.bodyMedium, textAlign: TextAlign.center),
        ),
      );
    }

    return RefreshIndicator(
      color: ThemeTokens.primary,
      onRefresh: () => _load(forceRefresh: true),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
        children: [
          Text(
            "SELECT A FACTORY TO VIEW ITS EMPLOYEES",
            style: ThemeTokens.labelSmall,
          ),
          const SizedBox(height: 16.0),
          ..._factories.map((factory) => Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: FactoryCard(factory: factory, onTap: () => _openFactory(factory)),
              )),
        ],
      ),
    );
  }
}
