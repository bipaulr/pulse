import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/pulse_theme.dart';
import '../../shared/widgets/widgets.dart';
import 'data/auth_repository.dart';
import 'data/auth_validators.dart';
import 'widgets/auth_scaffold.dart';
import 'widgets/pulse_brand_mark.dart';

/// A lightweight mock "forgot password" flow: one field, one request, one
/// confirmation. Nothing is sent — [MockAuthRepository.requestPasswordReset]
/// is a no-op delay standing in for a network call.
///
/// This state is local to the screen rather than living in [AuthController]:
/// it doesn't change who is signed in, so it has no business in the app-wide
/// auth state.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _attemptedSubmit = false;
  bool _sending = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? get _emailError =>
      _attemptedSubmit ? AuthValidators.email(_emailController.text) : null;

  Future<void> _submit() async {
    setState(() => _attemptedSubmit = true);
    if (AuthValidators.email(_emailController.text) != null) return;

    setState(() => _sending = true);
    await ref
        .read(authRepositoryProvider)
        .requestPasswordReset(email: _emailController.text);
    if (!mounted) return;
    setState(() {
      _sending = false;
      _sent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      onBack: () => _backToLogin(context),
      child: _sent
          ? _ConfirmationView(onDone: () => _backToLogin(context))
          : _buildForm(context),
    );
  }

  /// This screen is normally reached by pushing from Login, so popping is
  /// correct — but a direct visit to the URL (this is a web app) leaves
  /// nothing to pop, so falling back to an explicit navigation is what keeps
  /// the back arrow from throwing in that case.
  static void _backToLogin(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.login);
    }
  }

  Widget _buildForm(BuildContext context) {
    final colors = context.pulseColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PulseBrandMark(),
        const SizedBox(height: PulseSpacing.xl),
        Text(
          'Forgot your password?',
          style: PulseTypography.displayLg.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: PulseSpacing.xs),
        Text(
          "Enter the email on your account and we'll send a reset link.",
          style: PulseTypography.bodyLg.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: PulseSpacing.xxl),
        PulseTextField(
          label: 'Email',
          controller: _emailController,
          hint: 'you@example.com',
          prefixIcon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.email],
          errorText: _emailError,
          onSubmitted: (_) => _submit(),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: PulseSpacing.xl),
        PulseButton(
          label: 'Send Reset Link',
          expand: true,
          size: PulseButtonSize.large,
          loading: _sending,
          onPressed: _sending ? null : _submit,
        ),
      ],
    );
  }
}

class _ConfirmationView extends StatelessWidget {
  const _ConfirmationView({required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: PulseSpacing.huge),
        Container(
          height: 72,
          width: 72,
          decoration: BoxDecoration(color: colors.accent, shape: BoxShape.circle),
          child: Icon(
            Icons.mark_email_read_outlined,
            size: 32,
            color: colors.onAccent,
          ),
        ),
        const SizedBox(height: PulseSpacing.xl),
        Text(
          'Check your email',
          textAlign: TextAlign.center,
          style: PulseTypography.headingLg.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: PulseSpacing.sm),
        Text(
          'If an account exists for this email, a reset link has been sent.',
          textAlign: TextAlign.center,
          style: PulseTypography.bodyLg.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: PulseSpacing.xxl),
        PulseButton(
          label: 'Back to Login',
          expand: true,
          size: PulseButtonSize.large,
          onPressed: onDone,
        ),
      ],
    );
  }
}
