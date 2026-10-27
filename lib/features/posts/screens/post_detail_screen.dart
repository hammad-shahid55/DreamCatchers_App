import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/section_title.dart';
import '../../comments/controllers/comments_controller.dart';
import '../../comments/data/comment_repository.dart';
import '../../comments/widgets/comments_view.dart';
import '../controllers/post_actions_controller.dart';
import '../controllers/post_events.dart';
import '../models/post.dart';
import '../widgets/post_card.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key, required this.post});

  final Post post;

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late Post _post = widget.post;
  late final CommentsController _comments;
  late final StreamSubscription<PostEvent> _subscription;

  @override
  void initState() {
    super.initState();
    _comments = CommentsController(
      postId: _post.id,
      repository: context.read<CommentRepository>(),
      postActions: context.read<PostActionsController>(),
    );
    _subscription = context.read<PostEventBus>().stream.listen(_onPostEvent);
  }

  void _onPostEvent(PostEvent event) {
    if (!mounted) return;
    switch (event) {
      case PostPatched(:final postId, :final patch) when postId == _post.id:
        setState(() => _post = patch(_post));
      case PostDeleted(:final postId) when postId == _post.id:
        Navigator.of(context).maybePop();
      case AuthorAvatarChanged(:final authorId, :final avatarUrl)
          when authorId == _post.authorId:
        setState(() => _post = _post.withAuthorAvatar(avatarUrl));
      default:
        break;
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    _comments.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(),
      body: CommentsView(
        controller: _comments,
        header: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PostCard(post: _post, isDetail: true),
            const SectionTitle('Comments'),
          ],
        ),
      ),
    );
  }
}
