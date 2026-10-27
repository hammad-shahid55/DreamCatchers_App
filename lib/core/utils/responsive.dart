import 'package:flutter/widgets.dart';

enum WindowSize { compact, medium, expanded }

abstract final class Responsive {
  static const double mediumBreakpoint = 600;
  static const double expandedBreakpoint = 840;

  static const double contentMaxWidth = 640;

  static const double formMaxWidth = 480;

  static WindowSize sizeOf(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= expandedBreakpoint) return WindowSize.expanded;
    if (width >= mediumBreakpoint) return WindowSize.medium;
    return WindowSize.compact;
  }

  static bool isExpanded(BuildContext context) =>
      sizeOf(context) == WindowSize.expanded;

  static double centeringPadding(
    double available, [
    double maxWidth = contentMaxWidth,
  ]) => available > maxWidth ? (available - maxWidth) / 2 : 0;
}
