import 'package:flutter/material.dart';

import '../../../core/widgets/paginated_list_view.dart';
import '../controllers/post_list_controllers.dart';
import '../models/post.dart';
import 'post_card.dart';

class PostListView extends StatelessWidget {
  const PostListView({
    super.key,
    required this.controller,
    required this.empty,
    this.header,
  });

  final PostListController controller;
  final Widget empty;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    return PaginatedListView<Post>(
      controller: controller,
      header: header,
      empty: empty,
      endMessage: 'You\'re all caught up',
      itemBuilder: (context, post, _) =>
          PostCard(key: ValueKey(post.id), post: post),
    );
  }
}
