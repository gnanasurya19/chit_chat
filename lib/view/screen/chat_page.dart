// import 'package:cached_network_image/cached_network_image.dart';
// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chit_chat/controller/chat_cubit/chat_cubit.dart';
import 'package:chit_chat/controller/media_cubit/media_cubit.dart';
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
// import 'package:intl/intl.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
// import '../widget/file_upload_dialog.dart';

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
    BlocProvider.of<ChatCubit>(context).onInit(widget.userData.uid!);
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
    _chatRoomsCubit = BlocProvider.of<ChatCubit>(context);
    super.didChangeDependencies();
  }

  @override
  Future<void> dispose() async {
    messageController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _chatRoomsCubit.stopStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            splashRadius: 40,
            onPressed: () async {
              await BlocProvider.of<ChatCubit>(context).stopStream().then((e) {
                Navigator.pop(context);
              });
            },
            icon: const SVGIcon(
              name: 'arrow-left',
              color: AppColor.white,
              size: 20,
            )),
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
            Text(
                widget.userData.userName!.replaceRange(0, 1,
                    widget.userData.userName!.split('').first.toUpperCase()),
                style: style.text.boldMedium.copyWith(
                  color: AppColor.white,
                )),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        iconTheme: const IconThemeData(color: AppColor.white),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: Column(
          children: [
            Expanded(
              child: BlocConsumer<ChatCubit, ChatState>(
                listenWhen: (previous, current) => current is ChatActionState,
                listener: listener,
                buildWhen: (previous, current) => current is! ChatActionState,
                builder: (context, state) {
                  if (state is ChatReady) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        ListView.builder(
                          reverse: true,
                          controller: listScrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 5),
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
                                MessageBubble(widget: widget, message: message),
                              ],
                            );
                          },
                        ),
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
            ChatTextField(messageController: messageController, widget: widget),
          ],
        ),
      ),
    );
  }

  void listener(BuildContext context, ChatState state) {
    if (state is EmptyMessage) {
      util.showSnackbar(context, 'cannot send empty msg', 'error');
    } else if (state is UploadFile) {
      if (state.fileStatus == FileStatus.preview) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => FileUploadDialog(
            state: state,
          ),
        );
      }
    } else if (state is FileUploaded) {
      Navigator.pop(context);
      context.read<ChatCubit>().sendMessage(state.fileUrl, widget.userData,
          state.mediaType == MediaType.image ? 'image' : 'video');
    }
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.widget,
    required this.message,
  });

  final ChatPage widget;
  final MessageModel message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.userData.uid == message.senderID
          ? Alignment.centerLeft
          : Alignment.centerRight,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.7),
        margin: const EdgeInsets.only(bottom: 6),
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
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * 0.35),
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
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const Gap(5)
            ],
            if (message.messageType == 'video') ...[
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => ViewMediaPage(message: message)),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 5),
                      constraints: BoxConstraints(
                          maxHeight: MediaQuery.sizeOf(context).height * 0.35),
                      child: CachedNetworkImage(
                        imageUrl: message.thumbnail!,
                        placeholder: _loader,
                        errorWidget: _error,
                        fit: BoxFit.contain,
                      ),
                    ),
                    //static button used as icon
                    Positioned(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColor.black.withOpacity(0.4),
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
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  DateFormat('hh:mm a').format(message.timestamp!.toDate()),
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
