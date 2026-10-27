import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/app_button.dart';

class BirthdayField extends StatelessWidget {
  const BirthdayField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.maximumDate,
  });

  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final DateTime maximumDate;

  Future<void> _pick(BuildContext context) async {
    var selected =
        value ??
        DateTime(maximumDate.year - 7, maximumDate.month, maximumDate.day);
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Date',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Gaps.h16,
              SizedBox(
                height: 200,
                child: CupertinoTheme(
                  data: const CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 20,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    dateOrder: DatePickerDateOrder.mdy,
                    initialDateTime: selected,
                    minimumYear: 1900,
                    maximumDate: maximumDate,
                    onDateTimeChanged: (date) => selected = date,
                  ),
                ),
              ),
              Gaps.h16,
              AppButton(
                label: 'Done',
                onPressed: () => Navigator.pop(context, selected),
              ),
            ],
          ),
        ),
      ),
    );
    if (picked != null) onChanged(DateUtils.dateOnly(picked));
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _pick(context),
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: InputDecorator(
        isEmpty: value == null,
        decoration: const InputDecoration(
          hintText: 'Select your birthday',
          prefixIcon: Icon(Icons.calendar_month_outlined, size: 20),
        ),
        child: Text(
          value == null ? '' : AppDateUtils.display(value!),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
