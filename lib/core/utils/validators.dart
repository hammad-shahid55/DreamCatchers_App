import '../constants/app_constants.dart';
import 'date_utils.dart';
import 'password_rules.dart';

abstract final class Validators {
  static final RegExp _email = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');
  static final RegExp _username = RegExp(r'^[a-zA-Z0-9_.]+$');

  static String? required(String? value, [String field = 'This field']) =>
      (value == null || value.trim().isEmpty) ? '$field is required' : null;

  static String? Function(T?) requiredSelection<T>(String field) =>
      (T? value) => value == null ? 'Please select your $field' : null;

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email is required';
    if (!_email.hasMatch(v)) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password is required';
    for (final rule in PasswordRules.all) {
      if (!rule.isMetBy(v)) return 'Needs: ${rule.label}';
    }
    return null;
  }

  static String? Function(String?) confirmPassword(
    String Function() original,
  ) =>
      (value) => value != original() ? 'Passwords do not match' : null;

  static String? username(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Username is required';
    if (v.length < AppConstants.minUsernameLength ||
        v.length > AppConstants.maxUsernameLength) {
      return 'Use ${AppConstants.minUsernameLength}-'
          '${AppConstants.maxUsernameLength} characters';
    }
    if (!_username.hasMatch(v)) {
      return 'Only letters, numbers, "_" and "." are allowed';
    }
    return null;
  }

  static String? birthday(DateTime? value) {
    if (value == null) return 'Please select your birthday';
    if (AppDateUtils.ageFrom(value) < AppConstants.minimumAge) {
      return 'You must be at least ${AppConstants.minimumAge} years old';
    }
    return null;
  }
}
