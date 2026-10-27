import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_footer_link.dart';
import '../widgets/step_page.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    context.unfocus();
    setState(() => _isSubmitting = true);
    try {
      await context.read<AuthController>().signIn(_email.text, _password.text);
    } on AuthException catch (e) {
      if (!mounted) return;
      if (e.code == 'email_not_confirmed') {
        context.showMessage('Please verify your email first.', isError: true);
        Navigator.pushNamed(
          context,
          AppRoutes.verifyEmail,
          arguments: _email.text.trim(),
        );
      } else {
        context.showError(e);
      }
    } catch (e) {
      if (mounted) context.showError(e);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StepPage(
      title: 'Welcome back',
      subtitle: 'Sign in with your email address and password.',
      primaryLabel: 'Sign in',
      isLoading: _isSubmitting,
      onPrimary: _submit,
      secondary: AuthFooterLink(
        text: 'New here?',
        action: 'Sign up',
        onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.signUp),
      ),
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                controller: _email,
                hint: 'Enter email address',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: Validators.email,
              ),
              Gaps.h12,
              AppTextField(
                controller: _password,
                hint: 'Password',
                isPassword: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                validator: (v) => Validators.required(v, 'Password'),
                onSubmitted: (_) => _submit(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
