import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../profile/widgets/user_profile_dialog.dart';
import '../models/comment.dart';

class CommentTile extends StatelessWidget {
  const CommentTile({super.key, required this.comment});

  final Comment comment;

  @override
  Widget build(BuildContext context) {
    void openProfile() => UserProfileDialog.show(
      context,
      userId: comment.authorId,
      username: comment.authorUsername,
      avatarUrl: comment.authorAvatarUrl,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: 6,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: AppColors.cardShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: openProfile,
                    child: UserAvatar(
                      username: comment.authorUsername,
                      imageUrl: comment.authorAvatarUrl,
                      size: 26,
                    ),
                  ),
                  Gaps.w8,
                  Flexible(
                    child: GestureDetector(
                      onTap: openProfile,
                      child: Text(
                        comment.authorUsername,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    '  •  ${AppDateUtils.timeAgo(comment.createdAt)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
              Gaps.h8,
              Text(
                comment.content,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
