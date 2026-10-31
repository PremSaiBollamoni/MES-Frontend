import 'package:flutter/material.dart';
import '../components/entrance_fade.dart';
import '../components/login_form.dart';
import '../l10n/app_localizations.dart';
import '../utils/theme_tokens.dart';
import 'login_widgets.dart';

/// The sign-in form itself, with the language switcher and institutional footer -
/// fills the whole screen on a phone, or just the right-hand pane on a wide window.
/// Its entrance is staggered off a shared [entrance] animation: logos, then heading,
/// then the form itself cascade in rather than appearing all at once.
class LoginSignInPane extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool isLoading;
  final bool obscurePassword;
  final VoidCallback onObscureToggle;
  final VoidCallback onLoginPressed;
  final VoidCallback onForgotPassword;
  final bool showFooter;
  final Animation<double> entrance;

  const LoginSignInPane({
    super.key,
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
    required this.isLoading,
    required this.obscurePassword,
    required this.onObscureToggle,
    required this.onLoginPressed,
    required this.onForgotPassword,
    required this.showFooter,
    required this.entrance,
  });

  @override
  Widget build(BuildContext context) {
    final t = L10n.of(context);
    return SafeArea(
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
              child: LoginLanguageSwitcher(),
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
                      EntranceFade(
                        animation: entrance,
                        interval: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
                        child: const InstitutionLogos(),
                      ),
                      const SizedBox(height: 52.0),
                      EntranceFade(
                        animation: entrance,
                        interval: const Interval(0.15, 0.7, curve: Curves.easeOutCubic),
                        child: Column(
                          children: [
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 40.0),
                      EntranceFade(
                        animation: entrance,
                        interval: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
                        child: LoginForm(
                          formKey: formKey,
                          usernameController: usernameController,
                          passwordController: passwordController,
                          isLoading: isLoading,
                          obscurePassword: obscurePassword,
                          onObscureToggle: onObscureToggle,
                          onLoginPressed: onLoginPressed,
                          onForgotPassword: onForgotPassword,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (showFooter) const PoweredByFooter(),
        ],
      ),
    );
  }
}
