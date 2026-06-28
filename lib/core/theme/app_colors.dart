import 'package:flutter/material.dart';

class AppColors {
  // Light — GitHub Primer Light
  static const Color _lightBg = Color(0xFFFFFFFF);
  static const Color _lightSurface = Color(0xFFF6F8FA);
  static const Color _lightBorder = Color(0xFFD0D7DE);
  static const Color _lightText = Color(0xFF1F2328);
  static const Color _lightSecondary = Color(0xFF59636E);
  static const Color _lightMuted = Color(0xFF818B98);
  static const Color _lightAccent = Color(0xFF0969DA);
  static const Color _lightBtn = Color(0xFF1F883D);
  static const Color _lightSuccess = Color(0xFF1A7F37);
  static const Color _lightWarning = Color(0xFF9A6700);
  static const Color _lightDanger = Color(0xFFCF222E);
  static const Color _lightDot = Color(0x1A0969DA);

  // Dark — GitHub Primer Dark
  static const Color _darkBg = Color(0xFF0D1117);
  static const Color _darkSurface = Color(0xFF161B22);
  static const Color _darkElevated = Color(0xFF1C2128);
  static const Color _darkBorder = Color(0xFF30363D);
  static const Color _darkText = Color(0xFFE6EDF3);
  static const Color _darkSecondary = Color(0xFF7D8590);
  static const Color _darkMuted = Color(0xFF6E7681);
  static const Color _darkAccent = Color(0xFF2F81F7);
  static const Color _darkBtn = Color(0xFF238636);
  static const Color _darkSuccess = Color(0xFF3FB950);
  static const Color _darkWarning = Color(0xFFD29922);
  static const Color _darkDanger = Color(0xFFF85149);
  static const Color _darkDot = Color(0x1F2F81F7);

  static Color bg(bool isDark) => isDark ? _darkBg : _lightBg;
  static Color surface(bool isDark) => isDark ? _darkSurface : _lightSurface;
  static Color elevated(bool isDark) => isDark ? _darkElevated : _lightSurface;
  static Color border(bool isDark) => isDark ? _darkBorder : _lightBorder;
  static Color text(bool isDark) => isDark ? _darkText : _lightText;
  static Color secondary(bool isDark) => isDark ? _darkSecondary : _lightSecondary;
  static Color muted(bool isDark) => isDark ? _darkMuted : _lightMuted;
  static Color accent(bool isDark) => isDark ? _darkAccent : _lightAccent;
  static Color btn(bool isDark) => isDark ? _darkBtn : _lightBtn;
  static Color success(bool isDark) => isDark ? _darkSuccess : _lightSuccess;
  static Color warning(bool isDark) => isDark ? _darkWarning : _lightWarning;
  static Color danger(bool isDark) => isDark ? _darkDanger : _lightDanger;
  static Color dot(bool isDark) => isDark ? _darkDot : _lightDot;
}
