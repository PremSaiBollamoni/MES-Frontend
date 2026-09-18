import 'package:flutter/material.dart';
import '../utils/theme_tokens.dart';

/// Underline-style date field matching AppTextField.
class AppDateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String hint;

  const AppDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    this.hint = "Select date",
  });

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1950),
      lastDate: lastDate ?? DateTime.now(),
    );
    if (picked != null) {
      onChanged(picked);
    }
  }

  String _format(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label.toUpperCase(), style: ThemeTokens.labelSmall),
        InkWell(
          onTap: () => _pickDate(context),
          child: Container(
            padding: const EdgeInsets.only(top: 12.0, bottom: 10.0),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: ThemeTokens.hairline)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value != null ? _format(value!) : hint,
                    style: value != null ? ThemeTokens.inputText.copyWith(fontSize: 15) : ThemeTokens.hintText,
                  ),
                ),
                Icon(Icons.event_outlined, size: 17, color: ThemeTokens.textLight),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
