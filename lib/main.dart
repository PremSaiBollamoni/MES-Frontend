import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'activities/splash_screen.dart';
import 'utils/theme_tokens.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MES',
      debugShowCheckedModeBanner: false,
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
  }
}
