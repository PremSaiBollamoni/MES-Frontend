import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../components/app_button.dart';
import '../services/api_service.dart';
import '../services/auth_session.dart';
import '../components/custom_toast.dart';
import '../utils/theme_tokens.dart';
import 'login_screen.dart';
import 'main_shell_screen.dart';

/// Flat, plain splash - no ambient glow orbs, no gradient logo. A small solid
/// mark, a heading, a thin progress line. Nothing decorative.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isConnecting = true;
  String? _errorMessage;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _performConnectionCheck();
  }

  Future<void> _performConnectionCheck() async {
    setState(() {
      _isConnecting = true;
      _errorMessage = null;
    });

    final String? connectionUrl = await _apiService.checkBackendHealth();

    if (!mounted) return;

    if (connectionUrl != null) {
      final restoredUser = await AuthSession().restore();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => restoredUser != null ? MainShellScreen(user: restoredUser) : const LoginScreen(),
          ),
        );
      }
    } else {
      setState(() {
        _isConnecting = false;
        _errorMessage = L10n.of(context).splashUnableToConnect(_apiService.baseUrl);
      });
      CustomToast.show(context, L10n.of(context).splashOffline, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(color: ThemeTokens.primary, borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium)),
                alignment: Alignment.center,
                child: const Icon(Icons.checkroom_rounded, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 24.0),
              Text("MES", style: ThemeTokens.headingDisplay.copyWith(fontSize: 26)),
              const SizedBox(height: 6.0),
              Text(L10n.of(context).appTagline, style: ThemeTokens.bodyMedium),
              const SizedBox(height: 40.0),
              if (_isConnecting)
                SizedBox(
                  width: 120,
                  child: LinearProgressIndicator(
                    minHeight: 2,
                    backgroundColor: ThemeTokens.hairline,
                    valueColor: const AlwaysStoppedAnimation<Color>(ThemeTokens.primary),
                  ),
                )
              else ...[
                Icon(Icons.wifi_off_rounded, color: ThemeTokens.error, size: 24),
                const SizedBox(height: 10.0),
                Text(
                  _errorMessage ?? L10n.of(context).connectionOffline,
                  style: ThemeTokens.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20.0),
                SizedBox(
                  width: 180,
                  child: AppPrimaryButton(label: L10n.of(context).retry, onPressed: _performConnectionCheck),
                ),
              ],
            ],
            ),
          ),
        ),
      ),
    );
  }
}
