import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum ToastType { success, error, info }

abstract final class AppToast {
  static const Duration _visibleFor = Duration(milliseconds: 2800);

  static OverlayEntry? _current;
  static GlobalKey<_ToastBannerState>? _currentKey;

  static void show(
    BuildContext context,
    String message, {
    ToastType type = ToastType.success,
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    _removeNow();

    final key = GlobalKey<_ToastBannerState>();
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastBanner(
        key: key,
        message: message,
        type: type,
        visibleFor: _visibleFor,
        onDismissed: () {
          if (_current == entry) {
            _current = null;
            _currentKey = null;
          }
          if (entry.mounted) entry.remove();
        },
      ),
    );
    _current = entry;
    _currentKey = key;
    overlay.insert(entry);
  }

  static void _removeNow() {
    final entry = _current;
    _current = null;
    _currentKey = null;
    if (entry != null && entry.mounted) entry.remove();
  }

  static void hide() => _currentKey?.currentState?._dismiss();
}

class _ToastBanner extends StatefulWidget {
  const _ToastBanner({
    super.key,
    required this.message,
    required this.type,
    required this.visibleFor,
    required this.onDismissed,
  });

  final String message;
  final ToastType type;
  final Duration visibleFor;
  final VoidCallback onDismissed;

  @override
  State<_ToastBanner> createState() => _ToastBannerState();
}

class _ToastBannerState extends State<_ToastBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
    reverseDuration: const Duration(milliseconds: 200),
  );
  late final Animation<Offset> _slide = Tween(
    begin: const Offset(0, -1.2),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  Timer? _timer;
  bool _dismissing = false;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _timer = Timer(widget.visibleFor, _dismiss);
  }

  Future<void> _dismiss() async {
    if (_dismissing || !mounted) return;
    _dismissing = true;
    _timer?.cancel();
    await _controller.reverse();
    widget.onDismissed();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (Color color, IconData icon) = switch (widget.type) {
      ToastType.success => (AppColors.primary, Icons.check_circle_rounded),
      ToastType.error => (AppColors.error, Icons.error_rounded),
      ToastType.info => (AppColors.textPrimary, Icons.info_rounded),
    };

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            0,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: SlideTransition(
                position: _slide,
                child: FadeTransition(
                  opacity: _controller,
                  child: Semantics(
                    liveRegion: true,
                    child: GestureDetector(
                      onTap: _dismiss,
                      onVerticalDragEnd: (d) {
                        if ((d.primaryVelocity ?? 0) < 0) _dismiss();
                      },
                      child: Material(
                        color: color,
                        elevation: 6,
                        shadowColor: color.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusLg,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Icon(icon, color: Colors.white, size: 22),
                              Gaps.w12,
                              Expanded(
                                child: Text(
                                  widget.message,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
