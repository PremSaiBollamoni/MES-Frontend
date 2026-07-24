import 'package:flutter/material.dart';
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

  const LoginForm({
    super.key,
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
    required this.isLoading,
    required this.obscurePassword,
    required this.onObscureToggle,
    required this.onLoginPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: "Username",
            controller: usernameController,
            hint: "e.g. MES001",
            prefixIcon: const Icon(Icons.badge_outlined, size: 20, color: ThemeTokens.textLight),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Username is required";
              }
              return null;
            },
          ),
          const SizedBox(height: 18.0),
          AppTextField(
            label: "Password",
            controller: passwordController,
            obscureText: obscurePassword,
            hint: "Enter your password",
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
                return "Password is required";
              }
              return null;
            },
          ),
          const SizedBox(height: 32.0),
          AppPrimaryButton(label: "Sign in", onPressed: onLoginPressed, isLoading: isLoading),
        ],
      ),
    );
  }
}
