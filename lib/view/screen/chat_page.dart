import 'dart:async';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chit_chat/controller/chat_cubit/chat_cubit.dart';
import 'package:chit_chat/model/message_model.dart';
import 'package:chit_chat/model/user_data.dart';
import 'package:chit_chat/res/colors.dart';
import 'package:chit_chat/res/common_instants.dart';
import 'package:chit_chat/res/custom_widget/svg_icon.dart';
import 'package:chit_chat/view/widget/chat_text_field.dart';
import 'package:chit_chat/view/widget/circular_profile_image.dart';
import 'package:chit_chat/view/widget/empty_chat.dart';
import 'package:chit_chat/view/widget/file_upload_dialog.dart';
import 'package:chit_chat/view/widget/view_media.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final UserData userData;
  const ChatPage({super.key, required this.userData});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  final TextEditingController messageController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  late ChatCubit _chatRoomsCubit;

  @override
  void initState() {
    super.initState();
    // decreaseBadgeCount();
    _chatRoomsCubit = BlocProvider.of<ChatCubit>(context);
    final lastMessage = widget.userData.lastMessage;
    _chatRoomsCubit.onInit(widget.userData.uid!, widget.userData);
    _chatRoomsCubit.changeBadgeCount(lastMessage?.status, lastMessage?.batch);
    notificationService.cancelGroupNotification(widget.userData.uid!);
    WidgetsBinding.instance.addObserver(this);
    listScrollController.addListener(listListener);
  }

  void listListener() {
    if (listScrollController.position.atEdge &&
        listScrollController.position.pixels ==
            listScrollController.position.maxScrollExtent) {
      BlocProvider.of<ChatCubit>(context).loadMore();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _chatRoomsCubit.pauseChatStream();
    } else if (state == AppLifecycleState.resumed) {
      _chatRoomsCubit.resumeChatStream();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Future<void> dispose() async {
    messageController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _chatRoomsCubit.stopStream();
    super.dispose();
  }

  bool canPop = true;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.read<ChatCubit>().deSelectAllMsg();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BlocBuilder<ChatCubit, ChatState>(
            buildWhen: (previous, current) => current is ChatSelectionState,
            builder: (context, state) {
              if (state is ChatMessageSelectedState) {
                return IconButton(
                  splashRadius: 40,
                  color: AppColor.white,
                  iconSize: style.icon.md,
                  icon: Icon(Icons.close_sharp),
                  onPressed: () {
                    _chatRoomsCubit.deSelectAllMsg();
                  },
                );
              } else {
                return IconButton(
                    splashRadius: 40,
                    onPressed: () {
                      _chatRoomsCubit.stopStream();
                      Navigator.pop(context);
                    },
                    icon: SVGIcon(
                      name: 'arrow-left',
                      color: AppColor.white,
                      size: style.icon.sm,
                    ));
              }
            },
          ),
          titleSpacing: 0,
          title: Row(
            children: [
              if (widget.userData.profileURL != null)
                Container(
                  width: 30,
                  height: 30,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: GestureDetector(
                    onTap: () {
                      if (widget.userData.profileURL != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ViewMediaPage(
                              message: MessageModel(
                                  message: widget.userData.profileURL,
                                  messageType: 'image'),
                            ),
                          ),
                        );
                      }
                    },
                    child: CircularProfileImage(
                      image: widget.userData.profileURL,
                      isNetworkImage: true,
                    ),
                  ),
                ),
              const Gap(10),
              InkWell(
                onTap: () {
                  context.read<ChatCubit>().justEmit();
                },
                child: Text(
                    widget.userData.userName!.replaceRange(
                        0,
                        1,
                        widget.userData.userName!
                            .split('')
                            .first
                            .toUpperCase()),
                    style: style.text.boldMedium.copyWith(
                      color: AppColor.white,
                    )),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          iconTheme: const IconThemeData(color: AppColor.white),
          actions: [
            BlocBuilder<ChatCubit, ChatState>(
              buildWhen: (previous, current) => current is ChatSelectionState,
              builder: (context, state) {
                if (state is ChatMessageSelectedState) {
                  return Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(style.insets.xs),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColor.white,
                        ),
                        child: Text(
                          '${state.selectedMsgCount}',
                          style: style.text.regular.copyWith(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary),
                        ),
                      ),
                      IconButton(
                        color: AppColor.white,
                        iconSize: style.icon.rg,
                        onPressed: () {
                          _chatRoomsCubit.showDeleteAlert();
                        },
                        icon: Icon(Icons.delete),
                      ),
                    ],
                  );
                } else {
                  return SizedBox();
                }
              },
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
          child: Column(
            children: [
              Expanded(
                child: BlocConsumer<ChatCubit, ChatState>(
                  listenWhen: (previous, current) =>
                      current is ChatActionState ||
                      current is ChatSelectionState,
                  listener: listener,
                  buildWhen: (previous, current) =>
                      current is! ChatActionState &&
                      current is! ChatSelectionState,
                  builder: (context, state) {
                    if (state is ChatReady) {
                      return Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          ListView.builder(
                            reverse: true,
                            // shrinkWrap: true,
                            controller: listScrollController,
                            itemCount: state.messageList.length,
                            itemBuilder: (context, index) {
                              final MessageModel message =
                                  state.messageList[index];
                              return Column(
                                children: [
                                  //date
                                  Builder(builder: (context) {
                                    if (index < state.messageList.length - 1 &&
                                        message.date ==
                                            state.messageList[index + 1].date) {
                                      return const SizedBox();
                                    } else {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Text('${message.date}'),
                                      );
                                    }
                                  }),
                                  //message bubble
                                  MessageBubble(
                                    widget: widget,
                                    message: message,
                                    isMsgsSelected: state.isMsgsSelected,
                                  ),
                                ],
                              );
                            },
                          ),

                          // load more progress indicator
                          if (state.loadingOldchat ?? false)
                            Positioned(
                              top: 10,
                              child: Container(
                                height: 30,
                                width: 30,
                                padding: const EdgeInsets.all(7),
                                decoration: const BoxDecoration(
                                    color: AppColor.white,
                                    shape: BoxShape.circle),
                                child: const CircularProgressIndicator(
                                  color: AppColor.blue,
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                        ],
                      );
                    } else if (state is ChatListEmpty) {
                      return EmptyChat(
                        onPress: () async {
                          context
                              .read<ChatCubit>()
                              .sendMessage('Hi', widget.userData, 'text');
                        },
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
              ),
              //chat field
              ChatTextField(
                  messageController: messageController, widget: widget),
            ],
          ),
        ),
      ),
    );
  }

  void listener(BuildContext context, ChatState state) {
    if (state is EmptyMessage) {
      util.showSnackbar(context, 'cannot send empty msg', 'error');
    } else if (state is OpenUploadFileDialog) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => const FileUploadDialog(),
      );
    } else if (state is FileUploaded) {
      Navigator.pop(context);
      context.read<ChatCubit>().sendMediaMessages(widget.userData);
    } else if (state is ChatMessageSelectedState) {
      setState(() => canPop = false);
    } else if (state is ChatMessgesDeselectedState) {
      setState(() => canPop = true);
    } else if (state is ChatDeleteDialogState) {
      util.showDeleteConfirmation(context, state.msgCount, state.isDeleteForAll,
          state.deleteForAll, state.deleteOnlyForMe);
    }
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.widget,
    required this.message,
    this.isMsgsSelected,
  });

  final ChatPage widget;
  final MessageModel message;
  final bool? isMsgsSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (isMsgsSelected ?? false) || message.isSelected == true
          ? () {
              context.read<ChatCubit>().selectMessages(message);
            }
          : null,
      onLongPress: !(isMsgsSelected ?? false)
          ? () {
              context.read<ChatCubit>().selectMessages(message);
            }
          : null,
      child: Stack(
        children: [
          Container(
            color: Colors.transparent,
            alignment: widget.userData.uid == message.senderID
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * 0.7),
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.inverseSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: widget.userData.uid == message.senderID
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                children: [
                  if (message.messageType == 'text')
                    SelectableText(
                      '${message.message}',
                      style: style.text.regular,
                    ),
                  if (message.messageType == 'image') ...[
                    Container(
                      width: MediaQuery.sizeOf(context).width * 0.7,
                      constraints: BoxConstraints(
                          maxHeight: MediaQuery.sizeOf(context).height * 0.45),
                      child: AspectRatio(
                        aspectRatio: (message.imageWidth ?? 1) /
                            (message.imageHeight ?? 1),
                        child: InkWell(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ViewMediaPage(
                                message: message,
                              ),
                            ),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: message.message!,
                            placeholder: _loader,
                            errorWidget: _error,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const Gap(5)
                  ],
                  if (message.messageType == 'video') ...[
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) =>
                                ViewMediaPage(message: message)),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: MediaQuery.sizeOf(context).width * 0.7,
                            margin: const EdgeInsets.only(bottom: 5),
                            constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.sizeOf(context).height * 0.45),
                            child: AspectRatio(
                              aspectRatio: (message.imageWidth ?? 1) /
                                  (message.imageHeight ?? 1),
                              child: CachedNetworkImage(
                                imageUrl: message.thumbnail!,
                                placeholder: _loader,
                                errorWidget: _error,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          //play button
                          Positioned(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColor.black.withValues(alpha: 0.4),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                color: AppColor.white,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                  if (message.messageType == 'audio') ...[
                    AudioMsgBubble(
                      key: Key(message.id ?? ''),
                      cubit: context.read<ChatCubit>(),
                      message: message,
                    ),
                  ],

                  // message info
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('hh:mm a')
                            .format(message.timestamp!.toDate()),
                        style: style.text.regularSmall,
                      ),
                      const Gap(3),
                      if (widget.userData.uid != message.senderID)
                        if (message.status == 'unread')
                          SVGIcon(
                            name: "check",
                            size: style.icon.xs,
                            color: AppColor.greyText,
                          )
                        else if (message.status == 'delivered')
                          SVGIcon(
                            name: "read",
                            size: style.icon.xs,
                            color: AppColor.greyText,
                          )
                        else ...[
                          SVGIcon(
                            name: "read",
                            size: style.icon.xs,
                            color: AppColor.blue,
                          ),
                        ]
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (message.isSelected == true)
            Positioned(
                top: 0,
                bottom: 0,
                width: MediaQuery.sizeOf(context).width,
                child: Container(
                  color: AppColor.blue.withValues(alpha: 0.3),
                ))
        ],
      ),
    );
  }
}

