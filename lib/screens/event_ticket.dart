import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final ValueNotifier<int>? selectedIndex;

  const VideoPlayerWidget(
      {Key? key, required this.videoUrl, this.selectedIndex})
      : super(key: key);

  @override
  VideoPlayerWidgetState createState() => VideoPlayerWidgetState();
}

class VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late CachedVideoPlayerPlusController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool _isPlaying = true;
  static const int homeTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller =
        CachedVideoPlayerPlusController.networkUrl(Uri.parse(widget.videoUrl));
    widget.selectedIndex?.addListener(_handleIndexChanged);
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      if (mounted) {
        _controller.play();
      }
    });
    _controller.setLooping(true);
    _controller.addListener(_videoPlayerListener);
  }

  void _videoPlayerListener() {
    if (_controller.value.isInitialized) {
      setState(() {});
    }
  }

  void _handleIndexChanged() {
    if (widget.selectedIndex?.value != homeTabIndex) {
      _controller.pause();
    } else if (widget.selectedIndex?.value == homeTabIndex &&
        !_controller.value.isPlaying) {
      _controller.play();
    }
  }

  @override
  void dispose() {
    widget.selectedIndex?.removeListener(_handleIndexChanged);
    _controller.removeListener(_videoPlayerListener);
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    _isPlaying ? _controller.play() : _controller.pause();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return VisibilityDetector(
            key: const Key('video_visibility'),
            onVisibilityChanged: (VisibilityInfo info) {
              if (info.visibleFraction == 0 && mounted) {
                setState(() {
                  _isPlaying = false;
                });
                _controller.pause();
              }
            },
            child: GestureDetector(
              onTap: _togglePlayPause,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: CachedVideoPlayerPlus(_controller),
                  ),
                  if (!_isPlaying)
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        size: 150,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                ],
              ),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
