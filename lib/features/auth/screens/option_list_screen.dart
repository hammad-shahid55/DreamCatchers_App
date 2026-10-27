import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/option_tile.dart';

class OptionListScreen extends StatefulWidget {
  const OptionListScreen({
    super.key,
    required this.title,
    required this.options,
    this.selected,
  });

  final String title;
  final List<String> options;
  final String? selected;

  static Future<String?> open(
    BuildContext context, {
    required String title,
    required List<String> options,
    String? selected,
  }) => Navigator.push<String>(
    context,
    MaterialPageRoute(
      builder: (_) =>
          OptionListScreen(title: title, options: options, selected: selected),
    ),
  );

  @override
  State<OptionListScreen> createState() => _OptionListScreenState();
}

class _OptionListScreenState extends State<OptionListScreen> {
  late String? _selected = widget.selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Sign Up'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                children: [
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Gaps.h16,
                  OptionList<String>(
                    options: widget.options,
                    labelOf: (o) => o,
                    selected: _selected,
                    onSelected: (o) => setState(() => _selected = o),
                  ),
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
                label: 'Continue',
                onPressed: _selected == null
                    ? null
                    : () => Navigator.pop(context, _selected),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
