enum PostMediaType {
  image,
  video;

  static PostMediaType? fromValue(Object? value) {
    for (final type in values) {
      if (type.name == value) return type;
    }
    return null;
  }
}

class Post {
  const Post({
    required this.id,
    required this.authorId,
    required this.authorUsername,
    required this.createdAt,
    this.authorAvatarUrl,
    this.title,
    this.content,
    this.mediaUrl,
    this.mediaPath,
    this.mediaType,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.isLiked = false,
    this.trendingScore,
  });

  final String id;
  final String authorId;
  final String authorUsername;
  final String? authorAvatarUrl;
  final String? title;
  final String? content;
  final String? mediaUrl;

  final String? mediaPath;
  final PostMediaType? mediaType;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final DateTime createdAt;
  final bool isLiked;
  final double? trendingScore;

  bool get hasTitle => title != null && title!.trim().isNotEmpty;
  bool get hasText => content != null && content!.trim().isNotEmpty;
  bool get hasMedia => mediaUrl != null && mediaType != null;
  int get interactionCount => likeCount + commentCount + shareCount;

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: json['id'] as String,
    authorId: json['author_id'] as String,
    authorUsername: json['author_username'] as String,
    authorAvatarUrl: json['author_avatar_url'] as String?,
    title: json['title'] as String?,
    content: json['content'] as String?,
    mediaUrl: json['media_url'] as String?,
    mediaPath: json['media_path'] as String?,
    mediaType: PostMediaType.fromValue(json['media_type']),
    likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
    commentCount: (json['comment_count'] as num?)?.toInt() ?? 0,
    shareCount: (json['share_count'] as num?)?.toInt() ?? 0,
    createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    isLiked: json['is_liked'] as bool? ?? false,
    trendingScore: (json['trending_score'] as num?)?.toDouble(),
  );

  Post withAuthorAvatar(String? url) => Post(
    id: id,
    authorId: authorId,
    authorUsername: authorUsername,
    authorAvatarUrl: url,
    title: title,
    content: content,
    mediaUrl: mediaUrl,
    mediaPath: mediaPath,
    mediaType: mediaType,
    createdAt: createdAt,
    trendingScore: trendingScore,
    likeCount: likeCount,
    commentCount: commentCount,
    shareCount: shareCount,
    isLiked: isLiked,
  );

  Post withText({String? title, String? content}) => Post(
    id: id,
    authorId: authorId,
    authorUsername: authorUsername,
    authorAvatarUrl: authorAvatarUrl,
    title: title,
    content: content,
    mediaUrl: mediaUrl,
    mediaPath: mediaPath,
    mediaType: mediaType,
    createdAt: createdAt,
    trendingScore: trendingScore,
    likeCount: likeCount,
    commentCount: commentCount,
    shareCount: shareCount,
    isLiked: isLiked,
  );

  Post copyWith({
    int? likeCount,
    int? commentCount,
    int? shareCount,
    bool? isLiked,
  }) => Post(
    id: id,
    authorId: authorId,
    authorUsername: authorUsername,
    authorAvatarUrl: authorAvatarUrl,
    title: title,
    content: content,
    mediaUrl: mediaUrl,
    mediaPath: mediaPath,
    mediaType: mediaType,
    createdAt: createdAt,
    trendingScore: trendingScore,
    likeCount: likeCount ?? this.likeCount,
    commentCount: commentCount ?? this.commentCount,
    shareCount: shareCount ?? this.shareCount,
    isLiked: isLiked ?? this.isLiked,
  );
}
