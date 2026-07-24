import 'package:flutter/material.dart';
import '../utils/theme_tokens.dart';

/// Underline-style dropdown matching AppTextField.
class AppDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;
  final String? hint;

  const AppDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label.toUpperCase(), style: ThemeTokens.labelSmall),
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          validator: validator,
          isExpanded: true,
          dropdownColor: ThemeTokens.surfaceRaised,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: ThemeTokens.textLight),
          style: ThemeTokens.inputText.copyWith(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: ThemeTokens.hintText,
            isDense: true,
            contentPadding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
            filled: false,
            border: const UnderlineInputBorder(borderSide: BorderSide(color: ThemeTokens.hairline)),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: ThemeTokens.hairline)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: ThemeTokens.primary, width: 1.5)),
            errorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: ThemeTokens.error)),
            focusedErrorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: ThemeTokens.error, width: 1.5)),
            errorStyle: ThemeTokens.caption.copyWith(color: ThemeTokens.error),
          ),
        ),
      ],
    );
  }
}
