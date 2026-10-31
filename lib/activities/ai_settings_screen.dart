import 'package:flutter/material.dart';
import '../components/app_button.dart' show AppPrimaryButton;
import '../components/app_text_field.dart';
import '../components/custom_toast.dart';
import '../services/ai_api_service.dart';
import '../utils/error_messages.dart';
import '../utils/theme_tokens.dart';

/// SUPER_ADMIN-only: the AI providers, the models under each, and which model the support chat
/// and the daily reports use. Keys are never shown back - a blank key field keeps the saved one.
class AiSettingsScreen extends StatefulWidget {
  const AiSettingsScreen({super.key});

  @override
  State<AiSettingsScreen> createState() => _AiSettingsScreenState();
}

const _chatFeature = "CHAT";
const _reportFeature = "REPORT";

/// Starting points for the add-provider dialog. Every entry is editable afterwards, and any
/// OpenAI-compatible service (Groq, OpenRouter, OpenAI, a self-hosted one) works with the same type.
class _Preset {
  final String name;
  final String providerType;
  final String baseUrl;

  const _Preset(this.name, this.providerType, this.baseUrl);
}

const _presets = [
  _Preset("Groq", "OPENAI_COMPATIBLE", "https://api.groq.com/openai/v1"),
  _Preset("OpenRouter", "OPENAI_COMPATIBLE", "https://openrouter.ai/api/v1"),
  _Preset("OpenAI", "OPENAI_COMPATIBLE", "https://api.openai.com/v1"),
  _Preset("Google Gemini", "GEMINI", "https://generativelanguage.googleapis.com/v1beta"),
  _Preset("Anthropic", "ANTHROPIC", "https://api.anthropic.com/v1"),
  _Preset("Custom (OpenAI-compatible)", "OPENAI_COMPATIBLE", ""),
];

const _modelExamples = {
  "OPENAI_COMPATIBLE": "llama-3.3-70b-versatile, gpt-4o-mini, google/gemini-3.8-flash",
  "GEMINI": "gemini-2.5-flash",
  "ANTHROPIC": "claude-haiku-4-5-20251001",
};

String _typeLabel(String type) => switch (type) {
      "GEMINI" => "Google Gemini",
      "ANTHROPIC" => "Anthropic",
      _ => "OpenAI-compatible",
    };

typedef _ProviderForm = ({String name, String providerType, String address, String apiKey, bool enabled});

class _AiSettingsScreenState extends State<AiSettingsScreen> {
  final _service = AiApiService();

