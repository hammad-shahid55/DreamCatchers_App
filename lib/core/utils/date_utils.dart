import 'package:intl/intl.dart';

abstract final class AppDateUtils {
  static final DateFormat _display = DateFormat('MMMM d, yyyy');
  static final DateFormat _iso = DateFormat('yyyy-MM-dd');
  static final DateFormat _short = DateFormat('MMM d');

  static String display(DateTime date) => _display.format(date);

  static String isoDate(DateTime date) => _iso.format(date);

  static int ageFrom(DateTime birthday, [DateTime? now]) {
    final today = now ?? DateTime.now();
    var age = today.year - birthday.year;
    final hadBirthday =
        today.month > birthday.month ||
        (today.month == birthday.month && today.day >= birthday.day);
    if (!hadBirthday) age--;
    return age;
  }

  static String timeAgo(DateTime date, [DateTime? now]) {
    final current = now ?? DateTime.now();
    final diff = current.difference(date);
    if (diff.inSeconds < 60) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return date.year == current.year ? _short.format(date) : display(date);
  }
}
