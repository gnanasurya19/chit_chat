import 'dart:io';

import 'package:chit_chat_1/res/colors.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPreview extends StatefulWidget {
  final String filepath;
  const VideoPreview({
    super.key,
    required this.filepath,
  });

  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  late VideoPlayerController controller;
  bool isVideoPlaying = false;
  @override
  void initState() {
    controller = VideoPlayerController.file(File(widget.filepath));
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
                      disabledBackgroundColor: AppColor.black.withOpacity(0.4)),
                  onPressed: null,
                  icon: const Icon(
                    Icons.play_arrow_rounded,
                    color: AppColor.white,
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
