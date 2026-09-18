import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/roster_entry.dart';
import '../../models/station.dart';
import '../../utils/employee_names.dart';
import '../../utils/operation_names.dart';
import '../../utils/theme_tokens.dart';

/// Full-screen selection pages for choosing a station or an operator.
///
/// A dedicated page per choice rather than a dropdown: dropdowns show about seven rows
/// at a time, which means scanning a small scrolling window while standing at a machine.
/// Uniform full-width rows give a straight left edge to read down and a large touch
/// target, section headers group things the way the floor is organised, and a search box
/// handles the case where the supervisor already knows exactly who or what they want.

const double _rowHeight = 64.0;

/// The compact field shown on the form. Displays the current choice and opens the picker.
class PickerField extends StatelessWidget {
  final String label;
  final String? value;
  final String? subvalue;
  final String placeholder;
  final IconData icon;
  final VoidCallback onTap;

  const PickerField({
    super.key,
    required this.label,
    required this.value,
    required this.placeholder,
    required this.icon,
    required this.onTap,
    this.subvalue,
  });

  @override
  Widget build(BuildContext context) {
    final chosen = value != null && value!.isNotEmpty;
    return InkWell(
      borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 13.0),
        decoration: BoxDecoration(
          color: ThemeTokens.surfaceSolid,
          borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
          border: Border.all(color: chosen ? ThemeTokens.primary : ThemeTokens.hairline, width: chosen ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: chosen ? ThemeTokens.primary.withValues(alpha: 0.10) : ThemeTokens.surfaceSunken,
                borderRadius: BorderRadius.circular(ThemeTokens.radiusSmall),
              ),
              child: Icon(icon, size: 19, color: chosen ? ThemeTokens.primary : ThemeTokens.textLight),
            ),
            const SizedBox(width: 14.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: ThemeTokens.labelSmall.copyWith(fontSize: 9.5)),
                  const SizedBox(height: 3.0),
                  Text(
                    chosen ? value! : placeholder,
                    style: ThemeTokens.bodyLarge.copyWith(
                      fontSize: 14.5,
                      color: chosen ? ThemeTokens.textPrimary : ThemeTokens.textLight,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (chosen && subvalue != null && subvalue!.isNotEmpty) ...[
                    const SizedBox(height: 2.0),
                    Text(subvalue!, style: ThemeTokens.caption, overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: ThemeTokens.textLight),
          ],
        ),
      ),
    );
  }
}

/// One option, described independently of what it represents so both pickers can share
/// the same row rendering.
class _Option {
  final String id;
  final String title;
  final String subtitle;
  final String section;
  final Color? accent;
  final String searchText;
  final Object payload;

  _Option({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.section,
    required this.searchText,
    required this.payload,
    this.accent,
  });
}

/// Shared picker page: pinned search box, grouped rows, live filtering.
class _PickerPage extends StatefulWidget {
  final String title;
  final List<_Option> options;
  final String? selectedId;

  const _PickerPage({required this.title, required this.options, this.selectedId});

  @override
  State<_PickerPage> createState() => _PickerPageState();
}

class _PickerPageState extends State<_PickerPage> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_Option> get _filtered {
    if (_query.isEmpty) return widget.options;
    return widget.options.where((o) => o.searchText.contains(_query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = L10n.of(context);
    final results = _filtered;

    // Section headers are suppressed while searching - once the list is already short,
    // headers add noise rather than structure.
    final grouped = _query.isEmpty;
    final rows = <Widget>[];
    String? lastSection;
    for (final o in results) {
      if (grouped && o.section != lastSection) {
        rows.add(_SectionHeader(o.section));
        lastSection = o.section;
      }
      rows.add(_PickerRow(
        option: o,
        selected: o.id == widget.selectedId,
        onTap: () => Navigator.of(context).pop(o.payload),
      ));
    }

    return Scaffold(
      backgroundColor: ThemeTokens.background,
      appBar: AppBar(
        title: Text(widget.title, style: ThemeTokens.headingMedium.copyWith(fontSize: 17)),
        backgroundColor: ThemeTokens.background,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(62),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _controller,
              autofocus: false,
              style: ThemeTokens.inputText,
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: t.searchHint,
                hintStyle: ThemeTokens.hintText,
                prefixIcon: const Icon(Icons.search_rounded, size: 20, color: ThemeTokens.textLight),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18, color: ThemeTokens.textLight),
                        onPressed: () {
                          _controller.clear();
                          setState(() => _query = '');
                        },
                      ),
                filled: true,
                fillColor: ThemeTokens.surfaceSolid,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                border: _border(),
                enabledBorder: _border(),
                focusedBorder: _border(focused: true),
              ),
            ),
          ),
        ),
      ),
      body: results.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.search_off_rounded, size: 38, color: ThemeTokens.textLight),
                    const SizedBox(height: 14.0),
                    Text(t.noResults, style: ThemeTokens.bodyLarge.copyWith(fontSize: 15)),
                  ],
                ),
              ),
            )
          : ListView(padding: const EdgeInsets.only(bottom: 24), children: rows),
    );
  }

  OutlineInputBorder _border({bool focused = false}) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
        borderSide: BorderSide(
          color: focused ? ThemeTokens.primary : ThemeTokens.hairline,
          width: focused ? 1.5 : 1,
        ),
      );
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: ThemeTokens.surfaceSunken,
      padding: const EdgeInsets.fromLTRB(20, 9, 20, 9),
      child: Text(label, style: ThemeTokens.labelSmall.copyWith(fontSize: 9.5)),
    );
  }
}

