import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chit_chat/controller/media_cubit/media_cubit.dart';
import 'package:chit_chat/model/message_model.dart';
import 'package:chit_chat/res/colors.dart';
import 'package:chit_chat/view/widget/video_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';

class ViewMediaPage extends StatefulWidget {
  final MessageModel? message;
  const ViewMediaPage({super.key, this.message});

  @override
  State<ViewMediaPage> createState() => _ViewMediaPageState();
}

class _ViewMediaPageState extends State<ViewMediaPage> {
  late VideoPlayerController vcController;
  bool isVideoPlaying = false;
  bool isBuffering = false;
  int videoDuration = 0;

  @override
  void initState() {
    BlocProvider.of<MediaCubit>(context).onInit();
    if (widget.message!.messageType == 'video') {
      final String filepath = widget.message!.message!;

      if (filepath.startsWith('http')) {
        vcController = VideoPlayerController.networkUrl(Uri.parse(filepath));
      } else {
        vcController = VideoPlayerController.file(File(filepath));
      }

      vcController
        ..initialize().then((v) {
          videoDuration = vcController.value.duration.inMilliseconds;
          vcController.addListener(videoListener);
        })
        ..play();
      BlocProvider.of<MediaCubit>(context).toggleStatusbar();
    }
    super.initState();
  }

  void videoListener() {
    setState(() {
      isVideoPlaying = vcController.value.isPlaying;
      isBuffering = vcController.value.isBuffering;
      seekPosition = vcController.value.position.inMilliseconds / videoDuration;
    });
  }

  double seekPosition = 0;

  final controller = MediaCubit();
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value:
          SystemUiOverlayStyle(statusBarColor: AppColor.black.withOpacity(0.2)),
      child: Scaffold(
        backgroundColor: AppColor.black,
        body: BlocBuilder<MediaCubit, MediaState>(
          builder: (context, state) {
            if (state is MediaInitial) {
              return GestureDetector(
                onTap: () {
                  BlocProvider.of<MediaCubit>(context).toggleStatusbar();
                  if (widget.message!.messageType == 'video') {
                    Future.delayed(const Duration(seconds: 4), () {
                      if (isVideoPlaying) {
                        BlocProvider.of<MediaCubit>(context)
                            .toggleStatusbar(true);
                      }
                    });
                  }
                },
                child: Container(
                  constraints: const BoxConstraints.expand(),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        constraints: const BoxConstraints.expand(),
                        child: widget.message!.messageType == 'video'
                            ? VideoWidget(
                                videoPlayerController: vcController,
                              )
                            : PhotoView(
                                imageProvider: CachedNetworkImageProvider(
                                  widget.message!.message!,
                                  cacheKey: widget.message!.message,
                                ),
                              ),
                      ),

                      //Appbar
                      Positioned(
                        top: 0,
                        child: SizedBox(
                          width: MediaQuery.sizeOf(context).width,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: state.iscontentVisible ? 1 : 0,
                            child: SafeArea(
                              child: Container(
                                color: AppColor.black.withOpacity(0.2),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      style: IconButton.styleFrom(
                                          foregroundColor: AppColor.white),
                                      onPressed: !state.iscontentVisible
                                          ? null
                                          : () {
                                              Navigator.pop(context);
                                            },
                                      icon: const Icon(Icons.arrow_back),
                                    ),
                                    PopupMenuButton(
                                      iconColor: AppColor.white,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .inverseSurface,
                                      enabled: state.iscontentVisible,
                                      padding: EdgeInsets.zero,
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          child: const Text('Download'),
                                          onTap: () {
                                            controller.downloadMedia(
                                                widget.message!.message!,
                                                widget.message!.messageType!);
                                          },
                                        ),
                                        PopupMenuItem(
                                          child: const Text('Share'),
                                          onTap: () {
                                            controller.shareFile(
                                                widget.message!.message!);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // duration slider
                      if (state.iscontentVisible &&
                          widget.message!.messageType == 'video')
                        Positioned(
                          bottom: 30,
                          child: SizedBox(
                            width: MediaQuery.sizeOf(context).width,
                            child: SliderTheme(
                              data: SliderThemeData(
                                  thumbShape: SliderComponentShape.noOverlay,
                                  overlayColor: Colors.transparent),
                              child: Slider(
                                value: seekPosition,
                                onChanged: (value) {
                                  setState(() {
                                    vcController.seekTo(Duration(
                                        milliseconds: (value * videoDuration)
                                            .truncate()));
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      //play button
                      if (!isVideoPlaying &&
                          !isBuffering &&
                          widget.message!.messageType == 'video')
                        Positioned(
                          child: IconButton.filled(
                            style: IconButton.styleFrom(
                                backgroundColor:
                                    AppColor.black.withOpacity(0.4)),
                            onPressed: () {
                              vcController.play();
                              Future.delayed(const Duration(seconds: 3), () {
                                BlocProvider.of<MediaCubit>(context)
                                    .toggleStatusbar(true);
                              });
                            },
                            icon: const Icon(
                              Icons.play_arrow_rounded,
                              color: AppColor.white,
                            ),
                          ),
                        ),
                      // pause button
                      if (isVideoPlaying && state.iscontentVisible)
                        IconButton.filled(
                          style: IconButton.styleFrom(
                              backgroundColor: AppColor.black.withOpacity(0.4)),
                          onPressed: () {
                            vcController.pause();
                          },
                          icon: const Icon(
                            Icons.pause,
                            color: AppColor.white,
                          ),
                        ),
                      // buffer icon
                      if (isBuffering && widget.message!.messageType == 'video')
                        SizedBox(
                          width: 45,
                          height: 45,
                          child: CircularProgressIndicator(
                            color: AppColor.white.withOpacity(0.5),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }
}
