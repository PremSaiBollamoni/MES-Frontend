import 'package:flutter/material.dart';
import '../components/entrance_fade.dart';
import '../components/typewriter_text.dart';
import '../l10n/app_localizations.dart';
import '../utils/theme_tokens.dart';

/// The dark "ink" panel shown alongside the sign-in form on wide (desktop/tablet) windows -
/// on a phone-width screen the form fills the whole screen instead and this is never built.
/// Flat and restrained (a wordmark, an accent rule, one line of copy) rather than a gradient
/// or illustration, matching the rest of the app's steel-and-teal, editorial-luxury language -
/// this replaces empty grey space with weight, not with decoration. Its entrance is staggered
/// off the same shared animation as the sign-in form beside it, so both halves settle in as
/// one coordinated moment rather than two screens that happen to share a frame.
class LoginBrandPanel extends StatelessWidget {
  final Animation<double> entrance;

  const LoginBrandPanel({super.key, required this.entrance});

  @override
  Widget build(BuildContext context) {
    final t = L10n.of(context);
    return Container(
      color: ThemeTokens.ink,
      padding: const EdgeInsets.symmetric(horizontal: 56.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EntranceFade(
            animation: entrance,
            interval: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
            child: Container(width: 44, height: 3, color: ThemeTokens.accentLight),
          ),
          const SizedBox(height: 28.0),
          TypewriterText(
            text: "GTMES",
            style: ThemeTokens.headingDisplay.copyWith(fontSize: 52, color: ThemeTokens.onInk, letterSpacing: -1),
            animation: entrance,
            interval: const Interval(0.05, 0.55, curve: Curves.linear),
          ),
          const SizedBox(height: 16.0),
          EntranceFade(
            animation: entrance,
            interval: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
            child: Text(
              t.loginBrandTagline,
              style: ThemeTokens.bodyLarge.copyWith(color: ThemeTokens.onInk, fontSize: 17, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 12.0),
          EntranceFade(
            animation: entrance,
            interval: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
            child: Text(
              t.loginBrandSubtagline,
              style: ThemeTokens.bodyMedium.copyWith(color: ThemeTokens.textMuted, fontSize: 14),
            ),
          ),
          const SizedBox(height: 64.0),
          EntranceFade(
            animation: entrance,
            interval: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 1, color: ThemeTokens.inkDivider),
                const SizedBox(height: 24.0),
                Text(
                  t.institutions,
                  style: ThemeTokens.caption.copyWith(color: ThemeTokens.textMuted, fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
