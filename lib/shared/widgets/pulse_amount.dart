import 'package:flutter/material.dart';

import '../../core/theme/pulse_theme.dart';

/// How loud a [PulseAmount] should be.
enum PulseAmountSize {
  /// Hero figure — one per screen.
  xl,

  /// Card balances and section totals.
  lg,

  /// Summary tiles.
  md,

  /// Inline, e.g. a transaction row.
  sm,
}

/// How the sign is rendered.
enum PulseAmountSign {
  /// No sign, neutral colour. For balances and totals.
  none,

  /// Prefix `+` / `-` but keep the text colour neutral.
  signed,

  /// Prefix `+` / `-` and colour by direction (positive / negative).
  signedColoured,
}

/// Displays a monetary value with the prominence Pulse gives to money.
///
/// Formatting is deliberately minimal and dependency-free: grouped thousands
/// and two decimals. When real locale support is needed, this is the one place
/// that has to change.
class PulseAmount extends StatelessWidget {
  const PulseAmount({
    super.key,
    required this.value,
    this.size = PulseAmountSize.md,
    this.currencySymbol = r'$',
    this.sign = PulseAmountSign.none,
    this.color,
    this.decimalDigits = 2,
    this.textAlign,
  });

  final num value;
  final PulseAmountSize size;
  final String currencySymbol;
  final PulseAmountSign sign;

  /// Overrides the colour that [sign] and the theme would otherwise pick.
  final Color? color;

  final int decimalDigits;
  final TextAlign? textAlign;

  TextStyle get _style => switch (size) {
    PulseAmountSize.xl => PulseTypography.amountXl,
    PulseAmountSize.lg => PulseTypography.amountLg,
    PulseAmountSize.md => PulseTypography.amountMd,
    PulseAmountSize.sm => PulseTypography.amountSm,
  };

  /// `1376.9` -> `1,376.90`
  static String formatMagnitude(num value, int decimalDigits) {
    final text = value.abs().toStringAsFixed(decimalDigits);
    final parts = text.split('.');
    final digits = parts.first;

    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }

    return parts.length > 1 ? '$buffer.${parts[1]}' : buffer.toString();
  }

  String get formatted {
    final prefix = switch (sign) {
      PulseAmountSign.none => '',
      _ => value < 0 ? '- ' : '+ ',
    };
    return '$prefix$currencySymbol${formatMagnitude(value, decimalDigits)}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;

    final resolved =
        color ??
        switch (sign) {
          PulseAmountSign.signedColoured =>
            value < 0 ? colors.negative : colors.positive,
          _ => DefaultTextStyle.of(context).style.color ?? colors.textPrimary,
        };

    return Text(
      formatted,
      textAlign: textAlign,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: _style.copyWith(color: resolved),
      semanticsLabel: '$currencySymbol${formatMagnitude(value, decimalDigits)}',
    );
  }
}
