import 'package:flutter/material.dart';

import '../../core/theme/pulse_theme.dart';
import 'pulse_button.dart';

/// Shown when something failed to load.
///
/// Structurally a sibling of `PulseEmptyState`, but tinted with the negative
/// role and always offering a way forward.
class PulseErrorState extends StatelessWidget {
  const PulseErrorState({
    super.key,
    this.title = 'Something went wrong',
    this.message = 'We could not load this right now. Please try again.',
    this.icon = Icons.error_outline_rounded,
    this.onRetry,
    this.retryLabel = 'Try again',
    this.compact = false,
  });

  final String title;
  final String? message;
  final IconData icon;
  final VoidCallback? onRetry;
  final String retryLabel;

  /// Tightens the vertical rhythm for use inside a card.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: PulseSpacing.xxl,
        vertical: compact ? PulseSpacing.xxl : PulseSpacing.huge,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: compact ? 56 : 72,
            width: compact ? 56 : 72,
            decoration: BoxDecoration(
              color: colors.negative.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: compact ? 24 : 30, color: colors.negative),
          ),
          SizedBox(height: compact ? PulseSpacing.lg : PulseSpacing.xl),
          Text(
            title,
            textAlign: TextAlign.center,
            style: PulseTypography.headingMd.copyWith(
              color: colors.textPrimary,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: PulseSpacing.sm),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: PulseTypography.bodyMd.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: PulseSpacing.xl),
            PulseButton(
              label: retryLabel,
              onPressed: onRetry,
              variant: PulseButtonVariant.dark,
              size: PulseButtonSize.small,
              icon: Icons.refresh_rounded,
            ),
          ],
        ],
      ),
    );
  }
}
