import 'package:flutter/material.dart';

import '../../../core/theme/pulse_theme.dart';
import '../../../shared/models/models.dart';
import '../../../shared/widgets/widgets.dart';

/// What [BudgetEditSheet] hands back. A limit of 0 means "remove this
/// budget" — the caller treats set and remove identically, just forwarding
/// whatever value comes back to the budgets provider.
class BudgetEditResult {
  const BudgetEditResult({required this.monthlyLimit});

  final double monthlyLimit;
}

/// Set, change, or remove one category's monthly budget.
///
/// The same sheet serves both "edit an existing budget" (opened from a
/// [BudgetProgressCard], [currentLimit] > 0) and "add a new one" (opened from
/// an unbudgeted category chip, [currentLimit] == 0) — only the title and the
/// presence of the Remove action differ.
class BudgetEditSheet extends StatefulWidget {
  const BudgetEditSheet({
    super.key,
    required this.category,
    required this.currentLimit,
  });

  final TransactionCategory category;
  final double currentLimit;

  @override
  State<BudgetEditSheet> createState() => _BudgetEditSheetState();
}

class _BudgetEditSheetState extends State<BudgetEditSheet> {
  late final _amountController = TextEditingController(
    text: widget.currentLimit > 0
        ? widget.currentLimit.toStringAsFixed(0)
        : '',
  );
  bool _attemptedSubmit = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double? get _parsedAmount => double.tryParse(_amountController.text.trim());

  String? get _amountError {
    if (!_attemptedSubmit) return null;
    final amount = _parsedAmount;
    return (amount == null || amount < 0) ? 'Enter a valid amount' : null;
  }

  void _save() {
    setState(() => _attemptedSubmit = true);
    final amount = _parsedAmount;
    if (amount == null || amount < 0) return;
    Navigator.of(context).pop(BudgetEditResult(monthlyLimit: amount));
  }

  void _remove() =>
      Navigator.of(context).pop(const BudgetEditResult(monthlyLimit: 0));

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;
    final isExisting = widget.currentLimit > 0;

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
              Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: colors.accentSoft,
                      borderRadius: PulseRadii.iconRadius,
                    ),
                    child: Icon(
                      widget.category.icon,
                      size: 20,
                      color: colors.accentMuted,
                    ),
                  ),
                  const SizedBox(width: PulseSpacing.md),
                  Expanded(
                    child: Text(
                      isExisting
                          ? 'Edit ${widget.category.label} Budget'
                          : 'Set ${widget.category.label} Budget',
                      maxLines: 2,
                      style: PulseTypography.headingMd.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: PulseSpacing.xl),
              PulseTextField(
                label: 'Monthly Limit',
                controller: _amountController,
                hint: '0.00',
                prefixIcon: Icons.currency_rupee_rounded,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.done,
                errorText: _amountError,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _save(),
              ),
              const SizedBox(height: PulseSpacing.xxl),
              PulseButton(
                label: 'Save Budget',
                expand: true,
                size: PulseButtonSize.large,
                onPressed: _save,
              ),
              if (isExisting) ...[
                const SizedBox(height: PulseSpacing.sm),
                PulseButton(
                  label: 'Remove Budget',
                  variant: PulseButtonVariant.ghost,
                  expand: true,
                  onPressed: _remove,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
