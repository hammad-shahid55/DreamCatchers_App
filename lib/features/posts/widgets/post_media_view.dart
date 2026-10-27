import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/post.dart';
import 'post_video_player.dart';

class PostMediaView extends StatelessWidget {
  const PostMediaView({super.key, required this.url, required this.type});

  final String url;
  final PostMediaType type;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: LayoutBuilder(
        builder: (context, box) => SizedBox(
          width: box.maxWidth,
          height: math.min(
            box.maxWidth / AppConstants.postMediaAspectRatio,
            MediaQuery.sizeOf(context).height * 0.7,
          ),
          child: switch (type) {
            PostMediaType.video => PostVideoPlayer(url: url),
            PostMediaType.image => LayoutBuilder(
              builder: (context, constraints) {
                final cacheWidth =
                    (constraints.maxWidth *
                            MediaQuery.devicePixelRatioOf(context))
                        .round();
                return CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  memCacheWidth: cacheWidth,
                  fadeInDuration: const Duration(milliseconds: 150),
                  placeholder: (_, _) =>
                      const ColoredBox(color: AppColors.surface),
                  errorWidget: (_, _, _) => const ColoredBox(
                    color: AppColors.surface,
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              },
            ),
          },
        ),
      ),
    );
  }
}
