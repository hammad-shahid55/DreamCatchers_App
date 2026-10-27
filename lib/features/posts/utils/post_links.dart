import '../../../core/config/supabase_config.dart';
import '../models/post.dart';

abstract final class PostLinks {
  static const String _deepLinkHost = 'post';
  static const int _snippetLength = 120;

  static String webUrl(String postId) =>
      '${SupabaseConfig.url}/functions/v1/share?post=$postId';

  static String? postIdFrom(Uri uri) {
    if (uri.scheme != SupabaseConfig.appScheme || uri.host != _deepLinkHost) {
      return null;
    }
    return uri.pathSegments.isEmpty ? null : uri.pathSegments.first;
  }

  static String shareText(Post post) {
    final buffer = StringBuffer('@${post.authorUsername} on DreamCatchers');
    if (post.hasTitle || post.hasText) {
      final text = (post.hasTitle ? post.title! : post.content!).trim();
      final snippet = text.length > _snippetLength
          ? '${text.substring(0, _snippetLength).trimRight()}…'
          : text;
      buffer.write(':\n"$snippet"');
    }
    buffer.write('\n\n${webUrl(post.id)}');
    return buffer.toString();
  }
}
