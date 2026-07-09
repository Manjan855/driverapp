import 'package:flutter/material.dart';

/// Three-typeface system: Space Grotesk for display/numbers (the
/// "instrument" feel), Inter for body/labels, JetBrains Mono for
/// data — timestamps, plate numbers, route codes.
class AppTypography {
  static const String displayFont = 'SpaceGrotesk';
  static const String bodyFont = 'Inter';
  static const String monoFont = 'JetBrainsMono';

  static TextStyle display({required Color color, double size = 28}) {
    return TextStyle(
      fontFamily: displayFont,
      fontSize: size,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: -0.3,
    );
  }

  static TextStyle heading({required Color color, double size = 18}) {
    return TextStyle(
      fontFamily: bodyFont,
      fontSize: size,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  static TextStyle body({required Color color, double size = 14}) {
    return TextStyle(
      fontFamily: bodyFont,
      fontSize: size,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }

  static TextStyle caption({required Color color, double size = 12}) {
    return TextStyle(
      fontFamily: bodyFont,
      fontSize: size,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }

  static TextStyle mono({required Color color, double size = 12}) {
    return TextStyle(
      fontFamily: monoFont,
      fontSize: size,
      fontWeight: FontWeight.w500,
      color: color,
      letterSpacing: 0.05,
    );
  }
}
