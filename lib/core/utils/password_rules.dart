import '../constants/app_constants.dart';

class PasswordRule {
  const PasswordRule(this.label, this._test);

  final String label;
  final bool Function(String password) _test;

  bool isMetBy(String password) => _test(password);
}

abstract final class PasswordRules {
  static final List<PasswordRule> all = [
    PasswordRule(
      'At least ${AppConstants.minPasswordLength} characters',
      (p) => p.length >= AppConstants.minPasswordLength,
    ),
    PasswordRule(
      'One uppercase letter (A-Z)',
      (p) => p.contains(RegExp('[A-Z]')),
    ),
    PasswordRule(
      'One lowercase letter (a-z)',
      (p) => p.contains(RegExp('[a-z]')),
    ),
    PasswordRule('One number (0-9)', (p) => p.contains(RegExp(r'\d'))),
    PasswordRule(
      'One symbol (e.g. ! @ # \$ %)',
      (p) => p.contains(RegExp(r'[^A-Za-z0-9\s]')),
    ),
  ];

  static bool isStrong(String password) =>
      all.every((rule) => rule.isMetBy(password));
}
