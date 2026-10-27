import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../profile/data/profile_repository.dart';
import '../../profile/models/profile.dart';
import '../data/auth_repository.dart';
import '../models/sign_up_data.dart';

enum AuthStatus { unknown, unauthenticated, authenticated }

class AuthController extends ChangeNotifier {
  AuthController(this._auth, this._profiles);

  final AuthRepository _auth;
  final ProfileRepository _profiles;
  StreamSubscription<AuthState>? _subscription;

  AuthStatus _status = AuthStatus.unknown;
  Profile? _profile;
  bool _isProfileLoading = false;
  Object? _profileError;

  AuthStatus get status => _status;
  User? get user => _auth.currentUser;
  String? get userId => _auth.currentUser?.id;
  String? get email => _auth.currentUser?.email;
  Profile? get profile => _profile;
  bool get isProfileLoading => _isProfileLoading;
  Object? get profileError => _profileError;

  String get displayName =>
      _profile?.username ??
      (user?.userMetadata?['username'] as String?) ??
      'You';

  void init() {
    _apply(_auth.currentSession);
    _subscription = _auth.authStateChanges.listen(
      (state) => _apply(state.session),
      onError: (_) {},
    );
  }

  void _apply(Session? session) {
    final next = session == null
        ? AuthStatus.unauthenticated
        : AuthStatus.authenticated;
    if (next != _status) {
      _status = next;
      if (session == null) {
        _profile = null;
        _profileError = null;
      }
      notifyListeners();
    }
    if (session != null && _profile?.id != session.user.id) loadProfile();
  }

  Future<void> loadProfile() async {
    final id = userId;
    if (id == null || _isProfileLoading) return;
    _isProfileLoading = true;
    _profileError = null;
    notifyListeners();
    try {
      final profile = await _profiles.fetchProfile(id);
      if (userId == id) _profile = profile;
    } catch (e) {
      if (userId == id) _profileError = e;
    } finally {
      _isProfileLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) =>
      _auth.signIn(email: email, password: password);

  Future<bool> signUp(SignUpData data) => _auth.signUp(data);

  Future<void> resendVerificationEmail(String email) =>
      _auth.resendVerificationEmail(email);

  Future<bool> isUsernameAvailable(String username) =>
      _profiles.isUsernameAvailable(username);

  bool _isAvatarUpdating = false;
  bool get isAvatarUpdating => _isAvatarUpdating;

  Future<String> updateAvatar(XFile image) => _changeAvatar(
    (profile) => _profiles.updateAvatar(
      userId: profile.id,
      image: image,
      previousUrl: profile.avatarUrl,
    ),
  );

  Future<void> removeAvatar() => _changeAvatar((profile) async {
    await _profiles.removeAvatar(
      userId: profile.id,
      currentUrl: profile.avatarUrl,
    );
    return null;
  });

  Future<T> _changeAvatar<T extends String?>(
    Future<T> Function(Profile profile) change,
  ) async {
    final profile = _profile;
    if (profile == null) throw StateError('Profile not loaded');
    _isAvatarUpdating = true;
    notifyListeners();
    try {
      final url = await change(profile);
      if (_profile?.id == profile.id) _profile = profile.withAvatar(url);
      return url;
    } finally {
      _isAvatarUpdating = false;
      notifyListeners();
    }
  }

  Future<void> signOut() => _auth.signOut();

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
