import 'package:dreamcatchers/core/theme/app_colors.dart';
import 'package:dreamcatchers/core/theme/app_theme.dart';
import 'package:dreamcatchers/core/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<BuildContext> pumpHost(WidgetTester tester) async {
    late BuildContext captured;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) {
            captured = context;
            return const Scaffold(body: SizedBox.expand());
          },
        ),
      ),
    );
    return captured;
  }

  Color bannerColor(WidgetTester tester, String message) => tester
      .widget<Material>(
        find
            .ancestor(of: find.text(message), matching: find.byType(Material))
            .first,
      )
      .color!;

  testWidgets('success alert is blue, at the top and auto-hides', (
    tester,
  ) async {
    final context = await pumpHost(tester);
    context.showMessage('Posted!');
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Posted!'), findsOneWidget);
    expect(bannerColor(tester, 'Posted!'), AppColors.primary);
    final screenHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    expect(
      tester.getTopLeft(find.text('Posted!')).dy,
      lessThan(screenHeight / 4),
    );

    await tester.pump(const Duration(seconds: 4));
    expect(find.text('Posted!'), findsNothing);
  });

  testWidgets('error alert is red and replaces the previous one', (
    tester,
  ) async {
    final context = await pumpHost(tester);
    context.showMessage('First');
    await tester.pump(const Duration(milliseconds: 100));
    context.showMessage('Something failed', isError: true);
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('First'), findsNothing);
    expect(bannerColor(tester, 'Something failed'), AppColors.error);
    await tester.pump(const Duration(seconds: 4));
  });
}
