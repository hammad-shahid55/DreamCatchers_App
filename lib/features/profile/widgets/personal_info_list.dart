import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/menu_card.dart';
import '../models/profile.dart';

class PersonalInfoList extends StatelessWidget {
  const PersonalInfoList({super.key, required this.profile, this.email});

  final Profile profile;
  final String? email;

  @override
  Widget build(BuildContext context) {
    final birthday = profile.birthday;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const GroupLabel('Basic information', uppercase: true),
        _InfoCard(
          rows: [
            ('Username', profile.username),
            (
              'Birthday',
              birthday == null ? null : AppDateUtils.display(birthday),
            ),
            ('Email Address', email),
            ('Ethnicity', profile.ethnicity),
            ('Gender', profile.gender),
          ],
        ),
        Gaps.h16,
        const GroupLabel('Personal information', uppercase: true),
        _InfoCard(
          rows: [
            ('Personality Type', profile.personalityType),
            ('Relationship Status', profile.relationshipStatus?.label),
            ('Education Level', profile.educationLevel?.label),
          ],
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.rows});

  final List<(String, String?)> rows;

  @override
  Widget build(BuildContext context) {
    return ShadowCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              const Divider(indent: AppSpacing.lg, endIndent: AppSpacing.lg),
            _InfoRow(label: rows[i].$1, value: rows[i].$2 ?? '—'),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  void _showFull(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                Gaps.h12,
                SelectableText(
                  value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Gaps.h24,
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showFull(context),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          14,
          AppSpacing.md,
          14,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) => Row(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth * 0.55,
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Gaps.w12,
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Gaps.w8,
              const Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: AppColors.textPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
