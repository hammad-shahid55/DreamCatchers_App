import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color primary = Color(0xFF3693E9);
  static const Color gradientStart = Color(0xFF2D92D3);
  static const Color gradientEnd = Color(0xFF44CBF1);

  static const Color background = Color(0xFFFFFFFF);

  static const Color surface = Color(0xFFF7F8FA);
  static const Color border = Color(0xFFE3E3E3);
  static const Color divider = Color(0xFFECECEC);

  static const Color progressTrack = Color(0xFFECECEC);
  static const Color tileHint = Color(0xFFC1C1C1);
  static const Color navInactive = Color(0xFFBEBEBE);

  static const Color textDark = Color(0xFF282828);

  static const Color textPrimary = Color(0xFF000000);
  static const Color textBody = Color(0xFF4E4E4E);
  static const Color textSecondary = Color(0xFF7A7A7A);
  static const Color textHint = Color(0xFFB3B3B3);
  static const Color textOnPrimary = Colors.white;

  static const Color error = Color(0xFFFD2D55);

  static const Color emphasis = Color(0xFFFF0000);
  static const Color success = Color(0xFF2EAE60);
  static const Color mediaBackground = Color(0xFF15121A);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [gradientStart, gradientEnd],
  );

  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, 2)),
  ];

  static const List<Color> avatarPalette = [
    Color(0xFF3693E9),
    Color(0xFF2D92D3),
    Color(0xFF6C5CE7),
    Color(0xFF00897B),
    Color(0xFFE5322D),
    Color(0xFFF2994A),
    Color(0xFF8E44AD),
    Color(0xFF27AE60),
  ];
}
