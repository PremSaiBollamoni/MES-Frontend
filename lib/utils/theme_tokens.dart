import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// WHATSAPP GREEN design language (locked direction).
///
/// Pure white canvas, neutral graphite ink, WhatsApp's own green accent. Fraunces
/// (old-style display serif) for headings paired with Manrope for body/data.
/// Restraint, deliberate whitespace, hairline structure, slow subtle motion.
class ThemeTokens {
  // Canvas - pure white, with cards separated by hairline border + shadow
  // rather than a tinted background.
  static const Color background = Color(0xFFFFFFFF);
  static const Color surfaceSolid = Color(0xFFFFFFFF);
  static const Color surfaceSunken = Color(0xFFECE5DD);
  static const Color surfaceRaised = Color(0xFFFFFFFF);

  // Ink - neutral cool grey, not warm-tinted.
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFFD1D5DB);
  static const Color textMono = Color(0xFF128C7E);

  // WhatsApp's own green - primary is their signature bright action green,
  // dark is their classic dark-teal-green header color.
  static const Color primary = Color(0xFF25D366);
  static const Color primaryDark = Color(0xFF075E54);
  static const Color accent = Color(0xFF25D366);
  // WhatsApp's light chat-bubble mint - used as bright text/numbers on the dark
  // ink surfaces below, where a dark accent would have no contrast at all.
  static const Color accentLight = Color(0xFFDCF8C6);

  // WhatsApp's dark header green for solid dark surfaces (drawer header, hero cards).
  static const Color ink = Color(0xFF054640);
  static const Color inkSoft = Color(0xFF0B3D38);
  // Light text + dividers that sit on top of the dark ink surfaces.
  static const Color onInk = Color(0xFFEDEFF1);
  static const Color inkDivider = Color(0xFF14514A);

  // Hairlines carry structure; leans on rules + whitespace, not shadow.
  static const Color hairline = Color(0xFFE5E7EB);
  static const Color hairlineStrong = Color(0xFF1F2937);
  static const Color glassBorder = hairline;
  static const Color glassBorderActive = primary;
  static const Color gridLine = Color(0x0A1F2937);

  static const Color success = Color(0xFF2E7D5B);
  static const Color error = Color(0xFFC43D2E);
  static const Color warning = Color(0xFFC77A1E);

  // Restrained radii - luxury is neither playful-pill nor brutalist-sharp.
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 18.0;
  static const double radiusPill = 999.0;

  static List<BoxShadow> get glowShadow => [
        BoxShadow(color: ink.withValues(alpha: 0.10), blurRadius: 40, offset: const Offset(0, 20)),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(color: ink.withValues(alpha: 0.05), blurRadius: 30, offset: const Offset(0, 12)),
      ];

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient accentGradient = primaryGradient;
  static const LinearGradient lightBackgroundGradient = LinearGradient(
    colors: [background, background],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Display type - Fraunces, an old-style serif with soft/optical character.
  // Heavier weights + tight tracking read editorial-luxury.
  static TextStyle get headingDisplay =>
      GoogleFonts.fraunces(fontSize: 34, fontWeight: FontWeight.w600, color: textPrimary, letterSpacing: -0.5, height: 1.05);
  static TextStyle get headingLarge =>
      GoogleFonts.fraunces(fontSize: 25, fontWeight: FontWeight.w600, color: textPrimary, letterSpacing: -0.3, height: 1.1);
  static TextStyle get headingMedium =>
      GoogleFonts.fraunces(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary, letterSpacing: -0.2);

  // Body type - Manrope, a clean grotesque that stays legible in dense tables.
  static TextStyle get bodyLarge => GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary, height: 1.5);
  static TextStyle get bodyMedium => GoogleFonts.manrope(fontSize: 13.5, fontWeight: FontWeight.w500, color: textSecondary, height: 1.5);
  static TextStyle get subtitleSmall => GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w600, color: textLight);

  // Eyebrow / label - uppercase, tracked-out, tiny. A luxury signature.
  static TextStyle get labelSmall =>
      GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w700, color: textSecondary, letterSpacing: 1.4);
  static TextStyle get hintText => GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w500, color: textLight);
  static TextStyle get inputText => GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary);
  static TextStyle get buttonTextLarge => GoogleFonts.manrope(fontSize: 13.5, fontWeight: FontWeight.w700, letterSpacing: 0.6);
  static TextStyle get buttonText => GoogleFonts.manrope(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.8);
  static TextStyle get caption => GoogleFonts.manrope(fontSize: 11.5, fontWeight: FontWeight.w600, color: textLight);
  static TextStyle get footerCaption => GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w500, color: textMuted);
  static TextStyle get techMonoStyle => GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w700, color: textMono, letterSpacing: 0.4);

  static const double space2 = 2.0;
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
}
