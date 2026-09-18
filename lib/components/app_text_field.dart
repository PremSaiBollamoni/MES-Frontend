import 'package:flutter/material.dart';
import '../utils/theme_tokens.dart';

/// Underline-style field - an uppercase eyebrow label above a text line with
/// only a bottom rule that turns gold on focus. Editorial-luxury, not a boxed
/// or pill input.
class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final int maxLines;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.suffixIcon,
    this.prefixIcon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label.toUpperCase(), style: ThemeTokens.labelSmall),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: obscureText ? 1 : maxLines,
          style: ThemeTokens.inputText.copyWith(fontSize: 15),
          cursorColor: ThemeTokens.primary,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: ThemeTokens.hintText,
            isDense: true,
            contentPadding: const EdgeInsets.only(top: 10.0, bottom: 8.0),
            filled: false,
            border: const UnderlineInputBorder(borderSide: BorderSide(color: ThemeTokens.hairline)),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: ThemeTokens.hairline)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: ThemeTokens.primary, width: 1.5)),
            errorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: ThemeTokens.error)),
            focusedErrorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: ThemeTokens.error, width: 1.5)),
            errorStyle: ThemeTokens.caption.copyWith(color: ThemeTokens.error),
            prefixIcon: prefixIcon,
            prefixIconConstraints: const BoxConstraints(minWidth: 30),
            suffixIcon: suffixIcon,
            suffixIconConstraints: const BoxConstraints(minWidth: 40),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
