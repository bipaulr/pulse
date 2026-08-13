/// Pulse spacing scale — a 4pt grid.
///
/// Use these instead of literal numbers so density can be tuned globally.
abstract final class PulseSpacing {
  static const double none = 0;
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;

  /// Standard horizontal inset for full-width screen content.
  static const double screenGutter = 20;

  /// Vertical rhythm between two major sections of a screen.
  static const double sectionGap = 28;

  /// Space to leave at the bottom of scroll views so content clears the
  /// floating bottom navigation.
  static const double bottomNavClearance = 108;
}
