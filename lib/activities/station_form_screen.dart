import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../components/app_button.dart';
import '../components/app_dropdown_field.dart';
import '../components/app_text_field.dart';
import '../components/confirm_dialog.dart';
import '../components/custom_toast.dart';
import '../components/section_card.dart';
import '../models/station.dart';
import '../services/station_api_service.dart';
import '../utils/theme_tokens.dart';

/// Single screen for both creating and editing a station (Operation Bulletin
/// row). Pass [existing] to edit; omit it to create a new station.
class StationFormScreen extends StatefulWidget {
  final Station? existing;

  const StationFormScreen({super.key, this.existing});

  bool get isEditMode => existing != null;

  @override
  State<StationFormScreen> createState() => _StationFormScreenState();
}

class _StationFormScreenState extends State<StationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final StationApiService _apiService = StationApiService();

  final _stationNumberController = TextEditingController();
  final _operationNameController = TextEditingController();
  final _samController = TextEditingController();
  final _operatorCountController = TextEditingController(text: "1");
  final _targetPerHourController = TextEditingController();
  final _targetPerDayController = TextEditingController();
  final _rateController = TextEditingController();
  final _minStockController = TextEditingController(text: "0");
  final _maxStockController = TextEditingController(text: "0");

  String _zone = "S1";
  bool _active = true;
  bool _isSaving = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _stationNumberController.text = existing.stationNumber;
      _operationNameController.text = existing.operationName;
      _samController.text = "${existing.sam}";
      _operatorCountController.text = "${existing.operatorCount}";
      _targetPerHourController.text = "${existing.targetPiecesPerHour}";
      _targetPerDayController.text = "${existing.targetPiecesPerDay}";
      _rateController.text = "${existing.ratePerPiece}";
      _minStockController.text = "${existing.minStockThreshold}";
      _maxStockController.text = "${existing.maxStockThreshold}";
      _zone = existing.zone;
      _active = existing.active;
    }
  }

  @override
  void dispose() {
    _stationNumberController.dispose();
    _operationNameController.dispose();
    _samController.dispose();
    _operatorCountController.dispose();
    _targetPerHourController.dispose();
    _targetPerDayController.dispose();
    _rateController.dispose();
    _minStockController.dispose();
    _maxStockController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final request = StationRequest(
        stationNumber: widget.isEditMode ? null : _stationNumberController.text.trim(),
        operationName: _operationNameController.text.trim(),
        zone: _zone,
        sam: double.parse(_samController.text.trim()),
        operatorCount: int.parse(_operatorCountController.text.trim()),
        targetPiecesPerHour: int.parse(_targetPerHourController.text.trim()),
        targetPiecesPerDay: int.parse(_targetPerDayController.text.trim()),
        ratePerPiece: double.parse(_rateController.text.trim()),
        active: widget.isEditMode ? _active : null,
        minStockThreshold: _minStockController.text.trim().isEmpty ? 0 : int.parse(_minStockController.text.trim()),
        maxStockThreshold: _maxStockController.text.trim().isEmpty ? 0 : int.parse(_maxStockController.text.trim()),
      );
      if (widget.isEditMode) {
        await _apiService.updateStation(widget.existing!.id, request);
      } else {
        await _apiService.createStation(request);
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

  Future<void> _deleteStation() async {
    final existing = widget.existing;
    if (existing == null) return;

    final confirmed = await showConfirmDialog(
      context,
      title: L10n.of(context).deleteStation,
      message: "This will permanently delete ${existing.stationNumber} (${existing.operationName}). This cannot be undone.",
    );
    if (!confirmed) return;

    setState(() => _isDeleting = true);
    try {
      await _apiService.deleteStation(existing.id);
      if (!mounted) return;
      CustomToast.show(context, L10n.of(context).stationDeleted);
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      CustomToast.show(context, e.toString().replaceAll("Exception: ", ""), isError: true);
      setState(() => _isDeleting = false);
    }
  }

  String? _requiredNumber(String? v, {bool isDecimal = true}) {
    if (v == null || v.trim().isEmpty) return L10n.of(context).required;
    final parsed = isDecimal ? double.tryParse(v.trim()) : int.tryParse(v.trim());
    if (parsed == null) return L10n.of(context).enterAValidNumber;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      appBar: AppBar(title: Text(widget.isEditMode ? L10n.of(context).editStation : L10n.of(context).addStation, style: ThemeTokens.headingMedium.copyWith(fontSize: 17))),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionCard(
                  title: L10n.of(context).stationDetails,
                  icon: Icons.factory_outlined,
                  child: Column(
                    children: [
                      AppTextField(
                        label: L10n.of(context).stationNumber,
                        controller: _stationNumberController,
                        hint: "e.g. STATION-38",
                        validator: (v) => (v == null || v.trim().isEmpty) ? L10n.of(context).stationNumberIsRequired : null,
                      ),
                      if (widget.isEditMode)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(L10n.of(context).stationNumberCanTBe, style: ThemeTokens.caption),
                          ),
                        ),
                      const SizedBox(height: 16.0),
                      AppTextField(
                        label: L10n.of(context).operationName,
                        controller: _operationNameController,
                        hint: "e.g. Collar Run",
                        validator: (v) => (v == null || v.trim().isEmpty) ? L10n.of(context).operationNameIsRequired : null,
                      ),
                      const SizedBox(height: 16.0),
                      AppDropdownField<String>(
                        label: L10n.of(context).zone,
                        value: _zone,
                        items: [
                          DropdownMenuItem(value: "S1", child: Text(L10n.of(context).s1SubAssembly)),
                          DropdownMenuItem(value: "S2", child: Text(L10n.of(context).s2FullGarmentAssembly)),
                        ],
                        onChanged: (v) => setState(() => _zone = v ?? "S1"),
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
                  title: L10n.of(context).samTargets,
                  icon: Icons.speed_outlined,
                  child: Column(
                    children: [
                      AppTextField(
                        label: L10n.of(context).samStandardAllowedMinutes,
                        controller: _samController,
                        hint: "e.g. 1.2",
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (v) => _requiredNumber(v),
                      ),
                      const SizedBox(height: 16.0),
                      AppTextField(
                        label: L10n.of(context).operatorCount,
                        controller: _operatorCountController,
                        keyboardType: TextInputType.number,
                        validator: (v) => _requiredNumber(v, isDecimal: false),
                      ),
                      const SizedBox(height: 16.0),
                      AppTextField(
                        label: L10n.of(context).targetPiecesHour,
                        controller: _targetPerHourController,
                        keyboardType: TextInputType.number,
                        validator: (v) => _requiredNumber(v, isDecimal: false),
                      ),
                      const SizedBox(height: 16.0),
                      AppTextField(
                        label: L10n.of(context).targetPiecesDay,
                        controller: _targetPerDayController,
                        keyboardType: TextInputType.number,
                        validator: (v) => _requiredNumber(v, isDecimal: false),
                      ),
                      const SizedBox(height: 16.0),
                      AppTextField(
                        label: L10n.of(context).minimumStockThreshold,
                        controller: _minStockController,
                        hint: "e.g. 50",
                        keyboardType: TextInputType.number,
                        validator: (v) => v == null || v.trim().isEmpty ? null : (int.tryParse(v.trim()) == null ? L10n.of(context).enterAValidWholeNumber : null),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            L10n.of(context).stockAvailabilityIsAutoFlagged2,
                            style: ThemeTokens.caption,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      AppTextField(
                        label: L10n.of(context).maximumStockThresholdOptional0,
                        controller: _maxStockController,
                        hint: "e.g. 500",
                        keyboardType: TextInputType.number,
                        validator: (v) => v == null || v.trim().isEmpty ? null : (int.tryParse(v.trim()) == null ? L10n.of(context).enterAValidWholeNumber : null),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            L10n.of(context).stockAvailabilityIsAutoFlagged,
                            style: ThemeTokens.caption,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
                SectionCard(
                  title: L10n.of(context).pieceRatePay,
                  icon: Icons.currency_rupee_rounded,
                  child: AppTextField(
                    label: L10n.of(context).ratePerPiece,
                    controller: _rateController,
                    hint: "e.g. 0.75",
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => _requiredNumber(v),
                  ),
                ),
                const SizedBox(height: 24.0),
                AppPrimaryButton(
                  label: widget.isEditMode ? L10n.of(context).saveChanges : L10n.of(context).createStation,
                  onPressed: _submit,
                  isLoading: _isSaving,
                ),
                if (widget.isEditMode) ...[
                  const SizedBox(height: 12.0),
                  AppGhostButton(
                    label: L10n.of(context).deleteStation,
                    onPressed: _deleteStation,
                    isLoading: _isDeleting,
                    color: ThemeTokens.error,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
