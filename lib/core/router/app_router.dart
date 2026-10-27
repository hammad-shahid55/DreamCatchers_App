import 'package:flutter/material.dart';

import '../../features/auth/screens/auth_gate.dart';
import '../../features/auth/screens/sign_in_screen.dart';
import '../../features/auth/screens/sign_up_screen.dart';
import '../../features/auth/screens/verify_email_screen.dart';
import '../../features/posts/models/post.dart';
import '../../features/posts/screens/create_post_screen.dart';
import '../../features/posts/screens/post_detail_screen.dart';
import '../../features/profile/screens/my_posts_screen.dart';
import '../../features/profile/screens/personal_information_screen.dart';

abstract final class AppNavigator {
  static final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();
}

abstract final class AppRoutes {
  static const String root = '/';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String verifyEmail = '/verify-email';
  static const String createPost = '/create-post';
  static const String postDetail = '/post';
  static const String personalInformation = '/profile/personal-information';
  static const String myPosts = '/profile/my-posts';
}

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final Widget page = switch (settings.name) {
      AppRoutes.signIn => const SignInScreen(),
      AppRoutes.signUp => const SignUpScreen(),
      AppRoutes.verifyEmail => VerifyEmailScreen(
        email: settings.arguments as String,
      ),
      AppRoutes.createPost => CreatePostScreen(
        editing: settings.arguments as Post?,
      ),
      AppRoutes.postDetail => PostDetailScreen(
        post: settings.arguments as Post,
      ),
      AppRoutes.personalInformation => const PersonalInformationScreen(),
      AppRoutes.myPosts => const MyPostsScreen(),
      _ => const AuthGate(),
    };
    return MaterialPageRoute<dynamic>(
      builder: (_) => page,
      settings: settings,
      fullscreenDialog: settings.name == AppRoutes.createPost,
    );
  }
}
