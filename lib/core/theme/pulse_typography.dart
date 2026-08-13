import 'package:flutter/material.dart';

/// Pulse type scale.
///
/// The hierarchy is deliberately wide: financial amounts are very large and
/// tightly tracked, metadata is small and quiet, and there is little in
/// between. That contrast is what makes the screens read as premium rather
/// than dense.
///
/// Colour is intentionally left `null` here — it is applied by the theme so
/// the same scale can serve a future dark palette.
@immutable
class PulseTypography {
  const PulseTypography._();

  /// Swap this for a bundled face later; `null` uses the platform UI font,
  /// which is already a close match for the geometric grotesque Pulse wants.
  static const String? fontFamily = null;

  // ---------------------------------------------------------------- amounts
  // Financial figures get their own scale. Heavy weight, negative tracking,
  // near-1.0 line height so the numerals feel like a single object.

  /// Hero balance / total spending. The single loudest thing on a screen.
  static const amountXl = TextStyle(
    fontFamily: fontFamily,
    fontSize: 44,
    fontWeight: FontWeight.w700,
    height: 1.05,
    letterSpacing: -1.6,
  );

  /// Card balances, section totals.
  static const amountLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -1.0,
  );

  /// Summary tiles (income / expense pills).
  static const amountMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.5,
  );

  /// Inline amounts in transaction rows.
  static const amountSm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.2,
  );

  // --------------------------------------------------------------- headings

  /// Greeting / page hero ("Welcome Back!").
  static const displayLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.8,
  );

  /// App bar titles.
  static const headingLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.4,
  );

  /// Section headers ("All Transactions", "Categories").
  static const headingMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 19,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.3,
  );

  /// Titles inside cards and list rows.
  static const titleSm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.1,
  );

  // ------------------------------------------------------------------- body

  static const bodyLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.45,
  );

  static const bodyMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  // --------------------------------------------------------------- supporting

  /// Row subtitles, timestamps, "Sent" / "Payment".
  static const metadata = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  /// Field labels on cards ("Holder", "Exp Date"), axis ticks.
  static const caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.2,
  );

  /// Button and chip text.
  static const label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.1,
  );

  static const labelSm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  /// Maps the Pulse scale onto Material's [TextTheme] so stock widgets that
  /// resolve typography from the theme still look like Pulse.
  static TextTheme textTheme({
    required Color primary,
    required Color secondary,
  }) {
    return TextTheme(
      displayLarge: amountXl.copyWith(color: primary),
      displayMedium: amountLg.copyWith(color: primary),
      displaySmall: displayLg.copyWith(color: primary),
      headlineLarge: displayLg.copyWith(color: primary),
      headlineMedium: headingLg.copyWith(color: primary),
      headlineSmall: headingMd.copyWith(color: primary),
      titleLarge: headingMd.copyWith(color: primary),
      titleMedium: titleSm.copyWith(color: primary),
      titleSmall: label.copyWith(color: primary),
      bodyLarge: bodyLg.copyWith(color: primary),
      bodyMedium: bodyMd.copyWith(color: secondary),
      bodySmall: metadata.copyWith(color: secondary),
      labelLarge: label.copyWith(color: primary),
      labelMedium: labelSm.copyWith(color: secondary),
      labelSmall: caption.copyWith(color: secondary),
    );
  }
}
