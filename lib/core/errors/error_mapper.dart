import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_exception.dart';

String friendlyError(Object error) {
  if (error is AppException) return error.message;

  if (error is AuthException) {
    return switch (error.code) {
      'invalid_credentials' => 'Incorrect email or password.',
      'email_not_confirmed' => 'Please verify your email before signing in.',
      'user_already_exists' => 'An account with this email already exists.',
      'over_email_send_rate_limit' =>
        'Too many emails sent. Please wait a moment and try again.',
      'weak_password' =>
        'Password needs 8+ characters with uppercase, lowercase, a number and a symbol.',
      _ when error.message.contains('Database error saving new user') =>
        'That username was just taken. Please choose another one.',
      _ => error.message,
    };
  }

  if (error is PostgrestException) {
    return switch (error.code) {
      '23505' => 'This already exists.',
      '23514' => 'Some of the data is not valid.',
      '42501' => 'You are not allowed to do that.',
      _ => error.message,
    };
  }

  if (error is StorageException) return error.message;

  final text = error.toString();
  if (text.contains('SocketException') ||
      text.contains('Failed host lookup') ||
      text.contains('ClientException')) {
    return 'No internet connection. Please check your network.';
  }
  return 'Something went wrong. Please try again.';
}
