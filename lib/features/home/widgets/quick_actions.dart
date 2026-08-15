import 'package:flutter/material.dart';

import '../../../core/theme/pulse_theme.dart';

/// One of the four shortcuts under the card.
@immutable
class QuickAction {
  const QuickAction({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
}

/// A compact row of shortcuts.
///
/// Four evenly-shared columns rather than four buttons: the icon well stays
/// small, and the whole column — icon plus label — is the touch target, which
/// keeps it comfortably over 48dp without any large chrome.
class QuickActions extends StatelessWidget {
  const QuickActions({super.key, required this.actions});

  final List<QuickAction> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PulseSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final action in actions)
            Expanded(child: _QuickActionButton(action: action)),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatefulWidget {
  const _QuickActionButton({required this.action});

  final QuickAction action;

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;
    final action = widget.action;

    return Semantics(
      button: true,
      label: action.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: action.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1,
          duration: PulseMotion.fast,
          curve: PulseMotion.curve,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: PulseSpacing.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: PulseMotion.fast,
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: _pressed ? colors.accent : colors.surfaceMuted,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    action.icon,
                    size: 22,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: PulseSpacing.sm),
                Text(
                  action.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: PulseTypography.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
