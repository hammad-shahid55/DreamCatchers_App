import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../posts/controllers/post_actions_controller.dart';
import '../../posts/models/post.dart';
import '../controllers/comments_controller.dart';
import '../data/comment_repository.dart';
import 'comments_view.dart';

abstract final class CommentsSheet {
  static Future<void> show(BuildContext context, Post post) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _CommentsSheetBody(post: post),
    );
  }
}

class _CommentsSheetBody extends StatefulWidget {
  const _CommentsSheetBody({required this.post});

  final Post post;

  @override
  State<_CommentsSheetBody> createState() => _CommentsSheetBodyState();
}

class _CommentsSheetBodyState extends State<_CommentsSheetBody> {
  late final CommentsController _comments = CommentsController(
    postId: widget.post.id,
    repository: context.read<CommentRepository>(),
    postActions: context.read<PostActionsController>(),
  );

  @override
  void dispose() {
    _comments.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 1,
        builder: (context, scrollController) => Column(
          children: [
            Text('Comments', style: Theme.of(context).textTheme.titleMedium),
            Gaps.h8,
            const Divider(),
            Expanded(
              child: CommentsView(
                controller: _comments,
                scrollController: scrollController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
