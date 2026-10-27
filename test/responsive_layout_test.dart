import 'package:dreamcatchers/core/theme/app_theme.dart';
import 'package:dreamcatchers/core/widgets/app_text_field.dart';
import 'package:dreamcatchers/core/widgets/option_tile.dart';
import 'package:dreamcatchers/features/auth/screens/get_started_screen.dart';
import 'package:dreamcatchers/features/auth/widgets/birthday_field.dart';
import 'package:dreamcatchers/features/auth/widgets/personality_type_picker.dart';
import 'package:dreamcatchers/features/auth/widgets/step_page.dart';
import 'package:dreamcatchers/features/comments/models/comment.dart';
import 'package:dreamcatchers/features/comments/widgets/comment_tile.dart';
import 'package:dreamcatchers/features/profile/models/profile.dart';
import 'package:dreamcatchers/features/profile/models/profile_options.dart';
import 'package:dreamcatchers/features/profile/widgets/personal_info_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sizes = {
    'small phone': Size(320, 568),
    'phone landscape': Size(800, 360),
    'tablet': Size(1024, 1366),
    'desktop': Size(1440, 900),
  };

  Future<void> pumpAt(WidgetTester tester, Size size, Widget child) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: child));
    await tester.pump(const Duration(milliseconds: 400));
  }

  for (final MapEntry(key: name, value: size) in sizes.entries) {
    testWidgets('get started screen fits on $name', (tester) async {
      await pumpAt(tester, size, const GetStartedScreen());
      expect(tester.takeException(), isNull);
      expect(find.text(GetStartedScreen.tagline), findsOneWidget);
    });

    testWidgets('sign-up step pages fit on $name', (tester) async {
      await pumpAt(
        tester,
        size,
        StepPage(
          barTitle: 'Sign Up',
          progress: 0.5,
          title: 'What\'s your highest education level?',
          helper: const HelperText(
            'This will be shown on your profile. Username ',
            emphasis: 'cannot be changed',
          ),
          primaryLabel: 'Continue',
          onPrimary: () {},
          child: Column(
            children: [
              const AppTextField(hint: 'Username'),
              OptionList<EducationLevel>(
                options: EducationLevel.selectable,
                labelOf: (e) => e.label,
                selected: EducationLevel.bachelors,
                onSelected: (_) {},
              ),
              BirthdayField(
                value: DateTime(2000, 12, 23),
                maximumDate: DateTime(2008),
                onChanged: (_) {},
              ),
              PersonalityTypePicker(value: 'IN_P', onChanged: (_) {}),
            ],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('profile details and comments fit on $name', (tester) async {
      final profile = Profile(
        id: '1',
        username: 'a_really_long_username_here',
        createdAt: DateTime(2026),
        gender: 'Gender Nonconforming',
        ethnicity: 'Black/African-descent',
        relationshipStatus: RelationshipStatus.inARelationship,
        birthday: DateTime(1999, 9, 9),
        personalityType: 'ENFJ',
        educationLevel: EducationLevel.masters,
      );
      final comment = Comment(
        id: 'c1',
        postId: 'p1',
        authorId: '1',
        authorUsername: 'a_really_long_username_here',
        content: 'A long comment ' * 20,
        createdAt: DateTime.now(),
      );
      await pumpAt(
        tester,
        size,
        Scaffold(
          body: ListView(
            children: [
              PersonalInfoList(
                profile: profile,
                email: 'someone.with.long@email.com',
              ),
              CommentTile(comment: comment),
            ],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
