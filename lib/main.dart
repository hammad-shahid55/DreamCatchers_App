import 'package:flutter/material.dart';

import 'app_bootstrap.dart';
import 'core/config/supabase_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (!SupabaseConfig.isConfigured) {
    throw StateError(
      'Supabase is not configured. Copy .env.example to .env and run: '
      'flutter run --dart-define-from-file=.env',
    );
  }
  runApp(const AppBootstrap());
}
