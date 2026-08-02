import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/api_service.dart';
import '../components/custom_toast.dart';
import '../components/login_form.dart';
import '../utils/locale_controller.dart';
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

  @override
  Widget build(BuildContext context) {
    final t = L10n.of(context);
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      body: SafeArea(
        // Column + Expanded rather than a single scroll view, so the attribution
        // stays pinned to the bottom of the screen instead of trailing the form.
        child: Column(
          children: [
            // Language choice sits above everything - someone who cannot read the
            // English form needs to reach it before they read anything else.
            const Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 12, 20, 0),
                child: _LoginLanguageSwitcher(),
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 380),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const _InstitutionLogos(),
                        const SizedBox(height: 52.0),
                        Text(
                          t.loginWelcome,
                          style: ThemeTokens.headingDisplay.copyWith(fontSize: 30),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          t.loginSubtitle,
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const _PoweredByFooter(),
          ],
        ),
      ),
    );
  }
}

/// Compact language toggle for the sign-in screen.
///
/// Deliberately a pair of always-visible pills rather than a dropdown: a dropdown
/// hides the alternative behind a label the user may not be able to read, whereas
/// seeing "తెలుగు" written in its own script is self-explanatory.
class _LoginLanguageSwitcher extends StatelessWidget {
  const _LoginLanguageSwitcher();

  @override
  Widget build(BuildContext context) {
    final controller = LocaleController();
    return ValueListenableBuilder<Locale>(
      valueListenable: controller.locale,
      builder: (context, current, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.translate_rounded, size: 15, color: ThemeTokens.textLight),
            const SizedBox(width: 8.0),
            ...LocaleController.supported.map((locale) {
              final selected = locale.languageCode == current.languageCode;
              return Padding(
                padding: const EdgeInsets.only(left: 6.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(ThemeTokens.radiusPill),
                  onTap: () => controller.setLocale(locale),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                    decoration: BoxDecoration(
                      color: selected ? ThemeTokens.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(ThemeTokens.radiusPill),
                      border: Border.all(
                        color: selected ? ThemeTokens.primary : ThemeTokens.hairline,
                      ),
                    ),
                    child: Text(
                      LocaleController.nameOf(locale),
                      style: ThemeTokens.caption.copyWith(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: selected ? Colors.white : ThemeTokens.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

/// The two institutional logos, side by side at the top of the sign-in screen.
///
/// A logo is only rendered if its asset actually exists - a missing file degrades to
/// nothing rather than to Flutter's broken-image box, so the screen stays presentable
/// while brand assets are still being collected.
class _InstitutionLogos extends StatelessWidget {
  const _InstitutionLogos();

  // The two marks have very different proportions - Centurion's is a square seal,
  // GramTarang's is a wide 3:1 wordmark. Constraining both to the same height would
  // push the row past the screen width, so each is sized on its natural dimension
  // and the pair is balanced by visual weight rather than by matching numbers.
  static const double _sealSize = 84.0;
  static const double _wordmarkWidth = 156.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/logos/centurion.png',
          height: _sealSize,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => const SizedBox(height: _sealSize, width: _sealSize),
        ),
        const SizedBox(width: 18.0),
        Container(width: 1, height: 52, color: ThemeTokens.hairline),
        const SizedBox(width: 18.0),
        Image.asset(
          'assets/logos/gramtarang.png',
          width: _wordmarkWidth,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => const SizedBox(width: _wordmarkWidth, height: 52),
        ),
      ],
    );
  }
}

/// Institutional attribution pinned to the bottom of the sign-in screen - ownership of
/// the product, deliberately separated from the sign-in flow by whitespace alone.
class _PoweredByFooter extends StatelessWidget {
  const _PoweredByFooter();

  static TextStyle get _institutionStyle => ThemeTokens.bodyMedium.copyWith(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: ThemeTokens.textSecondary,
        height: 1.45,
      );

  @override
  Widget build(BuildContext context) {
    final t = L10n.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28.0, 16.0, 28.0, 22.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // "A product of" rather than "powered by" - this is authorship, not
          // infrastructure running underneath someone else's product.
          Text(
            t.aProductOf,
            style: ThemeTokens.labelSmall.copyWith(fontSize: 9, color: ThemeTokens.textLight),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8.0),
          // One joined string rather than two stacked lines - the ampersand makes the
          // two institutions read as a single shared credit. Identical styling
          // throughout, so neither name is presented as subordinate to the other.
          Text(
            t.institutions,
            style: _institutionStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
