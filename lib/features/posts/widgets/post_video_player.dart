import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_loader.dart';

class PostVideoPlayer extends StatefulWidget {
  const PostVideoPlayer({super.key, required this.url});

  final String url;

  @override
  State<PostVideoPlayer> createState() => _PostVideoPlayerState();
}

class _PostVideoPlayerState extends State<PostVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitializing = false;
  bool _hasError = false;

  Future<void> _start() async {
    if (_isInitializing) return;
    setState(() {
      _isInitializing = true;
      _hasError = false;
    });
    final controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    try {
      await controller.initialize();
      await controller.setLooping(true);
      if (!mounted) {
        await controller.dispose();
        return;
      }
      await controller.play();
      setState(() => _controller = controller);
    } catch (_) {
      await controller.dispose();
      if (mounted) setState(() => _hasError = true);
    } finally {
      if (mounted) setState(() => _isInitializing = false);
    }
  }

  void _togglePlay() {
    final controller = _controller;
    if (controller == null) {
      _start();
      return;
    }
    controller.value.isPlaying ? controller.pause() : controller.play();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return GestureDetector(
      onTap: _togglePlay,
      child: ColoredBox(
        color: AppColors.mediaBackground,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (controller != null)
              FittedBox(
                fit: BoxFit.cover,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: controller.value.size.width,
                  height: controller.value.size.height,
                  child: VideoPlayer(controller),
                ),
              ),
            if (_isInitializing)
              const AppLoader(color: Colors.white)
            else if (_hasError)
              const Center(
                child: Icon(
                  Icons.error_outline,
                  color: Colors.white70,
                  size: 40,
                ),
              )
            else if (controller == null)
              const _PlayBadge()
            else
              ValueListenableBuilder<VideoPlayerValue>(
                valueListenable: controller,
                builder: (_, value, _) => AnimatedOpacity(
                  opacity: value.isPlaying ? 0 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: const _PlayBadge(),
                ),
              ),
            if (controller != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: VideoProgressIndicator(
                  controller,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PlayBadge extends StatelessWidget {
  const _PlayBadge();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
        ),
        child: const Padding(
          padding: EdgeInsets.all(14),
          child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40),
        ),
      ),
    );
  }
}
