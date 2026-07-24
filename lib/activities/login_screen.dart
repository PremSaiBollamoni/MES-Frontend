import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../components/custom_toast.dart';
import '../components/login_form.dart';
import '../utils/theme_tokens.dart';
import 'main_shell_screen.dart';
import 'role_selection_screen.dart';

/// Left-aligned, flat, whitespace-led login - no big circular logo, no
/// gradient card. A small wordmark, a heading, and the form; that's it.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _apiService.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (result.requiresRoleSelection) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => RoleSelectionScreen(pending: result.roleSelection!)),
        );
        return;
      }

      final user = result.user!;
      CustomToast.show(context, "Welcome back, ${user.name}!", isError: false);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MainShellScreen(user: user)),
      );
    } catch (e) {
      if (mounted) {
        CustomToast.show(context, e.toString().replaceAll("Exception: ", ""), isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(color: ThemeTokens.primary, borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium)),
                    alignment: Alignment.center,
                    child: const Icon(Icons.checkroom_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 40.0),
                  Text("Welcome back", style: ThemeTokens.headingDisplay.copyWith(fontSize: 30), textAlign: TextAlign.center),
                  const SizedBox(height: 8.0),
                  Text(
                    "Sign in to your MES account to continue.",
                    style: ThemeTokens.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40.0),
                  LoginForm(
                    formKey: _formKey,
                    usernameController: _usernameController,
                    passwordController: _passwordController,
                    isLoading: _isLoading,
                    obscurePassword: _obscurePassword,
                    onObscureToggle: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    onLoginPressed: _handleLogin,
                  ),
                  const SizedBox(height: 40.0),
                  Text(
                    "MES v2.0 · Real-time production tracker",
                    style: ThemeTokens.footerCaption,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
