import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/option_tile.dart';
import '../../profile/models/profile_options.dart';
import '../controllers/auth_controller.dart';
import '../models/sign_up_data.dart';
import '../widgets/auth_footer_link.dart';
import '../widgets/birthday_field.dart';
import '../widgets/password_hint.dart';
import '../widgets/personality_type_picker.dart';
import '../widgets/step_page.dart';
import 'option_list_screen.dart';

enum _Step {
  email,
  password,
  username,
  gender,
  birthday,
  ethnicity,
  personality,
  relationship,
  education,
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailForm = GlobalKey<FormState>();
  final _passwordForm = GlobalKey<FormState>();
  final _usernameForm = GlobalKey<FormState>();

  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _username = TextEditingController();

  String? _gender;
  DateTime? _birthday;
  String? _ethnicity;
  String _personality = PersonalityTypePicker.unset;
  RelationshipStatus? _relationshipStatus;
  EducationLevel? _educationLevel;

  _Step _step = _Step.email;
  bool _isBusy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _username.dispose();
    super.dispose();
  }

  double get _progress => (_step.index + 1) / _Step.values.length;

  void _next() => setState(() => _step = _Step.values[_step.index + 1]);

  void _back() {
    if (_step == _Step.email) {
      Navigator.pop(context);
    } else {
      setState(() => _step = _Step.values[_step.index - 1]);
    }
  }

  bool _requireChoice(Object? value) {
    if (value != null) return true;
    context.showMessage('Please choose an option to continue.', isError: true);
    return false;
  }

  Future<void> _continue() async {
    context.unfocus();
    switch (_step) {
      case _Step.email:
        if (_emailForm.currentState!.validate()) _next();
      case _Step.password:
        if (_passwordForm.currentState!.validate()) _next();
      case _Step.username:
        if (_usernameForm.currentState!.validate()) await _checkUsername();
      case _Step.gender:
        if (_requireChoice(_gender)) _next();
      case _Step.birthday:
        final error = Validators.birthday(_birthday);
        if (error == null) {
          _next();
        } else {
          context.showMessage(error, isError: true);
        }
      case _Step.ethnicity:
        if (_requireChoice(_ethnicity)) _next();
      case _Step.personality:
        if (PersonalityType.isValid(_personality)) {
          _next();
        } else {
          context.showMessage(
            'Tap all four boxes to set your type.',
            isError: true,
          );
        }
      case _Step.relationship:
        if (_requireChoice(_relationshipStatus)) _next();
      case _Step.education:
        if (_requireChoice(_educationLevel)) await _createAccount();
    }
  }

  Future<void> _runBusy(Future<void> Function() task) async {
    setState(() => _isBusy = true);
    try {
      await task();
    } catch (e) {
      if (mounted) context.showError(e);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _checkUsername() => _runBusy(() async {
    final available = await context.read<AuthController>().isUsernameAvailable(
      _username.text,
    );
    if (!mounted) return;
    if (available) {
      _next();
    } else {
      context.showMessage(
        '"${_username.text.trim()}" is already taken.',
        isError: true,
      );
    }
  });

  Future<void> _createAccount() => _runBusy(() async {
    final data = SignUpData(
      email: _email.text,
      password: _password.text,
      username: _username.text,
      ethnicity: _ethnicity!,
      gender: _gender!,
      relationshipStatus: _relationshipStatus!,
      birthday: _birthday!,
      personalityType: _personality,
      educationLevel: _educationLevel!,
    );
    final needsVerification = await context.read<AuthController>().signUp(data);
    if (mounted && needsVerification) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.verifyEmail,
        arguments: data.email.trim(),
      );
    }
  });

  Future<void> _pickOtherGender() async {
    final choice = await OptionListScreen.open(
      context,
      title: 'Others',
      options: Genders.others,
      selected: Genders.others.contains(_gender) ? _gender : null,
    );
    if (choice != null) setState(() => _gender = choice);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _step == _Step.email,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_isBusy) _back();
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: KeyedSubtree(key: ValueKey(_step), child: _buildStep()),
      ),
    );
  }

  Widget _buildStep() {
    StepPage page({
      required String title,
      required Widget child,
      String? subtitle,
      Widget? helper,
      Widget? secondary,
      bool withBar = true,
    }) => StepPage(
      barTitle: withBar ? 'Sign Up' : null,
      progress: withBar ? _progress : null,
      title: title,
      subtitle: subtitle,
      helper: helper,
      secondary: secondary,
      primaryLabel: 'Continue',
      isLoading: _isBusy,
      onPrimary: _continue,
      onBack: _isBusy ? () {} : _back,
      child: child,
    );

    switch (_step) {
      case _Step.email:
        return page(
          withBar: false,
          title: 'What\'s your email address?',
          subtitle:
              'Verify your email address in case you lose access to '
              'your account.',
          secondary: AuthFooterLink(
            text: 'Already joined?',
            action: 'Sign in',
            onTap: () =>
                Navigator.pushReplacementNamed(context, AppRoutes.signIn),
          ),
          child: Form(
            key: _emailForm,
            child: AppTextField(
              controller: _email,
              hint: 'Enter email address',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.email],
              validator: Validators.email,
              onSubmitted: (_) => _continue(),
            ),
          ),
        );
      case _Step.password:
        return page(
          withBar: false,
          title: 'Create a password',
          subtitle: 'Choose a strong password to keep your account safe.',
          child: Form(
            key: _passwordForm,
            child: Column(
              children: [
                AppTextField(
                  controller: _password,
                  hint: 'Password',
                  isPassword: true,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: Validators.password,
                ),
                Gaps.h12,
                AppTextField(
                  controller: _confirmPassword,
                  hint: 'Confirm password',
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  validator: Validators.confirmPassword(() => _password.text),
                  onSubmitted: (_) => _continue(),
                ),
                Gaps.h16,
                PasswordHint(controller: _password),
              ],
            ),
          ),
        );
      case _Step.username:
        return page(
          title: 'What\'s your Username?',
          helper: const HelperText(
            'This will be shown on your profile. Username ',
            emphasis: 'cannot be changed',
          ),
          child: Form(
            key: _usernameForm,
            child: AppTextField(
              controller: _username,
              hint: 'Username',
              maxLength: AppConstants.maxUsernameLength,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newUsername],
              validator: Validators.username,
              onSubmitted: (_) => _continue(),
            ),
          ),
        );
      case _Step.gender:
        final isOther = _gender != null && !Genders.primary.contains(_gender);
        return page(
          title: 'What gender do you identify as?',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OptionList<String>(
                options: Genders.primary,
                labelOf: (g) => g,
                selected: _gender,
                onSelected: (g) => setState(() => _gender = g),
              ),
              OptionTile(
                label: isOther ? _gender! : 'Others',
                selected: isOther,
                showChevron: true,
                onTap: _pickOtherGender,
              ),
            ],
          ),
        );
      case _Step.birthday:
        final now = DateTime.now();
        return page(
          title: 'When\'s your birthday?',
          helper: const HelperText(
            'Your profile will show your age, not your date of birth. ',
            emphasis: 'This cannot be changed later',
          ),
          child: BirthdayField(
            value: _birthday,
            maximumDate: DateTime(
              now.year - AppConstants.minimumAge,
              now.month,
              now.day,
            ),
            onChanged: (d) => setState(() => _birthday = d),
          ),
        );
      case _Step.ethnicity:
        return page(
          title: 'What\'s your ethnicity?',
          child: OptionList<String>(
            options: Ethnicities.all,
            labelOf: (e) => e,
            selected: _ethnicity,
            onSelected: (e) => setState(() => _ethnicity = e),
          ),
        );
      case _Step.personality:
        return page(
          title: 'What\'s your personality type?',
          helper: const Text(
            'The personality type used follows the 16 Personalities.',
          ),
          child: PersonalityTypePicker(
            value: _personality,
            onChanged: (v) => setState(() => _personality = v),
          ),
        );
      case _Step.relationship:
        return page(
          title: 'What\'s your relationship status?',
          child: OptionList<RelationshipStatus>(
            options: RelationshipStatus.selectable,
            labelOf: (r) => r.label,
            selected: _relationshipStatus,
            onSelected: (r) => setState(() => _relationshipStatus = r),
          ),
        );
      case _Step.education:
        return page(
          title: 'What\'s your highest education level?',
          child: OptionList<EducationLevel>(
            options: EducationLevel.selectable,
            labelOf: (e) => e.label,
            selected: _educationLevel,
            onSelected: (e) => setState(() => _educationLevel = e),
          ),
        );
    }
  }
}
