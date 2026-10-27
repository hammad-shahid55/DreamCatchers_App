import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/max_width_box.dart';
import '../../auth/controllers/auth_controller.dart';
import '../widgets/personal_info_list.dart';

class PersonalInformationScreen extends StatelessWidget {
  const PersonalInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final profile = auth.profile;
    return Scaffold(
      appBar: const AppTopBar(title: 'Personal Information'),
      body: profile == null
          ? const AppLoader()
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.sm,
                AppSpacing.xl,
                AppSpacing.xl,
              ),
              children: [
                MaxWidthBox(
                  child: PersonalInfoList(profile: profile, email: auth.email),
                ),
              ],
            ),
    );
  }
}
