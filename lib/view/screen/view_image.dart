import 'package:cached_network_image/cached_network_image.dart';
import 'package:chit_chat/controller/media_cubit/media_cubit.dart';
import 'package:chit_chat/model/message_model.dart';
import 'package:chit_chat/res/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';

class ViewImagePage extends StatefulWidget {
  final MessageModel? message;
  const ViewImagePage({super.key, this.message});

  @override
  State<ViewImagePage> createState() => _ViewImagePageState();
}

class _ViewImagePageState extends State<ViewImagePage> {
  @override
  void initState() {
    BlocProvider.of<MediaCubit>(context).onInit();
    super.initState();
  }

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
                  BlocProvider.of<MediaCubit>(context).toggleStatusbar(state);
                },
                child: Container(
                  constraints: const BoxConstraints.expand(),
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Container(
                        constraints: const BoxConstraints.expand(),
                        child: PhotoView(
                          imageProvider: CachedNetworkImageProvider(
                            widget.message!.message!,
                            cacheKey: widget.message!.message,
                          ),
                        ),
                      ),
                      Positioned(
                          child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: state.isAppbarVisible ? 1 : 0,
                        child: SafeArea(
                          child: Container(
                            color: AppColor.black.withOpacity(0.2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  style: IconButton.styleFrom(
                                      foregroundColor: AppColor.white),
                                  onPressed: !state.isAppbarVisible
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
                                  enabled: state.isAppbarVisible,
                                  padding: EdgeInsets.zero,
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      child: const Text('Download'),
                                      onTap: () {
                                        controller.downloadImage(
                                            widget.message!.message!);
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
                      )),
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
