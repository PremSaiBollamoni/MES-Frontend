import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../utils/theme_tokens.dart';
import 'app_button.dart';
import 'app_text_field.dart';

class LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool isLoading;
  final bool obscurePassword;
  final VoidCallback onObscureToggle;
  final VoidCallback onLoginPressed;
  final VoidCallback onForgotPassword;

  const LoginForm({
    super.key,
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
    required this.isLoading,
    required this.obscurePassword,
    required this.onObscureToggle,
    required this.onLoginPressed,
    required this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    final t = L10n.of(context);
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: t.loginUsername,
            controller: usernameController,
            hint: "e.g. MES001",
            prefixIcon: const Icon(Icons.badge_outlined, size: 20, color: ThemeTokens.textLight),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return t.loginUsernameRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: 18.0),
          AppTextField(
            label: t.loginPassword,
            controller: passwordController,
            obscureText: obscurePassword,
            hint: "••••••••",
            prefixIcon: const Icon(Icons.lock_outlined, size: 20, color: ThemeTokens.textLight),
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 20,
                color: ThemeTokens.textLight,
              ),
              onPressed: onObscureToggle,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return t.loginPasswordRequired;
              }
              return null;
            },
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onForgotPassword,
              child: Text("Forgot Password?", style: ThemeTokens.caption.copyWith(color: ThemeTokens.primaryDark, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 8.0),
          AppPrimaryButton(label: t.loginSignIn, onPressed: onLoginPressed, isLoading: isLoading),
        ],
      ),
    );
  }
}
