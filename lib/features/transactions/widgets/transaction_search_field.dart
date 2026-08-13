import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/pulse_theme.dart';
import '../data/transaction_query.dart';

/// Search input for the feed.
///
/// Styled as a Pulse surface rather than a Material `TextField` — no
/// underline, no floating label, no focus ring beyond a quiet border. Keeps
/// its own text state and pushes to the query provider only after the user
/// pauses, so a filter pass doesn't run on every keystroke.
class TransactionSearchField extends ConsumerStatefulWidget {
  const TransactionSearchField({super.key});

  static const debounce = Duration(milliseconds: 300);

  @override
  ConsumerState<TransactionSearchField> createState() =>
      _TransactionSearchFieldState();
}

class _TransactionSearchFieldState
    extends ConsumerState<TransactionSearchField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(TransactionSearchField.debounce, () {
      if (mounted) {
        ref.read(transactionQueryProvider.notifier).setSearch(value);
      }
    });
    // Rebuild so the clear button appears immediately, ahead of the debounce.
    setState(() {});
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    ref.read(transactionQueryProvider.notifier).setSearch('');
    _focusNode.unfocus();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;
    final hasText = _controller.text.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PulseSpacing.screenGutter,
      ),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: PulseSpacing.lg),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: PulseRadii.chipRadius,
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              size: 20,
              color: colors.textSecondary,
            ),
            const SizedBox(width: PulseSpacing.md),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                onChanged: _onChanged,
                textInputAction: TextInputAction.search,
                style: PulseTypography.bodyLg.copyWith(
                  color: colors.textPrimary,
                ),
                cursorColor: colors.textPrimary,
                cursorWidth: 1.5,
                decoration: InputDecoration(
                  isDense: true,
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  hintText: 'Search merchant or category',
                  hintStyle: PulseTypography.bodyLg.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
              ),
            ),
            if (hasText)
              GestureDetector(
                onTap: _clear,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.only(left: PulseSpacing.sm),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: colors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
