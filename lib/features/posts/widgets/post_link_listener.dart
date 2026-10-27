import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_router.dart';
import '../../../core/utils/context_extensions.dart';
import '../../auth/controllers/auth_controller.dart';
import '../data/post_repository.dart';
import '../utils/post_links.dart';

class PostLinkListener extends StatefulWidget {
  const PostLinkListener({super.key, required this.child});

  final Widget child;

  @override
  State<PostLinkListener> createState() => _PostLinkListenerState();
}

class _PostLinkListenerState extends State<PostLinkListener> {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;
  late final AuthController _auth = context.read<AuthController>();
  String? _pendingPostId;
  String? _lastHandledUri;

  @override
  void initState() {
    super.initState();
    _auth.addListener(_openPending);
    _appLinks
        .getInitialLink()
        .then((uri) {
          if (uri != null) _onLink(uri);
        })
        .catchError((_) {});
    _subscription = _appLinks.uriLinkStream.listen(_onLink, onError: (_) {});
  }

  void _onLink(Uri uri) {
    if (uri.toString() == _lastHandledUri) return;
    final postId = PostLinks.postIdFrom(uri);
    if (postId == null) return;
    _lastHandledUri = uri.toString();
    _pendingPostId = postId;
    _openPending();
  }

  Future<void> _openPending() async {
    final postId = _pendingPostId;
    if (postId == null || _auth.status != AuthStatus.authenticated) return;
    _pendingPostId = null;
    final navigator = AppNavigator.key.currentState;
    if (navigator == null) return;
    try {
      final post = await context.read<PostRepository>().fetchPost(postId);
      await navigator.pushNamed(AppRoutes.postDetail, arguments: post);
    } catch (e) {
      final navContext = AppNavigator.key.currentContext;
      if (navContext != null && navContext.mounted) navContext.showError(e);
    }
  }

  @override
  void dispose() {
    _auth.removeListener(_openPending);
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
