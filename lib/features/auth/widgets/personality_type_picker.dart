import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../profile/models/profile_options.dart';

class PersonalityTypePicker extends StatelessWidget {
  const PersonalityTypePicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  static const String unset = '____';

  final String value;
  final ValueChanged<String> onChanged;

  void _toggle(int axisIndex) {
    final axis = PersonalityType.axes[axisIndex];
    final current = value[axisIndex];
    final next = current == axis.first.letter
        ? axis.second.letter
        : axis.first.letter;
    final letters = value.split('')..[axisIndex] = next;
    onChanged(letters.join());
  }

  @override
  Widget build(BuildContext context) {
    final complete = PersonalityType.isValid(value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 4 * 64 + 3 * 20),
          child: Row(
            children: [
              for (var i = 0; i < PersonalityType.axes.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(
                  child: _AxisTile(
                    axis: PersonalityType.axes[i],
                    letter: value[i],
                    onTap: () => _toggle(i),
                  ),
                ),
              ],
            ],
          ),
        ),
        Gaps.h24,
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            complete
                ? '$value · ${PersonalityType.describe(value)}'
                : 'Tap each box to choose a letter',
            key: ValueKey(complete ? value : 'hint'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: complete ? AppColors.primary : AppColors.textHint,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _AxisTile extends StatelessWidget {
  const _AxisTile({
    required this.axis,
    required this.letter,
    required this.onTap,
  });

  final PersonalityAxis axis;
  final String letter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final chosen = axis.traits.where((t) => t.letter == letter).firstOrNull;
    final active = chosen != null;
    return Semantics(
      button: true,
      label: '${axis.first.name} or ${axis.second.name}',
      value: chosen?.name,
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: AspectRatio(
              aspectRatio: 1,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(6.35),
                  border: Border.all(
                    color: active ? AppColors.primary : AppColors.border,
                    width: 1.27,
                  ),
                ),
                child: FittedBox(
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      active ? letter : axis.label,
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w500,
                        color: active ? AppColors.primary : AppColors.tileHint,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Gaps.h8,
          SizedBox(
            width: double.infinity,
            child: Text(
              chosen?.name ?? '',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
