import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/picked_media.dart';
import '../models/post.dart';

class MediaAttachmentPreview extends StatelessWidget {
  const MediaAttachmentPreview({
    super.key,
    required this.media,
    required this.onRemove,
  });

  final PickedMedia media;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final bytes = media.bytes;
    final Widget preview = media.type == PostMediaType.image && bytes != null
        ? Image.memory(
            bytes,
            fit: BoxFit.cover,
            cacheWidth:
                (MediaQuery.sizeOf(context).width *
                        MediaQuery.devicePixelRatioOf(context))
                    .round(),
          )
        : ColoredBox(
            color: AppColors.mediaBackground,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.videocam_rounded,
                  color: Colors.white,
                  size: 48,
                ),
                Gaps.h8,
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Text(
                    media.file.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Stack(
          fit: StackFit.expand,
          children: [
            preview,
            Positioned(
              top: AppSpacing.sm,
              right: AppSpacing.sm,
              child: IconButton.filled(
                tooltip: 'Remove',
                onPressed: onRemove,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.close_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
