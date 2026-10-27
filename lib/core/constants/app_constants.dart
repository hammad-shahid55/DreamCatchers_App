abstract final class AppConstants {
  static const String appName = 'DreamCatchers';
  static const String tagline = 'Meet your people. Share your story.';

  static const String supportEmail = 'support@dreamcatchers.app';

  static const int postsPageSize = 10;
  static const int commentsPageSize = 20;
  static const double loadMoreThreshold = 800;

  static const int maxPostLength = 2000;
  static const int maxTitleLength = 120;
  static const int maxCommentLength = 1000;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;
  static const int minPasswordLength = 8;
  static const int minimumAge = 18;
  static const int maxMediaBytes = 50 * 1024 * 1024;
  static const int maxAvatarBytes = 5 * 1024 * 1024;

  static const double imageMaxWidth = 1600;
  static const double avatarMaxSize = 512;
  static const int imageQuality = 82;
  static const Duration maxVideoDuration = Duration(minutes: 2);
  static const double postMediaAspectRatio = 4 / 5;

  static const int trendingWindowDays = 30;

  static const Duration resendCooldown = Duration(seconds: 60);
}
