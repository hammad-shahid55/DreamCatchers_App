import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../core/widgets/app_dialogs.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../posts/controllers/post_events.dart';

class EditableAvatar extends StatelessWidget {
  const EditableAvatar({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final profile = auth.profile;
    if (profile == null) return SizedBox.square(dimension: size);
    final busy = auth.isAvatarUpdating;
    final badge = size * 0.32 < 20 ? 20.0 : size * 0.32;

    return Semantics(
      button: true,
      label: 'Edit profile picture',
      child: GestureDetector(
        onTap: busy ? null : () => _showOptions(context),
        child: SizedBox.square(
          dimension: size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              UserAvatar(
                username: profile.username,
                imageUrl: profile.avatarUrl,
                size: size,
              ),
              if (busy)
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black38,
                    shape: BoxShape.circle,
                  ),
                  child: const AppLoader(size: 28, color: Colors.white),
                ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  width: badge,
                  height: badge,
                  decoration: BoxDecoration(
                    gradient: AppColors.brandGradient,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.background, width: 2),
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    size: badge * 0.55,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showOptions(BuildContext context) async {
    final hasPhoto = context.read<AuthController>().profile?.avatarUrl != null;
    final action = await showModalBottomSheet<_AvatarAction>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(
                hasPhoto ? 'Change photo from gallery' : 'Choose from gallery',
              ),
              onTap: () => Navigator.pop(context, _AvatarAction.gallery),
            ),
            if (!kIsWeb)
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take a photo'),
                onTap: () => Navigator.pop(context, _AvatarAction.camera),
              ),
            if (hasPhoto)
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                ),
                title: const Text(
                  'Remove photo',
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () => Navigator.pop(context, _AvatarAction.remove),
              ),
          ],
        ),
      ),
    );
    if (action == null || !context.mounted) return;

    final auth = context.read<AuthController>();
    final events = context.read<PostEventBus>();
    try {
      final String? url;
      if (action == _AvatarAction.remove) {
        final confirmed = await AppDialogs.confirm(
          context,
          message:
              'Your profile photo will be removed and your initials '
              'shown instead.',
          confirmLabel: 'Remove',
        );
        if (!confirmed) return;
        await auth.removeAvatar();
        url = null;
      } else {
        final image = await ImagePicker().pickImage(
          source: action == _AvatarAction.camera
              ? ImageSource.camera
              : ImageSource.gallery,
          maxWidth: AppConstants.avatarMaxSize,
          maxHeight: AppConstants.avatarMaxSize,
          imageQuality: 85,
          preferredCameraDevice: CameraDevice.front,
        );
        if (image == null) return;
        url = await auth.updateAvatar(image);
      }
      events.emit(AuthorAvatarChanged(auth.userId!, url));
      if (context.mounted) {
        context.showMessage(
          url == null ? 'Profile photo removed' : 'Profile photo updated',
        );
      }
    } catch (e) {
      if (context.mounted) context.showError(e);
    }
  }
}

enum _AvatarAction { gallery, camera, remove }
