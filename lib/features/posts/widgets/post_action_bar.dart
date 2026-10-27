import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/context_extensions.dart';
import '../controllers/post_actions_controller.dart';
import '../models/post.dart';
import 'post_action_button.dart';

class PostActionBar extends StatelessWidget {
  const PostActionBar({super.key, required this.post, this.onCommentTap});

  final Post post;
  final VoidCallback? onCommentTap;

  Future<void> _run(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (e) {
      if (context.mounted) context.showError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final actions = context.read<PostActionsController>();
    return Row(
      children: [
        PostActionButton(
          tooltip: post.isLiked ? 'Unlike' : 'Like',
          icon: Icons.thumb_up_outlined,
          activeIcon: Icons.thumb_up_rounded,
          isActive: post.isLiked,
          count: post.likeCount,
          onTap: () => _run(context, () => actions.toggleLike(post)),
        ),
        PostActionButton(
          tooltip: 'Comments',
          icon: Icons.chat_bubble_outline_rounded,
          count: post.commentCount,
          onTap: onCommentTap,
        ),
        const Spacer(),
        PostActionButton(
          tooltip: 'Share',
          icon: Icons.ios_share_rounded,
          count: post.shareCount,
          onTap: () => _run(context, () => actions.share(post)),
        ),
      ],
    );
  }
}
