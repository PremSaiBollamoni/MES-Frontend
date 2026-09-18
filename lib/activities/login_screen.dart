import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/api_service.dart';
import '../components/custom_toast.dart';
import '../utils/theme_tokens.dart';
import 'login_brand_panel.dart';
import 'login_sign_in_pane.dart';
import 'main_shell_screen.dart';
import 'role_selection_screen.dart';

/// Flat, whitespace-led sign-in form. On a wide (desktop/tablet) window a dark brand
/// panel fills what would otherwise be empty grey space alongside it; on a phone-width
/// window the form alone fills the screen. Both halves settle in via one staggered
/// entrance animation on load.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  final ApiService _apiService = ApiService();

  // Drives the whole screen's staggered entrance (brand panel, then logos, then
  // heading, then the form cascading in) - one controller, each element just picks
  // its own slice of it via EntranceFade's interval.
  late final AnimationController _entrance;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _entrance.dispose();
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
      CustomToast.show(context, L10n.of(context).loginWelcomeBack(user.name), isError: false);

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

  Widget _buildSignInPane({required bool showFooter}) {
    return LoginSignInPane(
      formKey: _formKey,
      usernameController: _usernameController,
      passwordController: _passwordController,
      isLoading: _isLoading,
      obscurePassword: _obscurePassword,
      onObscureToggle: () => setState(() => _obscurePassword = !_obscurePassword),
      onLoginPressed: _handleLogin,
      showFooter: showFooter,
      entrance: _entrance,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Below this width the brand panel would squeeze the form uncomfortably
          // narrow, so a phone/small-tablet window gets exactly the old single-column
          // layout instead.
          if (constraints.maxWidth < 900) return _buildSignInPane(showFooter: true);
          // The brand panel already credits both institutions, so the form pane's own
          // footer would just repeat it - shown once, not twice.
          return Row(
            children: [
              Expanded(flex: 5, child: LoginBrandPanel(entrance: _entrance)),
              Expanded(flex: 4, child: _buildSignInPane(showFooter: false)),
            ],
          );
        },
      ),
    );
  }
}
