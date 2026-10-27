import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../core/widgets/paginated_list_view.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/comments_controller.dart';
import '../models/comment.dart';
import 'comment_composer.dart';
import 'comment_tile.dart';

class CommentsView extends StatefulWidget {
  const CommentsView({
    super.key,
    required this.controller,
    this.header,
    this.scrollController,
  });

  final CommentsController controller;
  final Widget? header;
  final ScrollController? scrollController;

  @override
  State<CommentsView> createState() => _CommentsViewState();
}

class _CommentsViewState extends State<CommentsView> {
  final _text = TextEditingController();
  final _focus = FocusNode();

  Future<bool> _send(String text) async {
    final auth = context.read<AuthController>();
    try {
      await widget.controller.addComment(
        content: text,
        authorUsername: auth.displayName,
        authorAvatarUrl: auth.profile?.avatarUrl,
      );
      return true;
    } catch (e) {
      if (mounted) context.showError(e);
      return false;
    }
  }

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return Column(
      children: [
        Expanded(
          child: PaginatedListView<Comment>(
            controller: controller,
            scrollController: widget.scrollController,
            header: widget.header,
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            empty: const EmptyView(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'No comments yet',
              message: 'Start the conversation.',
            ),
            itemBuilder: (context, comment, _) =>
                CommentTile(key: ValueKey(comment.id), comment: comment),
          ),
        ),
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) => CommentComposer(
            controller: _text,
            focusNode: _focus,
            isSending: controller.isSending,
            onSend: _send,
          ),
        ),
      ],
    );
  }
}
