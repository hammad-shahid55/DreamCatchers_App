import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_config.dart';
import '../../../core/errors/app_exception.dart';
import '../models/sign_up_data.dart';

class AuthRepository {
  const AuthRepository(this._client);

  final SupabaseClient _client;

  GoTrueClient get _auth => _client.auth;

  Session? get currentSession => _auth.currentSession;
  User? get currentUser => _auth.currentUser;
  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  Future<void> signIn({required String email, required String password}) =>
      _auth.signInWithPassword(email: email.trim(), password: password);

  Future<bool> signUp(SignUpData data) async {
    final response = await _auth.signUp(
      email: data.email.trim(),
      password: data.password,
      data: data.toMetadata(),
      emailRedirectTo: SupabaseConfig.emailRedirectUrl,
    );
    final identities = response.user?.identities;
    if (identities != null && identities.isEmpty) {
      throw const AppException('An account with this email already exists.');
    }
    return response.session == null;
  }

  Future<void> resendVerificationEmail(String email) => _auth.resend(
    type: OtpType.signup,
    email: email.trim(),
    emailRedirectTo: SupabaseConfig.emailRedirectUrl,
  );

  Future<void> signOut() => _auth.signOut();
}