class _PickerRow extends StatelessWidget {
  final _Option option;
  final bool selected;
  final VoidCallback onTap;

  const _PickerRow({required this.option, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: _rowHeight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        decoration: BoxDecoration(
          color: selected ? ThemeTokens.primary.withValues(alpha: 0.07) : ThemeTokens.background,
          border: const Border(bottom: BorderSide(color: ThemeTokens.hairline)),
        ),
        child: Row(
          children: [
            if (option.accent != null) ...[
              Container(
                width: 4,
                height: 30,
                decoration: BoxDecoration(
                  color: option.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 14.0),
            ],
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: ThemeTokens.bodyLarge.copyWith(
                      fontSize: 15,
                      color: selected ? ThemeTokens.primary : ThemeTokens.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (option.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 3.0),
                    Text(option.subtitle, style: ThemeTokens.caption, overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
            if (selected)
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: ThemeTokens.primary, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 15),
              ),
          ],
        ),
      ),
    );
  }
}

/// Opens the station picker and returns the chosen station, or null if dismissed.
Future<Station?> pickStation(BuildContext context, List<Station> stations, int? selectedId) {
  final active = stations.where((s) => s.active).toList()
    ..sort((a, b) {
      final z = a.zone.compareTo(b.zone);
      return z != 0 ? z : a.stationNumber.compareTo(b.stationNumber);
    });

  return Navigator.of(context).push<Station>(
    MaterialPageRoute(
      builder: (context) {
        final options = active
            .map((s) => _Option(
                  id: '${s.id}',
                  title: "${s.stationNumber}  ·  ${OperationNames.display(context, s.operationName)}",
                  subtitle: "SAM ${s.sam.toStringAsFixed(2)}  ·  ${s.operatorCount} operator${s.operatorCount == 1 ? '' : 's'}",
                  section: "ZONE ${s.zone}",
                  // Both scripts are searchable, so typing either "collar" or "కాలర్"
                  // finds the station regardless of which language the app is in.
                  searchText: "${s.stationNumber} ${s.operationName} "
                          "${OperationNames.display(context, s.operationName)} ${s.zone}"
                      .toLowerCase(),
                  payload: s,
                ))
            .toList();

        return _PickerPage(
          title: L10n.of(context).station,
          options: options,
          selectedId: selectedId?.toString(),
        );
      },
    ),
  );
}

/// Opens the operator picker and returns the chosen operator, or null if dismissed.
///
/// Anyone allocated to [stationId] is listed first under its own heading, since that is
/// nearly always who is being logged for - but the full present-today roster follows,
/// because production can be logged for someone who was never formally allocated.
Future<RosterEntry?> pickOperator(
  BuildContext context,
  List<RosterEntry> operators,
  int? selectedId,
  int? stationId,
) {
  final sorted = [...operators]..sort((a, b) => a.employeeName.compareTo(b.employeeName));
  final atStation = stationId == null ? <RosterEntry>[] : sorted.where((e) => e.stationId == stationId).toList();
  final others = sorted.where((e) => !atStation.contains(e)).toList();

  return Navigator.of(context).push<RosterEntry>(
    MaterialPageRoute(
      builder: (context) {
        final t = L10n.of(context);

        _Option toOption(RosterEntry e, String section, {Color? accent}) => _Option(
              id: '${e.employeeId}',
              title: EmployeeNames.display(context, e.employeeName),
              subtitle: [
                if (e.employeeCode != null && e.employeeCode!.isNotEmpty) e.employeeCode!,
                if (e.stationNumber != null) e.stationNumber!,
              ].join('  ·  '),
              section: section,
              accent: accent,
              searchText: "${e.employeeName} ${EmployeeNames.display(context, e.employeeName)} ${e.employeeCode ?? ''} ${e.stationNumber ?? ''}".toLowerCase(),
              payload: e,
            );

        final options = <_Option>[
          ...atStation.map((e) => toOption(e, t.atThisStation.toUpperCase(), accent: ThemeTokens.success)),
          ...others.map((e) => toOption(e, "${t.presentToday.toUpperCase()}  (${others.length})")),
        ];

        return _PickerPage(
          title: t.operator,
          options: options,
          selectedId: selectedId?.toString(),
        );
      },
    ),
  );
}
