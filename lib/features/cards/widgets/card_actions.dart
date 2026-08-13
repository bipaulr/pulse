import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/pulse_theme.dart';
import '../../../shared/models/models.dart';
import '../../../shared/widgets/widgets.dart';
import '../data/cards_repository.dart';

/// The four card controls, plus the transient UI they own.
///
/// Freeze and View PIN carry real local state; Replace opens a confirmation
/// sheet; Settings is an acknowledged placeholder. None of them pretend to
/// reach a backend.
class CardActions extends ConsumerStatefulWidget {
  const CardActions({super.key, required this.card});

  final PaymentCard card;

  /// How long a revealed PIN stays on screen.
  static const pinVisibleFor = Duration(seconds: 5);

  @override
  ConsumerState<CardActions> createState() => _CardActionsState();
}

class _CardActionsState extends ConsumerState<CardActions> {
  String? _pin;
  int _secondsLeft = 0;
  Timer? _countdown;

  @override
  void didUpdateWidget(CardActions oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Never carry a revealed PIN across to a different card.
    if (widget.card.id != oldWidget.card.id) _hidePin();
  }

  @override
  void dispose() {
    _countdown?.cancel();
    super.dispose();
  }

  void _hidePin() {
    _countdown?.cancel();
    _countdown = null;
    if (_pin != null && mounted) setState(() => _pin = null);
  }

  Future<void> _togglePin() async {
    if (_pin != null) {
      _hidePin();
      return;
    }

    final pin = await ref
        .read(cardsRepositoryProvider)
        .revealPin(widget.card.id);
    if (!mounted) return;

    setState(() {
      _pin = pin;
      _secondsLeft = CardActions.pinVisibleFor.inSeconds;
    });

    _countdown?.cancel();
    _countdown = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft <= 1) {
        _hidePin();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  Future<void> _confirmReplace() async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) =>
          _ReplaceCardSheet(last4: widget.card.last4),
    );

    if (confirmed == true && mounted) {
      _notify('Card replacement isn\'t available yet');
    }
  }

  void _notify(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final frozen = ref.watch(
      frozenCardsProvider.select((ids) => ids.contains(widget.card.id)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PulseSectionHeader(title: 'Card Actions'),
        const SizedBox(height: PulseSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PulseSpacing.screenGutter,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _ActionTile(
                      icon: frozen
                          ? Icons.lock_open_rounded
                          : Icons.ac_unit_rounded,
                      label: frozen ? 'Unfreeze' : 'Freeze Card',
                      active: frozen,
                      onTap: () {
                        ref
                            .read(frozenCardsProvider.notifier)
                            .toggle(widget.card.id);
                        _notify(
                          frozen
                              ? 'Card unfrozen'
                              : 'Card frozen — payments are blocked',
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: PulseSpacing.sm),
                  Expanded(
                    child: _ActionTile(
                      icon: _pin == null
                          ? Icons.password_rounded
                          : Icons.visibility_off_rounded,
                      label: _pin == null ? 'View PIN' : 'Hide PIN',
                      active: _pin != null,
                      onTap: _togglePin,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: PulseSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _ActionTile(
                      icon: Icons.credit_card_rounded,
                      label: 'Replace Card',
                      onTap: _confirmReplace,
                    ),
                  ),
                  const SizedBox(width: PulseSpacing.sm),
                  Expanded(
                    child: _ActionTile(
                      icon: Icons.tune_rounded,
                      label: 'Card Settings',
                      onTap: () => _notify('Card settings are coming soon'),
                    ),
                  ),
                ],
              ),
              // The revealed PIN slides in below the grid and times itself out.
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: _pin == null
                    ? const SizedBox(width: double.infinity)
                    : Padding(
                        padding: const EdgeInsets.only(top: PulseSpacing.sm),
                        child: _PinPanel(
                          pin: _pin!,
                          secondsLeft: _secondsLeft,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;
    final foreground = active ? colors.onAccent : colors.textPrimary;

    return PulseCard(
      tone: active ? PulseCardTone.accent : PulseCardTone.muted,
      radius: PulseRadii.button,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: PulseSpacing.lg,
        vertical: PulseSpacing.lg,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: foreground),
          const SizedBox(width: PulseSpacing.md),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: PulseTypography.labelSm.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}

class _PinPanel extends StatelessWidget {
  const _PinPanel({required this.pin, required this.secondsLeft});

  final String pin;
  final int secondsLeft;

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;

    return PulseCard(
      tone: PulseCardTone.inverse,
      radius: PulseRadii.button,
      padding: const EdgeInsets.symmetric(
        horizontal: PulseSpacing.xl,
        vertical: PulseSpacing.lg,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'CARD PIN',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: PulseTypography.caption.copyWith(
                    color: colors.onInverse.withValues(alpha: 0.55),
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: PulseSpacing.xs),
                // Scales down rather than overflowing on narrow screens or at
                // a large text scale.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pin.split('').join('  '),
                    style: PulseTypography.amountMd.copyWith(
                      color: colors.accent,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: PulseSpacing.md),
          Text(
            'Hides in ${secondsLeft}s',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: PulseTypography.caption.copyWith(
              color: colors.onInverse.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

/// Confirmation before replacing a card — a sheet, not an alert dialog.
class _ReplaceCardSheet extends StatelessWidget {
  const _ReplaceCardSheet({required this.last4});

  final String last4;

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          PulseSpacing.screenGutter,
          PulseSpacing.xl,
          PulseSpacing.screenGutter,
          PulseSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                height: 4,
                width: 44,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: PulseRadii.chipRadius,
                ),
              ),
            ),
            const SizedBox(height: PulseSpacing.xl),
            Text(
              'Replace this card?',
              style: PulseTypography.headingMd.copyWith(
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: PulseSpacing.sm),
            Text(
              'Card •••• $last4 will be cancelled immediately and a new one '
              'issued. Any subscriptions using it will need updating.',
              style: PulseTypography.bodyMd.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: PulseSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: PulseButton(
                    label: 'Cancel',
                    variant: PulseButtonVariant.outline,
                    expand: true,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: PulseSpacing.md),
                Expanded(
                  child: PulseButton(
                    label: 'Replace',
                    expand: true,
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
