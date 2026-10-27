import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exception.dart';
import '../models/comment.dart';

class CommentRepository {
  const CommentRepository(this._client);

  final SupabaseClient _client;

  List<Comment> _mapRows(Object? rows) => (rows as List<dynamic>)
      .map((row) => Comment.fromJson(row as Map<String, dynamic>))
      .toList(growable: false);

  Future<List<Comment>> fetchComments({
    required String postId,
    required int limit,
    Comment? after,
  }) async {
    final rows = await _client.rpc(
      'get_post_comments',
      params: {
        'p_post_id': postId,
        'p_limit': limit,
        'p_cursor_created_at': after?.createdAt.toUtc().toIso8601String(),
        'p_cursor_id': after?.id,
      },
    );
    return _mapRows(rows);
  }

  Future<Comment> addComment({
    required String postId,
    required String content,
    required String authorUsername,
    String? authorAvatarUrl,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw const AppException('Please sign in again.');
    final text = content.trim();
    if (text.isEmpty) throw const AppException('Comment cannot be empty.');

    final row = await _client
        .from('comments')
        .insert({'post_id': postId, 'author_id': userId, 'content': text})
        .select('id, created_at')
        .single();
    return Comment(
      id: row['id'] as String,
      postId: postId,
      authorId: userId,
      authorUsername: authorUsername,
      authorAvatarUrl: authorAvatarUrl,
      content: text,
      createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
    );
  }
}
