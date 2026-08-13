import 'package:flutter/widgets.dart';

/// Corner radii for Pulse. Generously rounded — it is a core part of the look.
abstract final class PulseRadii {
  /// Standard content card.
  static const double card = 28;

  /// Large hero surfaces (payment cards, chart panels).
  static const double cardLarge = 32;

  static const double button = 20;

  /// Chips and pills are fully rounded.
  static const double chip = 999;

  static const double input = 18;

  /// The floating bottom navigation bar.
  static const double navigation = 30;

  /// Small square-ish elements: avatars, icon wells, list leading tiles.
  static const double icon = 16;

  /// Concave "notch" carved out of a card corner — a Pulse signature detail.
  static const double notch = 22;

  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(card));
  static const BorderRadius cardLargeRadius = BorderRadius.all(
    Radius.circular(cardLarge),
  );
  static const BorderRadius buttonRadius = BorderRadius.all(
    Radius.circular(button),
  );
  static const BorderRadius chipRadius = BorderRadius.all(
    Radius.circular(chip),
  );
  static const BorderRadius inputRadius = BorderRadius.all(
    Radius.circular(input),
  );
  static const BorderRadius navigationRadius = BorderRadius.all(
    Radius.circular(navigation),
  );
  static const BorderRadius iconRadius = BorderRadius.all(
    Radius.circular(icon),
  );
}
