import 'package:flutter/foundation.dart';

abstract final class SupabaseConfig {
  static const String url = String.fromEnvironment('SUPABASE_URL');

  static const String publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;

  static const String appScheme = 'com.dreamcatchers.app';

  static const String mobileRedirectUrl = '$appScheme://login-callback/';

  static String? get emailRedirectUrl => kIsWeb ? null : mobileRedirectUrl;

  static const String postMediaBucket = 'post-media';
  static const String avatarsBucket = 'avatars';
}
