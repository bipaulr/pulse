import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/pulse_theme.dart';
import '../../shared/widgets/widgets.dart';
import 'data/auth_controller.dart';
import 'data/auth_repository.dart';
import 'data/auth_state.dart';
import 'data/auth_validators.dart';
import 'widgets/auth_scaffold.dart';
import 'widgets/pulse_brand_mark.dart';

/// The mock sign-in screen.
///
/// Doesn't navigate on success itself — once [AuthController] flips to
/// authenticated, the router's own redirect takes it to Home. Login only
/// owns the form.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _attemptedSubmit = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? get _emailError =>
      _attemptedSubmit ? AuthValidators.email(_emailController.text) : null;

  String? get _passwordError => _attemptedSubmit
      ? AuthValidators.password(_passwordController.text)
      : null;

  bool get _canSubmit =>
      AuthValidators.email(_emailController.text) == null &&
      AuthValidators.password(_passwordController.text) == null;

  void _submit() {
    setState(() => _attemptedSubmit = true);
    if (!_canSubmit) return;

    ref
        .read(authControllerProvider.notifier)
        .login(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;
    final auth = ref.watch(authControllerProvider);
    final isAuthenticating = auth.status == AuthStatus.authenticating;

    return AuthScaffold(
      child: PulseFadeIn(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PulseBrandMark(),
          const SizedBox(height: PulseSpacing.xl),
          Text(
            'Welcome back',
            style: PulseTypography.displayLg.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: PulseSpacing.xs),
          Text(
            'Log in to continue to Pulse.',
            style: PulseTypography.bodyLg.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: PulseSpacing.xxl),
          PulseTextField(
            label: 'Email',
            controller: _emailController,
            hint: 'you@example.com',
            prefixIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            errorText: _emailError,
            onChanged: (_) {
              ref.read(authControllerProvider.notifier).dismissError();
              setState(() {});
            },
          ),
          const SizedBox(height: PulseSpacing.lg),
          PulseTextField(
            label: 'Password',
            controller: _passwordController,
            hint: 'Enter your password',
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: true,
            showObscureToggle: true,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            errorText: _passwordError,
            onSubmitted: (_) => _submit(),
            onChanged: (_) {
              ref.read(authControllerProvider.notifier).dismissError();
              setState(() {});
            },
          ),
          const SizedBox(height: PulseSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: PulseButton(
              label: 'Forgot Password?',
              variant: PulseButtonVariant.ghost,
              size: PulseButtonSize.small,
              onPressed: () => context.push(AppRoutes.forgotPassword),
            ),
          ),
          if (auth.errorMessage != null) ...[
            const SizedBox(height: PulseSpacing.sm),
            Row(
              children: [
                Icon(Icons.error_outline_rounded, size: 16, color: colors.negative),
                const SizedBox(width: PulseSpacing.xs),
                Expanded(
                  child: Text(
                    auth.errorMessage!,
                    style: PulseTypography.metadata.copyWith(
                      color: colors.negative,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: PulseSpacing.xl),
          PulseButton(
            label: 'Log In',
            expand: true,
            size: PulseButtonSize.large,
            loading: isAuthenticating,
            onPressed: isAuthenticating ? null : _submit,
          ),
          const SizedBox(height: PulseSpacing.lg),
          PulseCard(
            tone: PulseCardTone.muted,
            radius: PulseRadii.input,
            padding: const EdgeInsets.symmetric(
              horizontal: PulseSpacing.lg,
              vertical: PulseSpacing.md,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: colors.textSecondary,
                ),
                const SizedBox(width: PulseSpacing.sm),
                Expanded(
                  child: Text(
                    'Demo account: ${MockAuthRepository.demoEmail} · '
                    '${MockAuthRepository.demoPassword}',
                    style: PulseTypography.caption.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: PulseSpacing.xxl),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  "Don't have an account? ",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: PulseTypography.bodyMd.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
              PulseButton(
                label: 'Sign Up',
                variant: PulseButtonVariant.ghost,
                size: PulseButtonSize.small,
                onPressed: () => context.go(AppRoutes.signUp),
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }
}
