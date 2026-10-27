import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/number_utils.dart';

class PostActionButton extends StatelessWidget {
  const PostActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.count,
    this.activeIcon,
    this.isActive = false,
  });

  final IconData icon;
  final IconData? activeIcon;

  final int? count;
  final VoidCallback? onTap;
  final String tooltip;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.textSecondary;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Icon(
                  isActive ? (activeIcon ?? icon) : icon,
                  key: ValueKey(isActive),
                  size: 20,
                  color: isActive ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: 6),
                Text(
                  NumberUtils.compact(count!),
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
