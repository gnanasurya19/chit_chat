// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chit_chat/controller/media_cubit/media_cubit.dart';
import 'package:chit_chat/model/message_model.dart';
import 'package:chit_chat/res/colors.dart';
import 'package:chit_chat/res/common_instants.dart';
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
  VideoPlayerController? vpController;
  bool isVideoPlaying = false;
  bool isBuffering = true;
  int videoDuration = 0;
  bool isCompleted = false;

  @override
  void dispose() {
    if (vpController != null) {
      vpController!.removeListener(videoListener);
      vpController!.dispose();
    }
    super.dispose();
  }

  late MediaCubit controller;
  @override
  void initState() {
    controller = BlocProvider.of<MediaCubit>(context);
    controller.onInit();
    if (widget.message!.messageType == 'video') {
      final String filepath = widget.message!.message!;

      if (filepath.startsWith('http')) {
        vpController = VideoPlayerController.networkUrl(Uri.parse(filepath));
      } else {
        vpController = VideoPlayerController.file(File(filepath));
      }

      vpController!.initialize().then((_) {
        setState(() {
          videoDuration = vpController!.value.duration.inMilliseconds;
        });
        vpController!.addListener(videoListener);

        // ✅ Ensure video is ready before playing
        if (vpController!.value.isInitialized) {
          vpController!.play();
        }
      });

      BlocProvider.of<MediaCubit>(context).toggleStatusbar();
    }
    super.initState();
  }

  void videoListener() {
    setState(() {
      isVideoPlaying = vpController?.value.isPlaying ?? false;
      isBuffering = vpController?.value.isBuffering ?? false;
      isCompleted = vpController?.value.isCompleted ?? false;

      if (vpController?.value.isCompleted == true) {
        // vpController?.seekTo(Duration.zero);
        vpController?.pause();
        isCompleted = true;

        // ✅ Manually reset buffering state when video completes
        isBuffering = false;
      }

      seekPosition =
          vpController!.value.position.inMilliseconds / videoDuration;
    });
  }

  double seekPosition = 0;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
          statusBarColor: AppColor.black.withValues(alpha: 0.2)),
      child: Scaffold(
        backgroundColor: AppColor.black,
        body: BlocConsumer<MediaCubit, MediaState>(
          buildWhen: (previous, current) => current is! MediaActionState,
          listenWhen: (previous, current) => current is MediaActionState,
          listener: (context, state) {
            if (state is MediaDownloaded) {
              util.showSnackbar(
                  context, '${state.mediaType} Downloaded', 'success');
            }
          },
          builder: (context, state) {
            if (state is MediaInitial) {
              return GestureDetector(
                onTap: () {
                  BlocProvider.of<MediaCubit>(context).toggleStatusbar();
                  if (widget.message!.messageType == 'video') {
                    Future.delayed(const Duration(seconds: 4), () {
                      if (isVideoPlaying) {
                        if (mounted) {
                          BlocProvider.of<MediaCubit>(context)
                              .toggleStatusbar(true);
                        }
                      }
                    });
                  }
                },
                child: Container(
                  color: Colors.transparent,
                  constraints: const BoxConstraints.expand(),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        constraints: const BoxConstraints.expand(),
                        child: widget.message!.messageType == 'video'
                            ? AspectRatio(
                                aspectRatio: vpController!.value.aspectRatio,
                                child: VideoPlayer(
                                  vpController!,
                                ),
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
                                color: AppColor.black.withValues(alpha: 0.2),
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
                                                widget.message!.messageType!,
                                                context);
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
                                  inactiveTrackColor: AppColor.greyline,
                                  thumbShape: SliderComponentShape.noOverlay,
                                  overlayColor: Colors.transparent),
                              child: Slider(
                                value: seekPosition,
                                activeColor: AppColor.blue,
                                onChanged: (value) {
                                  setState(() {
                                    vpController!.seekTo(
                                      Duration(
                                        milliseconds:
                                            (value * videoDuration).truncate(),
                                      ),
                                    );
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
                                    AppColor.black.withValues(alpha: 0.4)),
                            onPressed: () {
                              vpController!.play();
                              setState(() => isCompleted = false);
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
                              backgroundColor:
                                  AppColor.black.withValues(alpha: 0.4)),
                          onPressed: () {
                            vpController!.pause();
                          },
                          icon: const Icon(
                            Icons.pause,
                            color: AppColor.white,
                          ),
                        ),
                      // buffer icon
                      if (!isCompleted &&
                          isBuffering &&
                          widget.message!.messageType == 'video')
                        SizedBox(
                          width: 45,
                          height: 45,
                          child: CircularProgressIndicator(
                            color: AppColor.white.withValues(alpha: 0.5),
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
