import 'dart:async';

import '../models/post.dart';

sealed class PostEvent {
  const PostEvent();
}

class PostCreated extends PostEvent {
  const PostCreated(this.post);
  final Post post;
}

class PostPatched extends PostEvent {
  const PostPatched(this.postId, this.patch);
  final String postId;
  final Post Function(Post post) patch;
}

class PostDeleted extends PostEvent {
  const PostDeleted(this.postId);
  final String postId;
}

class AuthorAvatarChanged extends PostEvent {
  const AuthorAvatarChanged(this.authorId, this.avatarUrl);
  final String authorId;
  final String? avatarUrl;
}

class PostEventBus {
  final StreamController<PostEvent> _controller =
      StreamController<PostEvent>.broadcast(sync: true);

  Stream<PostEvent> get stream => _controller.stream;

  void emit(PostEvent event) {
    if (!_controller.isClosed) _controller.add(event);
  }

  void dispose() => _controller.close();
}
