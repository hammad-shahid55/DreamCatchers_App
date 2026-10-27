import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/context_extensions.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_footer_link.dart';
import '../widgets/step_page.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key, required this.email});

  final String email;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  Timer? _timer;
  int _secondsLeft = AppConstants.resendCooldown.inSeconds;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _secondsLeft = AppConstants.resendCooldown.inSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) timer.cancel();
      setState(() => _secondsLeft--);
    });
  }

  Future<void> _resend() async {
    setState(() => _isSending = true);
    try {
      await context.read<AuthController>().resendVerificationEmail(
        widget.email,
      );
      if (!mounted) return;
      context.showMessage('Verification email sent again.');
      _startCooldown();
    } catch (e) {
      if (mounted) context.showError(e);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canResend = _secondsLeft <= 0 && !_isSending;
    return StepPage(
      title: 'Verify your email address',
      subtitle:
          'We sent a verification link to ${widget.email}. Open it on '
          'this device to activate your account.',
      primaryLabel: 'I\'ve verified, sign in',
      onPrimary: () => Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.signIn,
        (route) => route.isFirst,
      ),
      helper: const Text('Can\'t find it? Check your spam folder.'),
      secondary: LinkButton(
        label: canResend ? 'Resend email' : 'Resend in ${_secondsLeft}s',
        onTap: canResend ? _resend : null,
      ),
      child: Center(
        child: Container(
          margin: const EdgeInsets.only(top: AppSpacing.xl),
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_unread_outlined,
            size: 56,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
