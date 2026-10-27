import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/errors/error_mapper.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/user_avatar.dart';
import '../data/profile_repository.dart';
import '../models/profile.dart';

abstract final class UserProfileDialog {
  static Future<void> show(
    BuildContext context, {
    required String userId,
    required String username,
    String? avatarUrl,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => Provider.value(
        value: context.read<ProfileRepository>(),
        child: _UserProfileCard(
          userId: userId,
          username: username,
          avatarUrl: avatarUrl,
        ),
      ),
    );
  }
}

class _UserProfileCard extends StatefulWidget {
  const _UserProfileCard({
    required this.userId,
    required this.username,
    this.avatarUrl,
  });

  final String userId;
  final String username;
  final String? avatarUrl;

  @override
  State<_UserProfileCard> createState() => _UserProfileCardState();
}

class _UserProfileCardState extends State<_UserProfileCard> {
  late final Future<Profile> _profile = context
      .read<ProfileRepository>()
      .fetchProfile(widget.userId);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DottedAvatar(
                username: widget.username,
                avatarUrl: widget.avatarUrl,
              ),
              Gaps.h12,
              Text(
                widget.username,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Gaps.h16,
              const Text(
                'User Profile',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              Gaps.h8,
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: FutureBuilder<Profile>(
                  future: _profile,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Text(
                          friendlyError(snapshot.error!),
                          style: const TextStyle(color: AppColors.error),
                        ),
                      );
                    }
                    final profile = snapshot.data;
                    if (profile == null) {
                      return const Padding(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: AppLoader(size: 24),
                      );
                    }
                    final age = profile.age;
                    return Column(
                      children: [
                        _DetailRow('Gender', profile.gender ?? '—'),
                        const Divider(),
                        _DetailRow('Age', age == null ? '—' : '$age years'),
                      ],
                    );
                  },
                ),
              ),
              Gaps.h24,
              FilledButton(onPressed: () {}, child: const Text('Message')),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DottedAvatar extends StatelessWidget {
  const _DottedAvatar({required this.username, this.avatarUrl});

  final String username;
  final String? avatarUrl;

  static const List<(double, double, double)> _dots = [
    (34, 18, 10),
    (150, 4, 5),
    (176, 26, 12),
    (20, 66, 4),
    (186, 80, 5),
    (44, 98, 7),
    (66, 112, 4),
    (150, 112, 3),
    (120, 0, 3),
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 200,
        height: 120,
        child: Stack(
          children: [
            for (final (x, y, d) in _dots)
              Positioned(
                left: x,
                top: y,
                child: Container(
                  width: d,
                  height: d,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            Center(
              child: UserAvatar(
                username: username,
                imageUrl: avatarUrl,
                size: 88,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
