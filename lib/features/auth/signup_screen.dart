import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/pulse_theme.dart';
import '../../shared/widgets/widgets.dart';
import 'data/auth_controller.dart';
import 'data/auth_state.dart';
import 'data/auth_validators.dart';
import 'widgets/auth_scaffold.dart';
import 'widgets/pulse_brand_mark.dart';

/// The mock registration screen. Like Login, it never navigates on success
/// itself — the router redirects once [AuthController] is authenticated.
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _attemptedSubmit = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? get _nameError =>
      _attemptedSubmit ? AuthValidators.name(_nameController.text) : null;

  String? get _emailError =>
      _attemptedSubmit ? AuthValidators.email(_emailController.text) : null;

  String? get _passwordError => _attemptedSubmit
      ? AuthValidators.password(_passwordController.text)
      : null;

  String? get _confirmError => _attemptedSubmit
      ? AuthValidators.confirmPassword(
          _passwordController.text,
          _confirmController.text,
        )
      : null;

  bool get _canSubmit =>
      AuthValidators.name(_nameController.text) == null &&
      AuthValidators.email(_emailController.text) == null &&
      AuthValidators.password(_passwordController.text) == null &&
      AuthValidators.confirmPassword(
            _passwordController.text,
            _confirmController.text,
          ) ==
          null;

  void _submit() {
    setState(() => _attemptedSubmit = true);
    if (!_canSubmit) return;

    ref
        .read(authControllerProvider.notifier)
        .signUp(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  void _clearAuthError() {
    ref.read(authControllerProvider.notifier).dismissError();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;
    final auth = ref.watch(authControllerProvider);
    final isAuthenticating = auth.status == AuthStatus.authenticating;

    return AuthScaffold(
      onBack: () => context.go(AppRoutes.login),
      child: PulseFadeIn(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PulseBrandMark(),
          const SizedBox(height: PulseSpacing.xl),
          Text(
            'Create your account',
            style: PulseTypography.displayLg.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: PulseSpacing.xs),
          Text(
            'A few details and you\'re in — this stays on your device.',
            style: PulseTypography.bodyLg.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: PulseSpacing.xxl),
          PulseTextField(
            label: 'Full name',
            controller: _nameController,
            hint: 'Aarav Sharma',
            prefixIcon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.name],
            errorText: _nameError,
            onChanged: (_) {
              _clearAuthError();
            },
          ),
          const SizedBox(height: PulseSpacing.lg),
          PulseTextField(
            label: 'Email',
            controller: _emailController,
            hint: 'you@example.com',
            prefixIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            errorText: _emailError,
            onChanged: (_) => _clearAuthError(),
          ),
          const SizedBox(height: PulseSpacing.lg),
          PulseTextField(
            label: 'Password',
            controller: _passwordController,
            hint: 'At least ${AuthValidators.minPasswordLength} characters',
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: true,
            showObscureToggle: true,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            errorText: _passwordError,
            onChanged: (_) => _clearAuthError(),
          ),
          const SizedBox(height: PulseSpacing.lg),
          PulseTextField(
            label: 'Confirm password',
            controller: _confirmController,
            hint: 'Re-enter your password',
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: true,
            showObscureToggle: true,
            textInputAction: TextInputAction.done,
            errorText: _confirmError,
            onSubmitted: (_) => _submit(),
            onChanged: (_) => _clearAuthError(),
          ),
          const SizedBox(height: PulseSpacing.xl),
          PulseButton(
            label: 'Create Account',
            expand: true,
            size: PulseButtonSize.large,
            loading: isAuthenticating,
            onPressed: isAuthenticating ? null : _submit,
          ),
          const SizedBox(height: PulseSpacing.xxl),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  'Already have an account? ',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: PulseTypography.bodyMd.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
              PulseButton(
                label: 'Log In',
                variant: PulseButtonVariant.ghost,
                size: PulseButtonSize.small,
                onPressed: () => context.go(AppRoutes.login),
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }
}
