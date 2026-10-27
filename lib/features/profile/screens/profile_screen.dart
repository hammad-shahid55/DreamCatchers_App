import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/errors/error_mapper.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_dialogs.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/app_svg_icon.dart';
import '../../../core/widgets/max_width_box.dart';
import '../../../core/widgets/menu_card.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/controllers/auth_controller.dart';
import '../widgets/editable_avatar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirmed = await AppDialogs.confirm(
      context,
      message: 'You will need to sign in again to use DreamCatchers.',
      confirmLabel: 'Logout',
      icon: Icons.logout_rounded,
    );
    if (!confirmed || !context.mounted) return;
    try {
      await context.read<AuthController>().signOut();
    } catch (e) {
      if (context.mounted) context.showError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final profile = auth.profile;
    final error = auth.profileError;

    return Scaffold(
      appBar: const AppTopBar(title: 'User Profile', showBack: false),
      body: switch ((profile, error)) {
        (final profile?, _) => ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            MaxWidthBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ShadowCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        const EditableAvatar(size: 48),
                        Gaps.w12,
                        Expanded(
                          child: Text(
                            profile.username,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const GroupLabel('Profile and Activity'),
                  MenuCard(
                    icon: AppIcons.profile,
                    label: 'Personal Information',
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.personalInformation,
                    ),
                  ),
                  Gaps.h12,
                  MenuCard(
                    icon: AppIcons.posts,
                    label: 'My Posts',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.myPosts),
                  ),
                  Gaps.h24,
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => _logout(context),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      icon: const AppSvgIcon(
                        AppIcons.logout,
                        size: 20,
                        color: AppColors.error,
                      ),
                      label: const Text('Logout'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        (null, final error?) when !auth.isProfileLoading => ErrorView(
          message: friendlyError(error),
          onRetry: auth.loadProfile,
        ),
        _ => const AppLoader(),
      },
    );
  }
}
