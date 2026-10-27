import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/dashed_border_box.dart';
import '../../../core/widgets/max_width_box.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/create_post_controller.dart';
import '../controllers/post_events.dart';
import '../data/post_repository.dart';
import '../models/post.dart';
import '../widgets/media_attachment_preview.dart';
import '../widgets/post_media_view.dart';

class CreatePostScreen extends StatelessWidget {
  const CreatePostScreen({super.key, this.editing});

  final Post? editing;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CreatePostController(
        context.read<PostRepository>(),
        context.read<PostEventBus>(),
        editing: editing,
      ),
      child: const _CreatePostView(),
    );
  }
}

class _CreatePostView extends StatelessWidget {
  const _CreatePostView();

  static const TextStyle _fieldText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle _placeholder = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  Future<void> _submit(BuildContext context) async {
    final controller = context.read<CreatePostController>();
    final auth = context.read<AuthController>();
    context.unfocus();
    try {
      await controller.submit(
        authorUsername: auth.displayName,
        authorAvatarUrl: auth.profile?.avatarUrl,
      );
      if (!context.mounted) return;
      context.showMessage(controller.isEditing ? 'Post updated' : 'Posted!');
      Navigator.pop(context);
    } catch (e) {
      if (context.mounted) context.showError(e);
    }
  }

  Future<void> _pick(BuildContext context, Future<void> Function() pick) async {
    try {
      await pick();
    } catch (e) {
      if (context.mounted) context.showError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<CreatePostController>();
    final isSubmitting = context.select(
      (CreatePostController c) => c.isSubmitting,
    );
    final canSubmit = context.select((CreatePostController c) => c.canSubmit);
    final media = context.select((CreatePostController c) => c.media);
    final editing = controller.editing;

    final Widget mediaSection;
    if (editing != null) {
      mediaSection = editing.hasMedia
          ? PostMediaView(url: editing.mediaUrl!, type: editing.mediaType!)
          : const SizedBox.shrink();
    } else if (media != null) {
      mediaSection = MediaAttachmentPreview(
        media: media,
        onRemove: isSubmitting ? null : controller.removeMedia,
      );
    } else {
      mediaSection = Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: DashedBorderBox(
          onTap: isSubmitting ? null : () => _chooseMedia(context, controller),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 13),
            child: Center(
              child: Text(
                '+ Add photos and videos',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return PopScope(
      canPop: !isSubmitting,
      child: Scaffold(
        appBar: AppTopBar(
          title: controller.isEditing ? 'Edit Post' : 'Create A Post',
          onBack: isSubmitting ? () {} : null,
          bottom: isSubmitting
              ? const PreferredSize(
                  preferredSize: Size.fromHeight(3),
                  child: LinearProgressIndicator(minHeight: 3),
                )
              : null,
        ),
        body: SafeArea(
          child: MaxWidthBox(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    children: [
                      TextField(
                        controller: controller.title,
                        enabled: !isSubmitting,
                        maxLength: AppConstants.maxTitleLength,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.next,
                        style: _fieldText,
                        decoration: const InputDecoration(
                          hintText: 'Title',
                          hintStyle: _placeholder,
                          counterText: '',
                        ),
                      ),
                      Gaps.h12,
                      TextField(
                        controller: controller.text,
                        enabled: !isSubmitting,
                        minLines: 6,
                        maxLines: 12,
                        maxLength: AppConstants.maxPostLength,
                        textCapitalization: TextCapitalization.sentences,
                        style: _fieldText,
                        decoration: const InputDecoration(
                          hintText: 'Description...',
                          hintStyle: _placeholder,
                        ),
                      ),
                      Gaps.h16,
                      mediaSection,
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    0,
                    AppSpacing.xl,
                    AppSpacing.lg,
                  ),
                  child: AppButton(
                    label: controller.isEditing ? 'Save' : 'Post',
                    isLoading: isSubmitting,
                    onPressed: canSubmit ? () => _submit(context) : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _chooseMedia(
    BuildContext context,
    CreatePostController controller,
  ) async {
    final choice = await showModalBottomSheet<Future<void> Function()>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_outlined),
              title: const Text('Photo from gallery'),
              onTap: () => Navigator.pop(
                sheet,
                () => controller.pickImage(ImageSource.gallery),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.videocam_outlined),
              title: const Text('Video from gallery'),
              onTap: () => Navigator.pop(
                sheet,
                () => controller.pickVideo(ImageSource.gallery),
              ),
            ),
            if (!kIsWeb)
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take a photo'),
                onTap: () => Navigator.pop(
                  sheet,
                  () => controller.pickImage(ImageSource.camera),
                ),
              ),
          ],
        ),
      ),
    );
    if (choice != null && context.mounted) await _pick(context, choice);
  }
}
