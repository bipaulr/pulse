import 'package:flutter/material.dart';

/// Raw Pulse brand values.
///
/// These are the only place literal colour values are allowed to live.
/// Everything in the app reads semantic roles from [PulseColors] instead, so a
/// dark palette can be introduced later without touching a single widget.
abstract final class PulseBrand {
  /// Warm, slightly green-tinted off-white. The canvas the whole app sits on.
  static const offWhite = Color(0xFFF4F4EE);

  /// Near-black used for primary text and solid dark controls.
  static const ink = Color(0xFF0E1013);

  /// Deep blue-black used for the large "spotlight" surfaces (charts, hero
  /// panels). Warmer and less absolute than [ink].
  static const inkSurface = Color(0xFF151A2B);

  /// The defining Pulse accent: electric lime / yellow-green.
  static const lime = Color(0xFFC7F04B);

  /// Pressed / hovered lime.
  static const limeDeep = Color(0xFFAFD934);

  /// Very light lime wash for tinted backgrounds and selected rows.
  static const limeSoft = Color(0xFFE6F7BE);

  /// Secondary accent — a warmer, more saturated yellow.
  static const citron = Color(0xFFF2E94B);

  /// Muted, earthy green for supporting states and secondary emphasis.
  static const green = Color(0xFF6E9B3F);

  static const white = Color(0xFFFFFFFF);

  /// Neutral tile fill — reads as "quiet surface" on the off-white canvas.
  static const stone = Color(0xFFEDEEE6);
  static const stoneDeep = Color(0xFFE3E4DA);

  static const warmGrey = Color(0xFF6B6F63);
  static const warmGreyLight = Color(0xFF9A9E92);

  static const positive = Color(0xFF4E9F3D);
  static const negative = Color(0xFFD9544D);
}

/// Semantic colour roles for Pulse, exposed as a [ThemeExtension].
///
/// Widgets should never reference [PulseBrand] directly — they read
/// `context.pulseColors`, which makes a future dark palette a one-file change.
@immutable
class PulseColors extends ThemeExtension<PulseColors> {
  const PulseColors({
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.surfaceInverse,
    required this.accent,
    required this.accentPressed,
    required this.accentSoft,
    required this.accentAlt,
    required this.accentMuted,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.onAccent,
    required this.onInverse,
    required this.positive,
    required this.negative,
    required this.border,
    required this.skeletonBase,
    required this.skeletonHighlight,
    required this.shadow,
  });

  /// Warm off-white app canvas.
  final Color background;

  /// White cards that need to sit above [background].
  final Color surface;

  /// Quiet neutral fill for tiles, inputs and icon buttons.
  final Color surfaceMuted;

  /// Dark hero surface (charts, feature panels).
  final Color surfaceInverse;

  /// Electric lime — the Pulse signature. Used strategically, not everywhere.
  final Color accent;
  final Color accentPressed;

  /// Light lime wash for tinted backgrounds.
  final Color accentSoft;

  /// Yellow secondary accent.
  final Color accentAlt;

  /// Muted green for supporting emphasis.
  final Color accentMuted;

  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  /// Text/icons drawn on top of [accent].
  final Color onAccent;

  /// Text/icons drawn on top of [surfaceInverse].
  final Color onInverse;

  final Color positive;
  final Color negative;

  final Color border;

  final Color skeletonBase;
  final Color skeletonHighlight;

  /// Base colour for the app's (deliberately subtle) shadows.
  final Color shadow;

  static const light = PulseColors(
    background: PulseBrand.offWhite,
    surface: PulseBrand.white,
    surfaceMuted: PulseBrand.stone,
    surfaceInverse: PulseBrand.inkSurface,
    accent: PulseBrand.lime,
    accentPressed: PulseBrand.limeDeep,
    accentSoft: PulseBrand.limeSoft,
    accentAlt: PulseBrand.citron,
    accentMuted: PulseBrand.green,
    textPrimary: PulseBrand.ink,
    textSecondary: PulseBrand.warmGrey,
    textTertiary: PulseBrand.warmGreyLight,
    onAccent: PulseBrand.ink,
    onInverse: PulseBrand.offWhite,
    positive: PulseBrand.positive,
    negative: PulseBrand.negative,
    border: PulseBrand.stoneDeep,
    skeletonBase: PulseBrand.stone,
    skeletonHighlight: PulseBrand.white,
    shadow: PulseBrand.ink,
  );

  @override
  PulseColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceMuted,
    Color? surfaceInverse,
    Color? accent,
    Color? accentPressed,
    Color? accentSoft,
    Color? accentAlt,
    Color? accentMuted,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? onAccent,
    Color? onInverse,
    Color? positive,
    Color? negative,
    Color? border,
    Color? skeletonBase,
    Color? skeletonHighlight,
    Color? shadow,
  }) {
    return PulseColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      surfaceInverse: surfaceInverse ?? this.surfaceInverse,
      accent: accent ?? this.accent,
      accentPressed: accentPressed ?? this.accentPressed,
      accentSoft: accentSoft ?? this.accentSoft,
      accentAlt: accentAlt ?? this.accentAlt,
      accentMuted: accentMuted ?? this.accentMuted,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      onAccent: onAccent ?? this.onAccent,
      onInverse: onInverse ?? this.onInverse,
      positive: positive ?? this.positive,
      negative: negative ?? this.negative,
      border: border ?? this.border,
      skeletonBase: skeletonBase ?? this.skeletonBase,
      skeletonHighlight: skeletonHighlight ?? this.skeletonHighlight,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  PulseColors lerp(covariant PulseColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return PulseColors(
      background: mix(background, other.background),
      surface: mix(surface, other.surface),
      surfaceMuted: mix(surfaceMuted, other.surfaceMuted),
      surfaceInverse: mix(surfaceInverse, other.surfaceInverse),
      accent: mix(accent, other.accent),
      accentPressed: mix(accentPressed, other.accentPressed),
      accentSoft: mix(accentSoft, other.accentSoft),
      accentAlt: mix(accentAlt, other.accentAlt),
      accentMuted: mix(accentMuted, other.accentMuted),
      textPrimary: mix(textPrimary, other.textPrimary),
      textSecondary: mix(textSecondary, other.textSecondary),
      textTertiary: mix(textTertiary, other.textTertiary),
      onAccent: mix(onAccent, other.onAccent),
      onInverse: mix(onInverse, other.onInverse),
      positive: mix(positive, other.positive),
      negative: mix(negative, other.negative),
      border: mix(border, other.border),
      skeletonBase: mix(skeletonBase, other.skeletonBase),
      skeletonHighlight: mix(skeletonHighlight, other.skeletonHighlight),
      shadow: mix(shadow, other.shadow),
    );
  }
}
