import 'package:flutter/material.dart';

import '../../core/theme/pulse_theme.dart';
import 'pulse_amount.dart';

/// A single row in any list of money movements.
///
/// Takes primitives rather than a domain model so it stays usable for
/// transactions, transfers and category breakdowns alike.
class PulseTransactionTile extends StatelessWidget {
  const PulseTransactionTile({
    super.key,
    required this.title,
    required this.amount,
    this.subtitle,
    this.icon = Icons.swap_horiz_rounded,
    this.trailingCaption,
    this.onTap,
    this.iconTone = PulseTransactionIconTone.accentSoft,
    this.showSign = true,
    this.highlightIncome = true,
    this.currencySymbol = r'$',
    this.decimalDigits = 2,
  });

  final String title;
  final num amount;
  final String? subtitle;
  final IconData icon;

  /// Small text under the amount — a time, a status.
  final String? trailingCaption;

  final VoidCallback? onTap;
  final PulseTransactionIconTone iconTone;

  /// When true the amount is prefixed with `+`/`-` based on its own sign.
  final bool showSign;

  /// Tints incoming money with the positive role.
  ///
  /// Outflows deliberately stay neutral — in a spending list almost every row
  /// is negative, so colouring them all would be noise rather than signal.
  final bool highlightIncome;

  final String currencySymbol;

  /// Pass 0 for whole-unit currencies so round amounts don't carry a noisy
  /// `.00` down the whole list.
  final int decimalDigits;

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;

    final (Color iconBackground, Color iconForeground) = switch (iconTone) {
      PulseTransactionIconTone.accentSoft => (
        colors.accentSoft,
        colors.accentMuted,
      ),
      PulseTransactionIconTone.accent => (colors.accent, colors.onAccent),
      PulseTransactionIconTone.muted => (
        colors.surfaceMuted,
        colors.textSecondary,
      ),
      PulseTransactionIconTone.inverse => (
        colors.surfaceInverse,
        colors.onInverse,
      ),
    };

    final row = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PulseSpacing.lg,
        vertical: PulseSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: PulseRadii.iconRadius,
            ),
            child: Icon(icon, size: 20, color: iconForeground),
          ),
          const SizedBox(width: PulseSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: PulseTypography.titleSm.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: PulseSpacing.xxs),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: PulseTypography.metadata.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: PulseSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              PulseAmount(
                value: amount,
                size: PulseAmountSize.sm,
                currencySymbol: currencySymbol,
                decimalDigits: decimalDigits,
                sign: showSign
                    ? PulseAmountSign.signed
                    : PulseAmountSign.none,
                color: highlightIncome && amount > 0
                    ? colors.positive
                    : colors.textPrimary,
              ),
              if (trailingCaption != null) ...[
                const SizedBox(height: PulseSpacing.xxs),
                Text(
                  trailingCaption!,
                  style: PulseTypography.caption.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );

    if (onTap == null) return row;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: PulseRadii.iconRadius,
        child: row,
      ),
    );
  }
}

enum PulseTransactionIconTone { accentSoft, accent, muted, inverse }
