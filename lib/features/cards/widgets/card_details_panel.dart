import 'package:flutter/material.dart';

import '../../../core/theme/pulse_theme.dart';
import '../../../shared/models/models.dart';
import '../../../shared/widgets/widgets.dart';

/// The selected card's particulars, as stacked quiet rows.
class CardDetailsPanel extends StatelessWidget {
  const CardDetailsPanel({super.key, required this.card});

  final PaymentCard card;

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PulseSectionHeader(title: 'Card Details'),
        const SizedBox(height: PulseSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PulseSpacing.screenGutter,
          ),
          child: Column(
            children: [
              PulseDetailRow(label: 'Card Number', value: card.maskedNumber),
              PulseDetailRow(label: 'Expiry Date', value: card.expiry),
              PulseDetailRow(label: 'Card Holder', value: card.holderName),
              PulseDetailRow(label: 'Network', value: card.network),
              // The balance is the one figure worth promoting out of the list.
              PulseCard(
                tone: PulseCardTone.muted,
                radius: PulseRadii.input,
                padding: const EdgeInsets.symmetric(
                  horizontal: PulseSpacing.lg,
                  vertical: PulseSpacing.lg,
                ),
                child: Row(
                  children: [
                    Text(
                      'Available Balance',
                      style: PulseTypography.metadata.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: PulseSpacing.lg),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: PulseAmount(
                          value: card.availableBalance,
                          size: PulseAmountSize.md,
                          currencySymbol: card.currencySymbol,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
