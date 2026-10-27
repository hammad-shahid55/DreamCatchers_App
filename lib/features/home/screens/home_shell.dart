import 'package:flutter/material.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_svg_icon.dart';
import '../../../core/widgets/brand_logo.dart';
import '../../posts/screens/feed_screen.dart';
import '../../profile/screens/profile_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  void _create() => Navigator.pushNamed(context, AppRoutes.createPost);

  @override
  Widget build(BuildContext context) {
    final body = IndexedStack(
      index: _tab,
      children: const [FeedScreen(), ProfileScreen()],
    );

    if (Responsive.isExpanded(context)) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _tab,
              onDestinationSelected: (i) => setState(() => _tab = i),
              labelType: NavigationRailLabelType.all,
              leading: Column(
                children: [
                  const BrandLogo(size: 40, showName: false),
                  const SizedBox(height: 20),
                  FloatingActionButton(
                    heroTag: 'create-post',
                    tooltip: 'Create post',
                    elevation: 0,
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    onPressed: _create,
                    child: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: AppSvgIcon(AppIcons.navHome),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: AppSvgIcon(AppIcons.navProfile),
                  label: Text('Profile'),
                ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        ),
      );
    }

    const createIndex = 1;
    return Scaffold(
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab == 0 ? 0 : 2,
        onDestinationSelected: (index) {
          if (index == createIndex) {
            _create();
          } else {
            setState(() => _tab = index > createIndex ? 1 : 0);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: AppSvgIcon(AppIcons.navHome),
            label: 'Home',
          ),
          NavigationDestination(
            icon: AppSvgIcon(AppIcons.navPost),
            label: 'Post',
          ),
          NavigationDestination(
            icon: AppSvgIcon(AppIcons.navProfile),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
