import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/user_avatar.dart';
import '../models/post.dart';

class PostHeader extends StatelessWidget {
  const PostHeader({
    super.key,
    required this.post,
    this.menu = const [],
    this.large = false,
  });

  final Post post;

  final List<(String, VoidCallback)> menu;

  final bool large;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        UserAvatar(
          username: post.authorUsername,
          imageUrl: post.authorAvatarUrl,
          size: large ? 36 : 32,
        ),
        Gaps.w8,
        Flexible(
          child: Text(
            post.authorUsername,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: large ? 18 : 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          '  •  ${AppDateUtils.timeAgo(post.createdAt)}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textHint,
          ),
        ),
        const Spacer(),
        if (menu.isNotEmpty)
          PopupMenuButton<VoidCallback>(
            tooltip: 'More',
            icon: const Icon(
              Icons.more_horiz_rounded,
              color: AppColors.textPrimary,
            ),
            color: AppColors.background,
            surfaceTintColor: Colors.transparent,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            onSelected: (action) => action(),
            itemBuilder: (_) => [
              for (final (label, action) in menu) _menuItem(label, action),
            ],
          ),
      ],
    );
  }

  PopupMenuItem<VoidCallback> _menuItem(String label, VoidCallback action) =>
      PopupMenuItem(
        value: action,
        height: 36,
        child: Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      );
}
