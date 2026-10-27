import 'package:intl/intl.dart';

abstract final class NumberUtils {
  static final NumberFormat _compact = NumberFormat.compact();

  static String compact(int value) => _compact.format(value);
}
