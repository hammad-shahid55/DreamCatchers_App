import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/system_ui.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/comments/data/comment_repository.dart';
import 'features/posts/controllers/post_actions_controller.dart';
import 'features/posts/controllers/post_events.dart';
import 'features/posts/data/media_storage_service.dart';
import 'features/posts/data/post_repository.dart';
import 'features/posts/widgets/post_link_listener.dart';
import 'features/profile/data/profile_repository.dart';

class DreamCatchersApp extends StatelessWidget {
  const DreamCatchersApp({super.key, required this.client});

  final SupabaseClient client;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => AuthRepository(client)),
        Provider(create: (_) => ProfileRepository(client)),
        Provider(
          create: (_) => PostRepository(client, MediaStorageService(client)),
        ),
        Provider(create: (_) => CommentRepository(client)),
        Provider(
          create: (_) => PostEventBus(),
          dispose: (_, bus) => bus.dispose(),
        ),
        Provider(
          create: (context) => PostActionsController(
            context.read<PostRepository>(),
            context.read<PostEventBus>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthController(
            context.read<AuthRepository>(),
            context.read<ProfileRepository>(),
          )..init(),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        navigatorKey: AppNavigator.key,
        initialRoute: AppRoutes.root,
        onGenerateRoute: AppRouter.onGenerateRoute,
        builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
          value: AppSystemUi.light,
          child: MediaQuery.withClampedTextScaling(
            minScaleFactor: 0.85,
            maxScaleFactor: 1.3,
            child: PostLinkListener(child: child!),
          ),
        ),
      ),
    );
  }
}
