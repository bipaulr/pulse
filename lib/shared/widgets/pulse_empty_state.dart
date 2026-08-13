import 'package:flutter/material.dart';

import '../../core/theme/pulse_theme.dart';
import 'pulse_button.dart';

/// Shown when a list or screen has nothing to display yet.
class PulseEmptyState extends StatelessWidget {
  const PulseEmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_rounded,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  final String title;
  final String? message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: compact ? 56 : 72,
            width: compact ? 56 : 72,
            decoration: BoxDecoration(
              color: colors.accentSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: compact ? 24 : 30,
              color: colors.accentMuted,
            ),
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
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: PulseSpacing.xl),
            PulseButton(
              label: actionLabel!,
              onPressed: onAction,
              size: PulseButtonSize.small,
            ),
          ],
        ],
      ),
    );
  }
}
