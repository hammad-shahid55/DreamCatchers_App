import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/system_ui.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/brand_logo.dart';
import '../../../core/widgets/max_width_box.dart';
import '../widgets/auth_footer_link.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  static const String tagline = 'Anytime, Anywhere, Anyone';

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemUi.gradientTop,
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            final heroHeight = (constraints.maxHeight * 0.58).clamp(
              260.0,
              560.0,
            );
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    ClipPath(
                      clipper: _ArcClipper(),
                      child: Container(
                        height: heroHeight,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: AppColors.brandGradient,
                        ),
                        alignment: const Alignment(0, 0.1),
                        child: const SafeArea(
                          child: BrandWordmark(fontSize: 52),
                        ),
                      ),
                    ),
                    Gaps.h32,
                    MaxWidthBox(
                      maxWidth: Responsive.formMaxWidth + AppSpacing.xl * 2,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xl,
                          0,
                          AppSpacing.xl,
                          AppSpacing.xl,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              tagline,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textBody,
                              ),
                            ),
                            Gaps.h24,
                            AppButton(
                              label: 'Sign up',
                              onPressed: () => Navigator.pushNamed(
                                context,
                                AppRoutes.signUp,
                              ),
                            ),
                            Gaps.h8,
                            AuthFooterLink(
                              text: 'Already joined?',
                              action: 'Sign in',
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.signIn,
                              ),
                            ),
                            Gaps.h8,
                            const _TermsNotice(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final curve = size.height * 0.16;
    return Path()
      ..lineTo(0, size.height - curve)
      ..quadraticBezierTo(
        size.width / 2,
        size.height + curve,
        size.width,
        size.height - curve,
      )
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _TermsNotice extends StatelessWidget {
  const _TermsNotice();

  @override
  Widget build(BuildContext context) {
    const link = TextStyle(color: AppColors.primary);
    return const Text.rich(
      TextSpan(
        text:
            'Tapping “Sign up” Or “Sign in” means you '
            "understand and accept ${AppConstants.appName}'s ",
        children: [
          TextSpan(text: 'Privacy Policy', style: link),
          TextSpan(text: ' and '),
          TextSpan(text: 'Terms of Service', style: link),
          TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 22 / 12,
        color: AppColors.textDark,
      ),
    );
  }
}
