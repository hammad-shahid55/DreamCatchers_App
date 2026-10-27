import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../models/picked_media.dart';
import '../models/post.dart';
import 'media_storage_service.dart';

class PostRepository {
  const PostRepository(this._client, this._storage);

  final SupabaseClient _client;
  final MediaStorageService _storage;

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw const AppException('Please sign in again.');
    return id;
  }

  List<Post> _mapRows(Object? rows) => (rows as List<dynamic>)
      .map((row) => Post.fromJson(row as Map<String, dynamic>))
      .toList(growable: false);

  Future<List<Post>> fetchLatest({
    required int limit,
    Post? after,
    String? authorId,
  }) async {
    final rows = await _client.rpc(
      'get_feed',
      params: {
        'p_limit': limit,
        'p_cursor_created_at': after?.createdAt.toUtc().toIso8601String(),
        'p_cursor_id': after?.id,
        'p_author_id': authorId,
      },
    );
    return _mapRows(rows);
  }

  Future<List<Post>> fetchTrending({
    required int limit,
    required int offset,
  }) async {
    final rows = await _client.rpc(
      'get_trending_posts',
      params: {
        'p_limit': limit,
        'p_offset': offset,
        'p_window_days': AppConstants.trendingWindowDays,
      },
    );
    return _mapRows(rows);
  }

  Future<Post> fetchPost(String postId) async {
    final rows = _mapRows(
      await _client.rpc('get_post', params: {'p_post_id': postId}),
    );
    if (rows.isEmpty) {
      throw const AppException('This post is no longer available.');
    }
    return rows.first;
  }

  Future<Post> createPost({
    required String authorUsername,
    String? authorAvatarUrl,
    String? title,
    String? content,
    PickedMedia? media,
  }) async {
    final userId = _userId;
    final heading = _clean(title);
    final body = _clean(content);
    if (heading == null && body == null && media == null) {
      throw const AppException('Write something or add a photo or video.');
    }

    final uploaded = media == null
        ? null
        : await _storage.upload(userId: userId, media: media);
    try {
      final row = await _client
          .from('posts')
          .insert({
            'author_id': userId,
            'title': heading,
            'content': body,
            'media_url': uploaded?.publicUrl,
            'media_path': uploaded?.path,
            'media_type': media?.type.name,
          })
          .select('id, created_at')
          .single();
      return Post(
        id: row['id'] as String,
        authorId: userId,
        authorUsername: authorUsername,
        authorAvatarUrl: authorAvatarUrl,
        title: heading,
        content: body,
        mediaUrl: uploaded?.publicUrl,
        mediaPath: uploaded?.path,
        mediaType: media?.type,
        createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
      );
    } catch (_) {
      if (uploaded != null) unawaited(_safeRemove(uploaded.path));
      rethrow;
    }
  }

  Future<Post> updatePost(Post post, {String? title, String? content}) async {
    final heading = _clean(title);
    final body = _clean(content);
    if (heading == null && body == null && !post.hasMedia) {
      throw const AppException('A post needs a title, text or media.');
    }
    await _client
        .from('posts')
        .update({'title': heading, 'content': body})
        .eq('id', post.id);
    return post.withText(title: heading, content: body);
  }

  static String? _clean(String? value) {
    final text = value?.trim();
    return text == null || text.isEmpty ? null : text;
  }

  Future<void> deletePost(Post post) async {
    await _client.from('posts').delete().eq('id', post.id);
    final path = post.mediaPath;
    if (path != null) unawaited(_safeRemove(path));
  }

  Future<void> like(String postId) async {
    try {
      await _client.from('post_likes').insert({
        'post_id': postId,
        'user_id': _userId,
      });
    } on PostgrestException catch (e) {
      if (e.code != '23505') rethrow;
    }
  }

  Future<void> unlike(String postId) => _client
      .from('post_likes')
      .delete()
      .match({'post_id': postId, 'user_id': _userId});

  Future<void> report(String postId, String reason, {String? details}) async {
    try {
      await _client.from('post_reports').insert({
        'post_id': postId,
        'reporter_id': _userId,
        'reason': reason,
        'details': _clean(details),
      });
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw const AppException('You have already reported this post.');
      }
      rethrow;
    }
  }

  Future<void> share(String postId) => _client.from('post_shares').insert({
    'post_id': postId,
    'user_id': _userId,
  });

  Future<void> _safeRemove(String path) async {
    try {
      await _storage.remove(path);
    } catch (_) {}
  }
}
