import 'package:flutter/material.dart';

const Map<String, Color> kLanguageColors = {
  'TypeScript': Color(0xFF3178C6),
  'JavaScript': Color(0xFFF1E05A),
  'Python': Color(0xFF3572A5),
  'Dart': Color(0xFF00B4AB),
  'Go': Color(0xFF00ADD8),
  'Rust': Color(0xFFDEA584),
  'Ruby': Color(0xFF701516),
  'Java': Color(0xFFB07219),
  'C++': Color(0xFFF34B7D),
  'Swift': Color(0xFFF05138),
  'Kotlin': Color(0xFFA97BFF),
  'Shell': Color(0xFF89E051),
};

Color languageColor(String language) =>
    kLanguageColors[language] ?? const Color(0xFF9AA4B8);
