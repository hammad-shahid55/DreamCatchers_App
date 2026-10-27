import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/system_ui.dart';
import '../../../core/widgets/brand_logo.dart';
import '../screens/get_started_screen.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key, this.onFinished});

  static const Duration duration = Duration(milliseconds: 1600);

  final VoidCallback? onFinished;

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: SplashView.duration)
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            Future.delayed(const Duration(milliseconds: 400), () {
              if (mounted) widget.onFinished?.call();
            });
          }
        });

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.waitUntilFirstFrameRasterized.then((_) {
      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) _controller.forward();
      });
    });
  }

  late final Animation<double> _logoFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.45, curve: Curves.easeOut),
  );
  late final Animation<double> _logoScale = Tween(begin: 0.8, end: 1.0).animate(
    CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.55, curve: Curves.easeOutBack),
    ),
  );
  late final Animation<double> _taglineFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.45, 0.85, curve: Curves.easeOut),
  );
  late final Animation<Offset> _taglineSlide =
      Tween(begin: const Offset(0, 0.6), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.45, 0.85, curve: Curves.easeOutCubic),
        ),
      );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemUi.gradientFull,
      child: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(gradient: AppColors.brandGradient),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: const BrandWordmark(fontSize: 52),
                  ),
                ),
                Gaps.h24,
                FadeTransition(
                  opacity: _taglineFade,
                  child: SlideTransition(
                    position: _taglineSlide,
                    child: Text(
                      GetStartedScreen.tagline,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
