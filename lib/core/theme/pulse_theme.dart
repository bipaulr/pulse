import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'pulse_colors.dart';
import 'pulse_radii.dart';
import 'pulse_spacing.dart';
import 'pulse_typography.dart';

export 'pulse_colors.dart';
export 'pulse_motion.dart';
export 'pulse_radii.dart';
export 'pulse_shadows.dart';
export 'pulse_shapes.dart';
export 'pulse_spacing.dart';
export 'pulse_typography.dart';

/// Convenient access to Pulse design tokens from a [BuildContext].
extension PulseThemeContext on BuildContext {
  /// Semantic Pulse colours for the active theme.
  ///
  /// Falls back to the light palette if the extension is missing, so widgets
  /// can still be dropped into a bare `MaterialApp` in tests.
  PulseColors get pulseColors =>
      Theme.of(this).extension<PulseColors>() ?? PulseColors.light;

  TextTheme get pulseText => Theme.of(this).textTheme;
}

/// Builds the Pulse [ThemeData].
///
/// Only [light] exists today. A dark palette is added by defining a
/// `PulseColors.dark` and calling [_build] with it — no widget changes needed,
/// because components resolve everything through [PulseThemeContext].
abstract final class PulseTheme {
  static ThemeData get light => _build(PulseColors.light, Brightness.light);

  static ThemeData _build(PulseColors colors, Brightness brightness) {
    final textTheme = PulseTypography.textTheme(
      primary: colors.textPrimary,
      secondary: colors.textSecondary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      extensions: [colors],
      scaffoldBackgroundColor: colors.background,
      canvasColor: colors.background,
      splashFactory: InkRipple.splashFactory,
      textTheme: textTheme,
      fontFamily: PulseTypography.fontFamily,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.accent,
        onPrimary: colors.onAccent,
        secondary: colors.textPrimary,
        onSecondary: colors.onInverse,
        tertiary: colors.accentAlt,
        onTertiary: colors.textPrimary,
        error: colors.negative,
        onError: colors.surface,
        surface: colors.surface,
        onSurface: colors.textPrimary,
        surfaceContainerLowest: colors.surface,
        surfaceContainer: colors.surfaceMuted,
        surfaceContainerHighest: colors.surfaceMuted,
        onSurfaceVariant: colors.textSecondary,
        outline: colors.border,
        outlineVariant: colors.border,
        inverseSurface: colors.surfaceInverse,
        onInverseSurface: colors.onInverse,
        shadow: colors.shadow,
      ),

      // Material's stock chrome is turned off rather than restyled where the
      // Pulse equivalent is a bespoke widget.
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: PulseTypography.headingLg.copyWith(
          color: colors.textPrimary,
        ),
        systemOverlayStyle: brightness == Brightness.light
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
      ),

      cardTheme: CardThemeData(
        color: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
          borderRadius: PulseRadii.cardRadius,
        ),
      ),

      dividerTheme: DividerThemeData(
        color: colors.border,
        thickness: 1,
        space: PulseSpacing.lg,
      ),

      // Stock buttons should never appear, but if one slips through it will at
      // least be pill-shaped and on-brand rather than obviously Material.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.accent,
          foregroundColor: colors.onAccent,
          elevation: 0,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: PulseSpacing.xxl),
          textStyle: PulseTypography.label,
          shape: const RoundedRectangleBorder(
            borderRadius: PulseRadii.buttonRadius,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.textPrimary,
          textStyle: PulseTypography.label,
          shape: const RoundedRectangleBorder(
            borderRadius: PulseRadii.buttonRadius,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.textPrimary,
          minimumSize: const Size(0, 52),
          side: BorderSide(color: colors.border),
          textStyle: PulseTypography.label,
          shape: const RoundedRectangleBorder(
            borderRadius: PulseRadii.buttonRadius,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: PulseSpacing.lg,
          vertical: PulseSpacing.lg,
        ),
        hintStyle: PulseTypography.bodyLg.copyWith(color: colors.textSecondary),
        labelStyle: PulseTypography.metadata.copyWith(
          color: colors.textSecondary,
        ),
        border: const OutlineInputBorder(
          borderRadius: PulseRadii.inputRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: PulseRadii.inputRadius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: PulseRadii.inputRadius,
          borderSide: BorderSide(color: colors.textPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: PulseRadii.inputRadius,
          borderSide: BorderSide(color: colors.negative),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(PulseRadii.cardLarge),
          ),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.surfaceInverse,
        contentTextStyle: PulseTypography.bodyLg.copyWith(
          color: colors.onInverse,
        ),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: PulseRadii.buttonRadius,
        ),
      ),

      // The app uses PulseBottomNavigation; disable the Material one entirely.
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
