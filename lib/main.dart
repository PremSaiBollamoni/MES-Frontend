import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'activities/splash_screen.dart';
import 'l10n/app_localizations.dart';
import 'utils/locale_controller.dart';
import 'utils/theme_tokens.dart';

Future<void> main() async {
  // Restore the saved language before the first frame, so the app never flashes
  // English on launch for someone who chose Telugu.
  WidgetsFlutterBinding.ensureInitialized();
  await LocaleController().load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuilding only MaterialApp on a language change is enough - every screen
    // below re-reads its strings from the new locale automatically.
    return ValueListenableBuilder<Locale>(
      valueListenable: LocaleController().locale,
      builder: (context, locale, _) {
        return MaterialApp(
          title: 'MES',
          debugShowCheckedModeBanner: false,
          locale: locale,
          supportedLocales: LocaleController.supported,
          localizationsDelegates: const [
            L10n.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: ThemeTokens.background,
            colorScheme: ColorScheme.fromSeed(
              seedColor: ThemeTokens.primary,
              brightness: Brightness.light,
              primary: ThemeTokens.primary,
              secondary: ThemeTokens.accent,
              surface: ThemeTokens.surfaceSolid,
              error: ThemeTokens.error,
            ),
            textTheme: GoogleFonts.manropeTextTheme(),
            appBarTheme: const AppBarTheme(
              iconTheme: IconThemeData(color: ThemeTokens.textPrimary),
              backgroundColor: ThemeTokens.background,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
            ),
            dividerTheme: const DividerThemeData(color: ThemeTokens.hairline, space: 1),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
