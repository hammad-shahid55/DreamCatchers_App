import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/max_width_box.dart';

class StepPage extends StatelessWidget {
  const StepPage({
    super.key,
    required this.title,
    required this.child,
    required this.primaryLabel,
    required this.onPrimary,
    this.subtitle,
    this.barTitle,
    this.progress,
    this.helper,
    this.isLoading = false,
    this.secondary,
    this.onBack,
    this.showBack = true,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  final String? barTitle;

  final double? progress;

  final Widget? helper;

  final String primaryLabel;
  final VoidCallback? onPrimary;
  final bool isLoading;

  final Widget? secondary;
  final VoidCallback? onBack;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasBar = barTitle != null;

    return Scaffold(
      appBar: hasBar
          ? AppTopBar(title: barTitle, showBack: showBack, onBack: onBack)
          : AppBar(
              automaticallyImplyLeading: false,
              shape: const Border(),
              leadingWidth: 56 + AppSpacing.sm,
              leading: showBack
                  ? Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.xl),
                      child: AppBackButton(onPressed: onBack),
                    )
                  : null,
            ),
      body: SafeArea(
        child: MaxWidthBox(
          maxWidth: Responsive.formMaxWidth + AppSpacing.xl * 2,
          child: Column(
            children: [
              if (progress != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.xl,
                    0,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(end: progress),
                      duration: const Duration(milliseconds: 300),
                      builder: (_, value, _) =>
                          LinearProgressIndicator(value: value, minHeight: 4),
                    ),
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    hasBar ? AppSpacing.xl : AppSpacing.sm,
                    AppSpacing.xl,
                    AppSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(title, style: textTheme.headlineSmall),
                      if (subtitle != null) ...[
                        Gaps.h8,
                        Text(
                          subtitle!,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      Gaps.h24,
                      child,
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  0,
                  AppSpacing.xl,
                  AppSpacing.lg,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (helper != null) ...[
                      DefaultTextStyle.merge(
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.55,
                        ),
                        child: helper!,
                      ),
                      Gaps.h16,
                    ],
                    AppButton(
                      label: primaryLabel,
                      isLoading: isLoading,
                      onPressed: onPrimary,
                    ),
                    if (secondary != null) ...[Gaps.h8, secondary!],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HelperText extends StatelessWidget {
  const HelperText(this.text, {super.key, this.emphasis, this.suffix = '.'});

  final String text;
  final String? emphasis;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: text,
        children: [
          if (emphasis != null) ...[
            TextSpan(
              text: emphasis,
              style: const TextStyle(
                color: AppColors.emphasis,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(text: suffix),
          ],
        ],
      ),
    );
  }
}
