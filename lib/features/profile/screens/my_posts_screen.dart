import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../posts/controllers/post_events.dart';
import '../../posts/controllers/post_list_controllers.dart';
import '../../posts/data/post_repository.dart';
import '../../posts/widgets/post_list_view.dart';

class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  late final UserPostsController _posts = UserPostsController(
    context.read<PostRepository>(),
    context.read<PostEventBus>(),
    userId: context.read<AuthController>().userId!,
  );

  @override
  void dispose() {
    _posts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'My Posts'),
      body: PostListView(
        controller: _posts,
        empty: const EmptyView(
          icon: Icons.edit_note_rounded,
          title: 'No posts yet',
          message: 'Tap Post to share your first one.',
        ),
      ),
    );
  }
}