class AudioMsgBubble extends StatefulWidget {
  const AudioMsgBubble({
    super.key,
    required this.message,
    required this.cubit,
  });
  final MessageModel message;
  final ChatCubit cubit;

  @override
  State<AudioMsgBubble> createState() => _AudioMsgBubbleState();
}

class _AudioMsgBubbleState extends State<AudioMsgBubble>
    with SingleTickerProviderStateMixin {
  late final animationController =
      AnimationController(vsync: this, duration: Duration(milliseconds: 500));
  bool isPlaying = false;
  String duration = '0:00';
  late PlayerController playerCtl;
  StreamSubscription<int>? audioDurationSubscription;

  @override
  void initState() {
    super.initState();
    if (widget.message.isAudioUploading != true) {
      audioSetUp();
    } else {
      playerCtl = PlayerController();
    }
  }

  @override
  void dispose() {
    if (audioDurationSubscription != null) {
      audioDurationSubscription!.cancel();
    }
    super.dispose();
  }

  audioSetUp() async {
    isPlaying = widget.cubit.activeAudioId == widget.message.id;
    playerCtl = widget.cubit.getPlayerController(widget.message.id!);
    if (mounted) {
      audioDurationSubscription = playerCtl.onCurrentDurationChanged.listen(
        (event) => widget.cubit.changeAudioDuration(widget.message, event),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    isPlaying = widget.cubit.activeAudioId == widget.message.id;
    if (isPlaying) {
      animationController.forward();
    } else {
      animationController.reverse();
    }

    return Row(
      children: [
        IconButton(
          onPressed: () async {
            if (!(widget.message.isAudioDownloaded ?? false)) {
              widget.cubit.downloadAudio(widget.message.id!);
            } else if (!isPlaying) {
              widget.cubit.playAudioPlayer(
                  widget.message.id!, widget.message.audioUrl!);
              animationController.forward();
            } else {
              widget.cubit.pauseAudio();
              animationController.reverse();
            }
          },
          style: IconButton.styleFrom(backgroundColor: AppColor.blue),
          icon: widget.message.isAudioUploading == true
              ? Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 25,
                      width: 25,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.8,
                        color: AppColor.white,
                      ),
                    ),
                    Positioned(
                      child: Icon(
                        Icons.upload,
                        color: AppColor.white,
                        size: style.icon.sm,
                      ),
                    ),
                  ],
                )
              : widget.message.isAudioDownloading ?? false
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: AppColor.white,
                      ),
                    )
                  : ((widget.message.isAudioDownloaded ?? false) == false)
                      ? Icon(
                          Icons.download,
                          color: AppColor.white,
                        )
                      : AnimatedIcon(
                          icon: AnimatedIcons.play_pause,
                          progress: animationController),
          color: AppColor.white,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  return AudioFileWaveforms(
                    size: Size(constraints.maxWidth, 30),
                    enableSeekGesture: true,
                    waveformType: WaveformType.fitWidth,
                    playerWaveStyle: PlayerWaveStyle(
                      fixedWaveColor: AppColor.blackGrey,
                      liveWaveColor: AppColor.blue,
                    ),
                    playerController: playerCtl,
                    waveformData: widget.message.audioFormData ?? [],
                  );
                },
              ),
              Text(
                  "${widget.message.audioCurrentDuration}/${widget.message.audioDuration}"),
            ],
          ),
        )
      ],
    );
  }
}

Widget _loader(BuildContext context, String url) => Center(
      child: ColoredBox(
        color: AppColor.greyBg,
        child: Container(),
      ),
    );

Widget _error(BuildContext context, String url, dynamic error) {
  return const Center(child: Icon(Icons.error));
}
