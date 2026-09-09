import 'package:flutter/material.dart';

import '../../../core/theme/pulse_theme.dart';
import '../../../shared/widgets/widgets.dart';

/// Which of the three Quick Actions opened the sheet — only the copy and the
/// presence of a recipient field differ between them.
enum MoneyMoveKind { deposit, withdraw, transfer }

/// What the sheet hands back on a successful submit.
@immutable
class MoneyMoveResult {
  const MoneyMoveResult({required this.amount, this.recipient});

  final double amount;

  /// Set only for [MoneyMoveKind.transfer].
  final String? recipient;
}

/// The Deposit / Withdraw / Send Money bottom sheet.
///
/// One widget rather than three near-duplicates: the amount field and its
/// validation are identical across all three actions, and Transfer only adds
/// a recipient field above it.
class MoneyMoveSheet extends StatefulWidget {
  const MoneyMoveSheet({
    super.key,
    required this.kind,
    required this.availableBalance,
    required this.currencySymbol,
  });

  final MoneyMoveKind kind;

  /// Caps the amount for [MoneyMoveKind.withdraw] and [MoneyMoveKind.transfer]
  /// — a deposit has no such ceiling.
  final double availableBalance;

  final String currencySymbol;

  @override
  State<MoneyMoveSheet> createState() => _MoneyMoveSheetState();
}

class _MoneyMoveSheetState extends State<MoneyMoveSheet> {
  final _amountController = TextEditingController();
  final _recipientController = TextEditingController();
  bool _attemptedSubmit = false;

  bool get _isTransfer => widget.kind == MoneyMoveKind.transfer;
  bool get _debitsBalance => widget.kind != MoneyMoveKind.deposit;

  @override
  void dispose() {
    _amountController.dispose();
    _recipientController.dispose();
    super.dispose();
  }

  double? get _parsedAmount => double.tryParse(_amountController.text.trim());

  String? get _amountError {
    if (!_attemptedSubmit) return null;
    final amount = _parsedAmount;
    if (amount == null || amount <= 0) return 'Enter a valid amount';
    if (_debitsBalance && amount > widget.availableBalance) {
      return 'That\'s more than your available balance';
    }
    return null;
  }

  String? get _recipientError {
    if (!_attemptedSubmit || !_isTransfer) return null;
    return _recipientController.text.trim().isEmpty
        ? 'Enter a recipient'
        : null;
  }

  bool get _isValid {
    final amount = _parsedAmount;
    if (amount == null || amount <= 0) return false;
    if (_debitsBalance && amount > widget.availableBalance) return false;
    if (_isTransfer && _recipientController.text.trim().isEmpty) return false;
    return true;
  }

  void _submit() {
    setState(() => _attemptedSubmit = true);
    if (!_isValid) return;

    Navigator.of(context).pop(
      MoneyMoveResult(
        amount: _parsedAmount!,
        recipient: _isTransfer ? _recipientController.text.trim() : null,
      ),
    );
  }

  (String title, String subtitle, String action) get _copy => switch (widget
      .kind) {
    MoneyMoveKind.deposit => (
      'Deposit Money',
      'Add funds to your Pulse balance.',
      'Deposit',
    ),
    MoneyMoveKind.withdraw => (
      'Withdraw Money',
      'Move money out of your Pulse balance.',
      'Withdraw',
    ),
    MoneyMoveKind.transfer => (
      'Send Money',
      'Transfer to another person or account.',
      'Send',
    ),
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;
    final (title, subtitle, action) = _copy;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
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
                title,
                style: PulseTypography.headingMd.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: PulseSpacing.xs),
              Text(
                subtitle,
                style: PulseTypography.bodyMd.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: PulseSpacing.xl),
              if (_isTransfer) ...[
                PulseTextField(
                  label: 'Recipient',
                  controller: _recipientController,
                  hint: 'Name or account',
                  prefixIcon: Icons.person_outline_rounded,
                  textInputAction: TextInputAction.next,
                  errorText: _recipientError,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: PulseSpacing.lg),
              ],
              PulseTextField(
                label: 'Amount',
                controller: _amountController,
                hint: '0.00',
                prefixIcon: Icons.currency_rupee_rounded,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.done,
                errorText: _amountError,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: PulseSpacing.xxl),
              PulseButton(
                label: action,
                expand: true,
                size: PulseButtonSize.large,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
