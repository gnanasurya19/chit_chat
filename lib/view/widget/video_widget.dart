import 'package:chit_chat/res/colors.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatefulWidget {
  const VideoWidget({
    super.key,
  });

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController controller;
  bool isVideoPlaying = false;
  @override
  void initState() {
    controller = VideoPlayerController.networkUrl(Uri.parse(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'));
    controller.initialize();
    controller.addListener(videoListener);
    super.initState();
  }

  void videoListener() {
    setState(() {
      isVideoPlaying = controller.value.isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () {
          if (controller.value.isCompleted) {
            controller.play();
          }
          if (controller.value.isPlaying) {
            controller.pause();
          } else {
            controller.play();
          }
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height / 2,
                  maxWidth: MediaQuery.sizeOf(context).width * 0.65),
              child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: VideoPlayer(controller)),
            ),
            if (!isVideoPlaying)
              Positioned(
                  child: IconButton.filled(
                      style: IconButton.styleFrom(
                          disabledBackgroundColor:
                              AppColor.black.withOpacity(0.4)),
                      onPressed: null,
                      icon: const Icon(
                        Icons.play_arrow_rounded,
                        color: AppColor.white,
                      )))
          ],
        ),
      ),
    );
  }
}
