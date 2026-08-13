import 'package:flutter/widgets.dart';

/// Pulse elevation.
///
/// Shadows are used sparingly and kept very soft — the design separates
/// surfaces with colour and radius first, shadow second. There is no "high
/// elevation" token on purpose.
abstract final class PulseShadows {
  /// Barely-there lift for tiles and quiet cards.
  static List<BoxShadow> soft(Color base) => [
    BoxShadow(
      color: base.withValues(alpha: 0.04),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  /// Hero cards that need to read as floating above the canvas.
  static List<BoxShadow> lifted(Color base) => [
    BoxShadow(
      color: base.withValues(alpha: 0.07),
      blurRadius: 28,
      offset: const Offset(0, 12),
      spreadRadius: -6,
    ),
  ];

  /// The floating bottom navigation bar.
  static List<BoxShadow> navigation(Color base) => [
    BoxShadow(
      color: base.withValues(alpha: 0.14),
      blurRadius: 30,
      offset: const Offset(0, 10),
      spreadRadius: -8,
    ),
  ];

  static const List<BoxShadow> none = <BoxShadow>[];
}
