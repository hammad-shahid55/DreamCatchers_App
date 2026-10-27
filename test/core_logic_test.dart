import 'package:flutter_test/flutter_test.dart';
import 'package:dreamcatchers/core/utils/date_utils.dart';
import 'package:dreamcatchers/core/utils/validators.dart';
import 'package:dreamcatchers/features/posts/models/post.dart';
import 'package:dreamcatchers/features/profile/models/profile_options.dart';

void main() {
  group('Validators', () {
    test('username', () {
      expect(Validators.username('ab'), isNotNull);
      expect(Validators.username('bad name'), isNotNull);
      expect(Validators.username('good_name.1'), isNull);
    });

    test('password must be strong', () {
      expect(Validators.password('Ab1!'), isNotNull);
      expect(Validators.password('abcdefg1!'), isNotNull);
      expect(Validators.password('ABCDEFG1!'), isNotNull);
      expect(Validators.password('Abcdefgh!'), isNotNull);
      expect(Validators.password('Abcdefg12'), isNotNull);
      expect(Validators.password('Dream@1234'), isNull);
    });

    test('birthday enforces minimum age', () {
      final now = DateTime.now();
      expect(Validators.birthday(DateTime(now.year - 10, 1, 1)), isNotNull);
      expect(Validators.birthday(DateTime(now.year - 30, 1, 1)), isNull);
    });
  });

  group('AppDateUtils', () {
    test('ageFrom respects birthday not yet reached', () {
      final now = DateTime(2026, 6, 15);
      expect(AppDateUtils.ageFrom(DateTime(2000, 6, 16), now), 25);
      expect(AppDateUtils.ageFrom(DateTime(2000, 6, 15), now), 26);
    });

    test('timeAgo', () {
      final now = DateTime(2026, 6, 15, 12);
      expect(
        AppDateUtils.timeAgo(now.subtract(const Duration(seconds: 5)), now),
        'now',
      );
      expect(
        AppDateUtils.timeAgo(now.subtract(const Duration(minutes: 5)), now),
        '5m',
      );
      expect(
        AppDateUtils.timeAgo(now.subtract(const Duration(hours: 3)), now),
        '3h',
      );
      expect(
        AppDateUtils.timeAgo(now.subtract(const Duration(days: 2)), now),
        '2d',
      );
    });
  });

  group('PersonalityType', () {
    test('validates 4-letter types', () {
      expect(PersonalityType.isValid('INFP'), isTrue);
      expect(PersonalityType.isValid('ESTJ'), isTrue);
      expect(PersonalityType.isValid('IN_P'), isFalse);
      expect(PersonalityType.isValid('XNFP'), isFalse);
      expect(PersonalityType.isValid(null), isFalse);
    });

    test('describe', () {
      expect(
        PersonalityType.describe('INFP'),
        'Introvert · Intuition · Feeling · Perceiving',
      );
    });
  });

  test('Post.fromJson maps RPC rows', () {
    final post = Post.fromJson({
      'id': 'p1',
      'author_id': 'u1',
      'author_username': 'sam',
      'author_avatar_url': null,
      'content': 'hello',
      'media_url': null,
      'media_path': null,
      'media_type': null,
      'like_count': 3,
      'comment_count': 2,
      'share_count': 1,
      'created_at': '2026-01-01T10:00:00+00:00',
      'is_liked': true,
      'trending_score': null,
    });
    expect(post.hasText, isTrue);
    expect(post.hasMedia, isFalse);
    expect(post.interactionCount, 6);
    expect(post.copyWith(likeCount: 4).likeCount, 4);
  });
}
