import 'package:flutter/material.dart';

/// Shared color utilities used across all screens.
class AppColors {
  AppColors._();

  /// Deterministic avatar palette — same 10 colors used everywhere.
  static const List<Color> avatarPalette = [
    Color(0xFF0D6E6E),
    Color(0xFF4DB6AC),
    Color(0xFFFF8A65),
    Color(0xFF7986CB),
    Color(0xFFE57373),
    Color(0xFF4FC3F7),
    Color(0xFFAED581),
    Color(0xFFBA68C8),
    Color(0xFFFFD54F),
    Color(0xFF90A4AE),
  ];

  /// Returns a deterministic color based on the contact's ID.
  static Color avatarColor(int id) {
    return avatarPalette[id % avatarPalette.length];
  }
}
