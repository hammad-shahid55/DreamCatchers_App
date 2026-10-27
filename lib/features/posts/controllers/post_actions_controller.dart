import 'dart:math' as math;

import 'package:share_plus/share_plus.dart';

import '../data/post_repository.dart';
import '../models/post.dart';
import '../utils/post_links.dart';
import 'post_events.dart';

class PostActionsController {
  PostActionsController(this._repository, this._events);

  final PostRepository _repository;
  final PostEventBus _events;
  final Set<String> _pendingLikes = <String>{};

  Future<void> toggleLike(Post post) async {
    if (!_pendingLikes.add(post.id)) return;
    final like = !post.isLiked;
    _patchLike(post.id, like);
    try {
      like
          ? await _repository.like(post.id)
          : await _repository.unlike(post.id);
    } catch (_) {
      _patchLike(post.id, !like);
      rethrow;
    } finally {
      _pendingLikes.remove(post.id);
    }
  }

  void _patchLike(String postId, bool liked) => _events.emit(
    PostPatched(
      postId,
      (p) => p.copyWith(
        isLiked: liked,
        likeCount: math.max(0, p.likeCount + (liked ? 1 : -1)),
      ),
    ),
  );

  Future<void> share(Post post) async {
    _patchShares(post.id, 1);
    try {
      await _repository.share(post.id);
    } catch (_) {
      _patchShares(post.id, -1);
      rethrow;
    }
    await SharePlus.instance.share(
      ShareParams(
        text: PostLinks.shareText(post),
        subject: 'Post by @${post.authorUsername} on DreamCatchers',
      ),
    );
  }

  void _patchShares(String postId, int delta) => _events.emit(
    PostPatched(
      postId,
      (p) => p.copyWith(shareCount: math.max(0, p.shareCount + delta)),
    ),
  );

  void commentAdded(String postId) => _events.emit(
    PostPatched(postId, (p) => p.copyWith(commentCount: p.commentCount + 1)),
  );

  Future<void> delete(Post post) async {
    await _repository.deletePost(post);
    _events.emit(PostDeleted(post.id));
  }
}
