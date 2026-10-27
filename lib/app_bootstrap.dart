import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/system_ui.dart';
import 'core/widgets/state_views.dart';
import 'features/auth/widgets/splash_view.dart';

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  SupabaseClient? _client;
  Object? _error;
  bool _splashDone = false;

  @override
  void initState() {
    super.initState();
    _initialise();
  }

  Future<void> _initialise() async {
    setState(() => _error = null);
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        publishableKey: SupabaseConfig.publishableKey,
      );
      if (mounted) setState(() => _client = Supabase.instance.client);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final client = _client;
    if (client != null && _splashDone) return DreamCatchersApp(client: client);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemUi.gradientFull,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: _error != null
            ? Scaffold(
                body: ErrorView(
                  message:
                      'Could not start DreamCatchers. Check your '
                      'connection and try again.',
                  onRetry: _initialise,
                ),
              )
            : SplashView(
                onFinished: () {
                  if (mounted) setState(() => _splashDone = true);
                },
              ),
      ),
    );
  }
}
