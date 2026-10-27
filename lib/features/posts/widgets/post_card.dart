import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../core/widgets/app_dialogs.dart';
import '../../../core/widgets/expandable_text.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../comments/widgets/comments_sheet.dart';
import '../controllers/post_actions_controller.dart';
import '../models/post.dart';
import 'post_action_bar.dart';
import 'post_header.dart';
import 'post_media_view.dart';
import 'report_sheet.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post, this.isDetail = false});

  final Post post;
  final bool isDetail;

  void _openDetail(BuildContext context) =>
      Navigator.pushNamed(context, AppRoutes.postDetail, arguments: post);

  void _edit(BuildContext context) =>
      Navigator.pushNamed(context, AppRoutes.createPost, arguments: post);

  Future<void> _share(BuildContext context) async {
    try {
      await context.read<PostActionsController>().share(post);
    } catch (e) {
      if (context.mounted) context.showError(e);
    }
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await AppDialogs.confirm(
      context,
      message: 'This removes the post, its likes and comments for everyone.',
      confirmLabel: 'Delete',
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed || !context.mounted) return;
    try {
      await context.read<PostActionsController>().delete(post);
      if (context.mounted) context.showMessage('Post deleted');
    } catch (e) {
      if (context.mounted) context.showError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = context.read<AuthController>().userId == post.authorId;
    final textStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(fontSize: isDetail ? 15 : 14);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PostHeader(
          post: post,
          large: isDetail,
          menu: isOwner
              ? [
                  ('Edit Post', () => _edit(context)),
                  ('Share Post', () => _share(context)),
                  ('Delete Post', () => _delete(context)),
                ]
              : [
                  ('Share Post', () => _share(context)),
                  ('Report', () => ReportSheet.show(context, post)),
                ],
        ),
        if (post.hasTitle) ...[
          Gaps.h12,
          Text(
            post.title!,
            style: TextStyle(
              fontSize: isDetail ? 18 : 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.35,
            ),
          ),
        ],
        if (post.hasText) ...[
          if (post.hasTitle) Gaps.h4 else Gaps.h12,
          isDetail
              ? SelectableText(post.content!, style: textStyle)
              : ExpandableText(post.content!, style: textStyle),
        ],
        if (post.hasMedia) ...[
          Gaps.h12,
          PostMediaView(url: post.mediaUrl!, type: post.mediaType!),
        ],
        Gaps.h4,
        Transform.translate(
          offset: const Offset(-AppSpacing.sm, 0),
          child: PostActionBar(
            post: post,
            onCommentTap: isDetail
                ? null
                : () => CommentsSheet.show(context, post),
          ),
        ),
      ],
    );

    if (isDetail) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          0,
        ),
        child: content,
      );
    }

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: 6,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            boxShadow: AppColors.cardShadow,
          ),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _openDetail(context),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.xs,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: content,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
