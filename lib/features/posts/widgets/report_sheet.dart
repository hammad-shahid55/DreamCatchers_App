import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_svg_icon.dart';
import '../data/post_repository.dart';
import '../models/post.dart';

abstract final class ReportSheet {
  static const List<String> reasons = [
    'Threatening violence',
    'Hate',
    'Copyright violation',
    'Minor abuse or sexualization',
    'Harassment',
    'Sharing overly personal information',
    'Spam',
    'Non-consensual intimate media',
    'Impersonation',
    'Prohibited transaction',
    'Trademark violation',
    'Self-harm or suicide',
    'Others',
  ];

  static Future<void> show(BuildContext context, Post post) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _ReportBody(post: post),
    );
  }
}

class _ReportBody extends StatefulWidget {
  const _ReportBody({required this.post});

  final Post post;

  @override
  State<_ReportBody> createState() => _ReportBodyState();
}

class _ReportBodyState extends State<_ReportBody> {
  String? _reason;
  bool _isSending = false;

  Future<void> _submit() async {
    final reason = _reason;
    if (reason == null) {
      context.showMessage('Please choose a reason.', isError: true);
      return;
    }
    final details = await _ShareReportDialog.show(context, reason);
    if (details == null || !mounted) return;
    setState(() => _isSending = true);
    try {
      await context.read<PostRepository>().report(
        widget.post.id,
        reason,
        details: details,
      );
      if (!mounted) return;
      Navigator.pop(context);
      context.showMessage('Thanks for reporting. We\'ll look into it.');
    } catch (e) {
      if (mounted) context.showError(e);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.9,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.xl,
          AppSpacing.xl,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Stack(
              alignment: Alignment.center,
              children: [
                Align(alignment: Alignment.centerLeft, child: AppBackButton()),
                Text(
                  'Report An Issue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            Gaps.h24,
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thanks for looking out for yourself and your fellow '
                      'members by reporting things that break the rules. Let '
                      'us know what\'s happening, and we\'ll look into it.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.55,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Gaps.h16,
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (final reason in ReportSheet.reasons)
                          _ReasonChip(
                            label: reason,
                            selected: reason == _reason,
                            onTap: () => setState(() => _reason = reason),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Text(
              'You can also contact us at',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textBody),
            ),
            Gaps.h4,
            const SelectableText(
              AppConstants.supportEmail,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primary,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.primary,
              ),
            ),
            Gaps.h16,
            AppButton(
              label: 'Submit',
              isLoading: _isSending,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReasonChip extends StatelessWidget {
  const _ReasonChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? AppColors.primary : AppColors.background,
        shape: StadiumBorder(
          side: selected
              ? BorderSide.none
              : const BorderSide(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: selected
                    ? AppColors.textOnPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShareReportDialog extends StatefulWidget {
  const _ShareReportDialog({required this.reason});

  final String reason;

  static Future<String?> show(BuildContext context, String reason) =>
      showDialog<String>(
        context: context,
        builder: (_) => _ShareReportDialog(reason: reason),
      );

  @override
  State<_ShareReportDialog> createState() => _ShareReportDialogState();
}

class _ShareReportDialogState extends State<_ShareReportDialog> {
  final _details = TextEditingController();

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: SvgPicture.asset(
                  AppIcons.reportShare,
                  width: 74,
                  height: 74,
                ),
              ),
              Gaps.h16,
              const Text(
                'Share Report',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              Gaps.h16,
              TextField(
                controller: _details,
                minLines: 4,
                maxLines: 6,
                maxLength: 1000,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Report what happened...',
                  counterText: '',
                ),
              ),
              Gaps.h16,
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textHint,
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  Gaps.w12,
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context, _details.text),
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