  bool _loading = true;
  bool _saving = false;
  List<AiProviderView> _providers = [];
  Map<String, AiFeatureView> _features = {};
  final Set<int> _testing = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([_service.listProviders(), _service.listFeatures()]);
      if (!mounted) return;
      final providers = results[0] as List<AiProviderView>;
      final features = results[1] as List<AiFeatureView>;
      setState(() {
        _providers = providers;
        _features = {for (final f in features) f.feature: f};
      });
    } catch (e) {
      if (mounted) CustomToast.show(context, ErrorMessages.translate(context, e), isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Runs [action], shows [successMessage], then reloads. Errors are shown as toasts.
  Future<void> _run(Future<void> Function() action, String successMessage) async {
    setState(() => _saving = true);
    try {
      await action();
      await _load();
      if (mounted) CustomToast.show(context, successMessage, isError: false);
    } catch (e) {
      if (mounted) CustomToast.show(context, ErrorMessages.translate(context, e), isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _test(AiModelView model) async {
    setState(() => _testing.add(model.id));
    try {
      final message = await _service.testModel(model.id);
      if (mounted) CustomToast.show(context, message, isError: false);
    } catch (e) {
      if (mounted) CustomToast.show(context, ErrorMessages.translate(context, e), isError: true);
    } finally {
      if (mounted) setState(() => _testing.remove(model.id));
    }
  }

  Future<bool> _confirm(String title, String body) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
        ],
      ),
    );
    return result == true;
  }

  Future<void> _addProvider() async {
    final form = await showDialog<_ProviderForm>(
      context: context,
      builder: (context) => const _ProviderDialog(),
    );
    if (form == null) return;
    await _run(
      () => _service.saveProvider(
        name: form.name,
        providerType: form.providerType,
        address: form.address,
        apiKey: form.apiKey,
        enabled: form.enabled,
      ),
      "Provider added",
    );
  }

  Future<void> _editProvider(AiProviderView provider) async {
    final form = await showDialog<_ProviderForm>(
      context: context,
      builder: (context) => _ProviderDialog(existing: provider),
    );
    if (form == null) return;
    await _run(
      () => _service.saveProvider(
        id: provider.id,
        name: form.name,
        providerType: form.providerType,
        address: form.address,
        apiKey: form.apiKey,
        enabled: form.enabled,
      ),
      "Provider saved",
    );
  }

  Future<void> _deleteProvider(AiProviderView provider) async {
    final ok = await _confirm(
      "Delete ${provider.name}?",
      "Its models and its saved key are removed. Any feature using one of its models is set to Not set.",
    );
    if (!ok) return;
    await _run(() => _service.deleteProvider(provider.id), "Provider deleted");
  }

  Future<void> _addModel(AiProviderView provider) async {
    final form = await showDialog<({String modelName, String label})>(
      context: context,
      builder: (context) => _ModelDialog(providerType: provider.providerType),
    );
    if (form == null) return;
    await _run(
      () => _service.addModel(providerId: provider.id, modelName: form.modelName, label: form.label),
      "Model added",
    );
  }

  Future<void> _deleteModel(AiModelView model) async {
    final ok = await _confirm("Remove ${model.modelName}?", "Features using this model are set to Not set.");
    if (!ok) return;
    await _run(() => _service.deleteModel(model.id), "Model removed");
  }

  List<DropdownMenuItem<int?>> _modelItems() {
    final items = <DropdownMenuItem<int?>>[];
    for (final provider in _providers.where((p) => p.enabled)) {
      for (final model in provider.models.where((m) => m.enabled)) {
        items.add(DropdownMenuItem<int?>(
          value: model.id,
          child: Text(
            "${provider.name} - ${model.label ?? model.modelName}",
            overflow: TextOverflow.ellipsis,
          ),
        ));
      }
    }
    return items;
  }

  Widget _card({required String title, required String subtitle, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeTokens.surfaceSolid,
        borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
        border: Border.all(color: ThemeTokens.hairline),
        boxShadow: ThemeTokens.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: ThemeTokens.headingMedium),
          const SizedBox(height: 4),
          Text(subtitle, style: ThemeTokens.caption),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }

  Widget _featureSelector({required String feature, required String title, required String subtitle}) {
    final current = _features[feature]?.modelId;
    final items = _modelItems();
    final currentValid = current == null || items.any((i) => i.value == current);
    final fallback = _features[feature]?.fallbackModelId;
    final fallbackValid = fallback == null || (fallback != current && items.any((i) => i.value == fallback));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: ThemeTokens.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(subtitle, style: ThemeTokens.caption),
        const SizedBox(height: 8),
        InputDecorator(
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: ThemeTokens.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int?>(
              isExpanded: true,
              value: currentValid ? current : null,
              hint: const Text("Choose a model"),
              items: [const DropdownMenuItem<int?>(value: null, child: Text("Not set")), ...items],
              onChanged: _saving
                  ? null
                  : (value) => _run(() => _service.assignFeature(feature, modelId: value, fallbackModelId: fallback), "Saved"),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text("If unavailable, switch to", style: ThemeTokens.caption),
        const SizedBox(height: 6),
        InputDecorator(
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: ThemeTokens.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int?>(
              isExpanded: true,
              value: fallbackValid ? fallback : null,
              items: [
                const DropdownMenuItem<int?>(value: null, child: Text("No fallback")),
                ...items.where((i) => i.value != current),
              ],
              onChanged: _saving
                  ? null
                  : (value) => _run(() => _service.assignFeature(feature, modelId: current, fallbackModelId: value), "Saved"),
            ),
          ),
        ),
        const SizedBox(height: 6),
        if (current == null || !currentValid)
          Text(
            "Not set - this feature stays off until a model is chosen.",
            style: ThemeTokens.caption.copyWith(color: ThemeTokens.warning),
          ),
      ],
    );
  }

  Widget _providerCard(AiProviderView provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeTokens.surfaceSolid,
        borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
        border: Border.all(color: ThemeTokens.hairline),
        boxShadow: ThemeTokens.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(provider.name, style: ThemeTokens.headingMedium),
                    const SizedBox(height: 2),
                    Text(
                      "${_typeLabel(provider.providerType)} - ${provider.baseUrl}",
                      style: ThemeTokens.caption,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: "Edit",
                icon: const Icon(Icons.edit_rounded, size: 20, color: ThemeTokens.textSecondary),
                onPressed: _saving ? null : () => _editProvider(provider),
              ),
              IconButton(
                tooltip: "Delete",
                icon: const Icon(Icons.delete_outline_rounded, size: 20, color: ThemeTokens.textSecondary),
                onPressed: _saving ? null : () => _deleteProvider(provider),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            [
              provider.keySet ? "Key saved" : "No key saved",
              if (!provider.enabled) "Disabled",
            ].join(" - "),
            style: ThemeTokens.caption.copyWith(
              color: provider.keySet && provider.enabled ? ThemeTokens.success : ThemeTokens.warning,
            ),
          ),
          const Divider(height: 24),
          if (provider.models.isEmpty)
            Text("No models yet. Add one below.", style: ThemeTokens.caption),
          for (final model in provider.models) _modelRow(model),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _saving ? null : () => _addModel(provider),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text("Add model"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modelRow(AiModelView model) {
    final testing = _testing.contains(model.id);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(model.label ?? model.modelName, style: ThemeTokens.bodyMedium, overflow: TextOverflow.ellipsis),
                if (model.label != null)
                  Text(model.modelName, style: ThemeTokens.caption, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          TextButton(
            onPressed: testing || _saving ? null : () => _test(model),
            child: testing
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: ThemeTokens.primary),
                  )
                : const Text("Test"),
          ),
          IconButton(
            tooltip: "Remove",
            icon: const Icon(Icons.close_rounded, size: 18, color: ThemeTokens.textSecondary),
            onPressed: _saving ? null : () => _deleteModel(model),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: ThemeTokens.primary));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _card(
            title: "Models in use",
            subtitle: "Pick one model for the in-app chat assistant and one for the daily PDF reports. They can use different providers.",
            children: [
              _featureSelector(
                feature: _chatFeature,
                title: "Chat assistant",
                subtitle: "Support chat and ticket drafting.",
              ),
              const SizedBox(height: 20),
              _featureSelector(
                feature: _reportFeature,
                title: "Daily reports",
                subtitle: "PDF reports in daily emails and reports generated in the app.",
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Text("Providers", style: ThemeTokens.headingMedium)),
              TextButton.icon(
                onPressed: _saving ? null : _addProvider,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text("Add provider"),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (_providers.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text("No providers yet. Add one to start.", style: ThemeTokens.caption),
            ),
          for (final provider in _providers) ...[
            _providerCard(provider),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

/// Add or edit a provider. A blank key keeps the saved one - the key is never shown back.
class _ProviderDialog extends StatefulWidget {
  final AiProviderView? existing;

  const _ProviderDialog({this.existing});

  @override
  State<_ProviderDialog> createState() => _ProviderDialogState();
}

class _ProviderDialogState extends State<_ProviderDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  final _keyController = TextEditingController();
  late String _providerType;
  late bool _enabled;
  bool _obscureKey = true;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? _presets.first.name);
    _addressController = TextEditingController(text: existing?.baseUrl ?? _presets.first.baseUrl);
    _providerType = existing?.providerType ?? _presets.first.providerType;
    _enabled = existing?.enabled ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  void _applyPreset(_Preset preset) {
    setState(() {
      _nameController.text = preset.name.startsWith("Custom") ? "" : preset.name;
      _addressController.text = preset.baseUrl;
      _providerType = preset.providerType;
    });
  }

  void _submit() {
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    if (name.isEmpty || address.isEmpty) {
      CustomToast.show(context, "Name and base URL are required", isError: true);
      return;
    }
    Navigator.pop<_ProviderForm>(context, (
      name: name,
      providerType: _providerType,
      address: address,
      apiKey: _keyController.text.trim(),
      enabled: _enabled,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final existing = widget.existing;
    final keySet = existing?.keySet ?? false;
    return AlertDialog(
      title: Text(existing == null ? "Add provider" : "Edit ${existing.name}"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (existing == null) ...[
              Text("Start from", style: ThemeTokens.caption),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final preset in _presets)
                    ActionChip(label: Text(preset.name), onPressed: () => _applyPreset(preset)),
                ],
              ),
              const SizedBox(height: 14),
            ],
            AppTextField(controller: _nameController, label: "Name", hint: "e.g. Groq"),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _providerType,
              decoration: const InputDecoration(labelText: "Type"),
              items: [
                for (final type in ["OPENAI_COMPATIBLE", "GEMINI", "ANTHROPIC"])
                  DropdownMenuItem(value: type, child: Text(_typeLabel(type))),
              ],
              onChanged: (value) => setState(() => _providerType = value ?? _providerType),
            ),
            const SizedBox(height: 12),
            AppTextField(controller: _addressController, label: "Base URL", hint: "https://..."),
            const SizedBox(height: 12),
            AppTextField(
              controller: _keyController,
              label: "API key",
              hint: keySet ? "Saved - leave blank to keep it" : "Paste the key",
              obscureText: _obscureKey,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureKey ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 20,
                  color: ThemeTokens.textLight,
                ),
                onPressed: () => setState(() => _obscureKey = !_obscureKey),
              ),
            ),
            const SizedBox(height: 6),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Enabled"),
              subtitle: Text("Turn off to stop every model under this provider.", style: ThemeTokens.caption),
              value: _enabled,
              onChanged: (value) => setState(() => _enabled = value),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        AppPrimaryButton(label: "Save", onPressed: _submit),
      ],
    );
  }
}

/// Add a model name under a provider. Any name the provider accepts works.
class _ModelDialog extends StatefulWidget {
  final String providerType;

  const _ModelDialog({required this.providerType});

  @override
  State<_ModelDialog> createState() => _ModelDialogState();
}

class _ModelDialogState extends State<_ModelDialog> {
  final _modelController = TextEditingController();
  final _labelController = TextEditingController();

  @override
  void dispose() {
    _modelController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  void _submit() {
    final model = _modelController.text.trim();
    if (model.isEmpty) {
      CustomToast.show(context, "Model name is required", isError: true);
      return;
    }
    Navigator.pop<({String modelName, String label})>(context, (
      modelName: model,
      label: _labelController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add model"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: _modelController,
              label: "Model name",
              hint: "e.g. ${_modelExamples[widget.providerType] ?? ""}",
            ),
            const SizedBox(height: 12),
            AppTextField(controller: _labelController, label: "Label (optional)", hint: "e.g. Fast and cheap"),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        AppPrimaryButton(label: "Add", onPressed: _submit),
      ],
    );
  }
}
