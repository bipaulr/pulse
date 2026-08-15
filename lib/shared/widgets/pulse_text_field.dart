import 'package:flutter/material.dart';

import '../../core/theme/pulse_theme.dart';

/// A labelled text input in the Pulse visual language.
///
/// Built the same way as the transaction search field: a bordered surface
/// container with no Material fill, underline, or floating label — never a
/// stock [TextField] look. Used across the auth screens; nothing here is
/// specific to any one of them.
class PulseTextField extends StatefulWidget {
  const PulseTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.errorText,
    this.obscureText = false,
    this.showObscureToggle = false,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.autofillHints,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;

  /// Shown beneath the field in the negative role. Null hides the slot
  /// entirely rather than reserving blank space.
  final String? errorText;

  final bool obscureText;

  /// Adds a show/hide eye icon that toggles [obscureText] locally. Only
  /// meaningful when [obscureText] starts true (password fields).
  final bool showObscureToggle;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final IconData? prefixIcon;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;

  @override
  State<PulseTextField> createState() => _PulseTextFieldState();
}

class _PulseTextFieldState extends State<PulseTextField> {
  late bool _obscured = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;
    final hasError = widget.errorText != null;
    final borderColor = hasError ? colors.negative : colors.border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label,
          style: PulseTypography.metadata.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: PulseSpacing.sm),
        AnimatedContainer(
          duration: PulseMotion.standard,
          curve: PulseMotion.curve,
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: PulseSpacing.lg),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: PulseRadii.inputRadius,
            border: Border.all(color: borderColor, width: hasError ? 1.5 : 1),
          ),
          child: Row(
            children: [
              if (widget.prefixIcon != null) ...[
                Icon(widget.prefixIcon, size: 20, color: colors.textSecondary),
                const SizedBox(width: PulseSpacing.md),
              ],
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  obscureText: _obscured,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  autofillHints: widget.autofillHints,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
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
                    hintText: widget.hint,
                    hintStyle: PulseTypography.bodyLg.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                ),
              ),
              if (widget.showObscureToggle)
                GestureDetector(
                  onTap: () => setState(() => _obscured = !_obscured),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.only(left: PulseSpacing.sm),
                    child: Icon(
                      _obscured
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Expands/fades into place rather than shoving the rest of the form
        // down in a single frame; collapses the same way when the error
        // clears, reserving no space when there's nothing to say.
        AnimatedSize(
          duration: PulseMotion.standard,
          curve: PulseMotion.curve,
          alignment: Alignment.topCenter,
          child: AnimatedOpacity(
            duration: PulseMotion.standard,
            opacity: hasError ? 1 : 0,
            child: hasError
                ? Padding(
                    padding: const EdgeInsets.only(top: PulseSpacing.xs),
                    child: Text(
                      widget.errorText!,
                      style: PulseTypography.caption.copyWith(
                        color: colors.negative,
                      ),
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ),
      ],
    );
  }
}
