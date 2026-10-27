import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../errors/error_mapper.dart';
import '../pagination/paginated_controller.dart';
import '../theme/app_spacing.dart';
import '../utils/context_extensions.dart';
import '../utils/responsive.dart';
import 'app_loader.dart';
import 'state_views.dart';

class PaginatedListView<T> extends StatefulWidget {
  const PaginatedListView({
    super.key,
    required this.controller,
    required this.itemBuilder,
    this.header,
    this.empty,
    this.padding = const EdgeInsets.symmetric(vertical: AppSpacing.sm),
    this.endMessage,
    this.scrollController,
  });

  final PaginatedController<T> controller;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget? header;
  final Widget? empty;
  final EdgeInsetsGeometry padding;

  final String? endMessage;

  final ScrollController? scrollController;

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.controller.loadInitial();
    });
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.axis == Axis.vertical &&
        notification.metrics.extentAfter < AppConstants.loadMoreThreshold) {
      widget.controller.loadMore();
    }
    return false;
  }

  Future<void> _refresh() async {
    final controller = widget.controller;
    await controller.refresh();
    final error = controller.error;
    if (error != null && controller.items.isNotEmpty && mounted) {
      context.showError(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final side = EdgeInsets.symmetric(
              horizontal: Responsive.centeringPadding(constraints.maxWidth),
            );
            return ListenableBuilder(
              listenable: widget.controller,
              builder: (context, _) => CustomScrollView(
                controller: widget.scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  if (widget.header case final header?)
                    SliverPadding(
                      padding: side,
                      sliver: SliverToBoxAdapter(child: header),
                    ),
                  for (final sliver in _buildBody())
                    SliverPadding(padding: side, sliver: sliver),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildBody() {
    final controller = widget.controller;
    final items = controller.items;

    if (!controller.hasLoaded) {
      final error = controller.error;
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: error != null
              ? ErrorView(
                  message: friendlyError(error),
                  onRetry: controller.refresh,
                )
              : const AppLoader(),
        ),
      ];
    }

    if (items.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: widget.empty ?? const EmptyView(title: 'Nothing here yet'),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: widget.padding,
        sliver: SliverList.builder(
          itemCount: items.length,
          itemBuilder: (context, index) =>
              widget.itemBuilder(context, items[index], index),
        ),
      ),
      SliverToBoxAdapter(child: _ListFooter<T>(controller, widget.endMessage)),
    ];
  }
}

class _ListFooter<T> extends StatelessWidget {
  const _ListFooter(this.controller, this.endMessage);

  final PaginatedController<T> controller;
  final String? endMessage;

  @override
  Widget build(BuildContext context) {
    final Widget child;
    if (controller.isLoadingMore) {
      child = const AppLoader(size: 24);
    } else if (controller.loadMoreError != null) {
      child = TextButton.icon(
        onPressed: controller.loadMore,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Couldn\'t load more. Tap to retry'),
      );
    } else if (!controller.hasMore && endMessage != null) {
      child = Text(endMessage!, style: Theme.of(context).textTheme.bodySmall);
    } else {
      child = const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      child: Center(child: child),
    );
  }
}
