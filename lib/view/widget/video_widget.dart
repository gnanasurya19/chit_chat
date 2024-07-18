import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatelessWidget {
  final VideoPlayerController videoPlayerController;

  const VideoWidget({
    super.key,
    required this.videoPlayerController,
  });

  @override
  Widget build(BuildContext context) {
    return VideoPlayer(
      videoPlayerController,
    );
  }
}
