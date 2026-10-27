import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/max_width_box.dart';

class CommentComposer extends StatelessWidget {
  const CommentComposer({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSend,
    required this.isSending,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  final Future<bool> Function(String text) onSend;
  final bool isSending;

  Future<void> _send() async {
    final text = controller.text.trim();
    if (text.isEmpty || isSending) return;
    if (await onSend(text)) controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final roundedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      borderSide: BorderSide.none,
    );
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: MaxWidthBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.sm,
                  AppSpacing.sm,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        focusNode: focusNode,
                        minLines: 1,
                        maxLines: 4,
                        maxLength: AppConstants.maxCommentLength,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: 'Add a comment…',
                          counterText: '',
                          fillColor: AppColors.surface,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.md,
                          ),
                          border: roundedBorder,
                          enabledBorder: roundedBorder,
                          focusedBorder: roundedBorder.copyWith(
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Gaps.w4,
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: controller,
                      builder: (context, value, _) {
                        final enabled =
                            value.text.trim().isNotEmpty && !isSending;
                        return IconButton.filled(
                          tooltip: 'Send',
                          onPressed: enabled ? _send : null,
                          icon: isSending
                              ? const AppLoader(size: 20, color: Colors.white)
                              : const Icon(Icons.send_rounded),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
