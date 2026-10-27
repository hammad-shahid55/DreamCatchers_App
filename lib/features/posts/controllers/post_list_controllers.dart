import 'dart:async';

import '../../../core/constants/app_constants.dart';
import '../../../core/pagination/paginated_controller.dart';
import '../data/post_repository.dart';
import '../models/post.dart';
import 'post_events.dart';

abstract class PostListController extends PaginatedController<Post> {
  PostListController(this.repository, PostEventBus events)
    : super(pageSize: AppConstants.postsPageSize) {
    _subscription = events.stream.listen(_onEvent);
  }

  final PostRepository repository;
  late final StreamSubscription<PostEvent> _subscription;

  void _onEvent(PostEvent event) {
    switch (event) {
      case PostCreated(:final post):
        onPostCreated(post);
      case PostPatched(:final postId, :final patch):
        updateWhere((p) => p.id == postId, patch);
      case PostDeleted(:final postId):
        removeWhere((p) => p.id == postId);
      case AuthorAvatarChanged(:final authorId, :final avatarUrl):
        updateWhere(
          (p) => p.authorId == authorId,
          (p) => p.withAuthorAvatar(avatarUrl),
        );
    }
  }

  void onPostCreated(Post post) {}

  @override
  Object itemKey(Post item) => item.id;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class LatestPostsController extends PostListController {
  LatestPostsController(super.repository, super.events);

  @override
  Future<List<Post>> fetchPage(List<Post> loaded) => repository.fetchLatest(
    limit: pageSize,
    after: loaded.isEmpty ? null : loaded.last,
  );

  @override
  void onPostCreated(Post post) => insertFirst(post);
}

class TrendingPostsController extends PostListController {
  TrendingPostsController(super.repository, super.events);

  @override
  Future<List<Post>> fetchPage(List<Post> loaded) =>
      repository.fetchTrending(limit: pageSize, offset: loaded.length);
}

class UserPostsController extends PostListController {
  UserPostsController(super.repository, super.events, {required this.userId});

  final String userId;

  @override
  Future<List<Post>> fetchPage(List<Post> loaded) => repository.fetchLatest(
    limit: pageSize,
    after: loaded.isEmpty ? null : loaded.last,
    authorId: userId,
  );

  @override
  void onPostCreated(Post post) {
    if (post.authorId == userId) insertFirst(post);
  }
}
