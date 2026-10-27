class Comment {
  const Comment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorUsername,
    required this.content,
    required this.createdAt,
    this.authorAvatarUrl,
  });

  final String id;
  final String postId;
  final String authorId;
  final String authorUsername;
  final String? authorAvatarUrl;
  final String content;
  final DateTime createdAt;

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    id: json['id'] as String,
    postId: json['post_id'] as String,
    authorId: json['author_id'] as String,
    authorUsername: json['author_username'] as String,
    authorAvatarUrl: json['author_avatar_url'] as String?,
    content: json['content'] as String,
    createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
  );
}
