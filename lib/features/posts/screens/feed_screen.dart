import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/keep_alive_page.dart';
import '../../../core/widgets/state_views.dart';
import '../controllers/post_events.dart';
import '../controllers/post_list_controllers.dart';
import '../data/post_repository.dart';
import '../widgets/post_list_view.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late final LatestPostsController _latest;
  late final TrendingPostsController _trending;

  @override
  void initState() {
    super.initState();
    final repository = context.read<PostRepository>();
    final events = context.read<PostEventBus>();
    _latest = LatestPostsController(repository, events);
    _trending = TrendingPostsController(repository, events);
  }

  @override
  void dispose() {
    _latest.dispose();
    _trending.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          shape: const Border(),
          titleSpacing: AppSpacing.xl,
          toolbarHeight: 64,
          title: const Text.rich(
            TextSpan(
              text: 'Discover ',
              children: [
                TextSpan(
                  text: 'Posts',
                  style: TextStyle(color: AppColors.primary),
                ),
              ],
            ),
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Latest'),
              Tab(text: 'Trending'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            KeepAlivePage(
              child: PostListView(
                controller: _latest,
                empty: EmptyView(
                  icon: Icons.dynamic_feed_rounded,
                  title: 'No posts yet',
                  message: 'Be the first to share something with everyone.',
                  action: FilledButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.createPost),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Create post'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(180, 48),
                    ),
                  ),
                ),
              ),
            ),
            KeepAlivePage(
              child: PostListView(
                controller: _trending,
                empty: const EmptyView(
                  icon: Icons.local_fire_department_rounded,
                  title: 'Nothing trending yet',
                  message:
                      'Posts with the most likes, comments and shares '
                      'will show up here.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
