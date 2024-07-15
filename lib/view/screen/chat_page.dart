import 'package:cached_network_image/cached_network_image.dart';
import 'package:chit_chat/controller/chat_cubit/chat_cubit.dart';
import 'package:chit_chat/model/message_model.dart';
import 'package:chit_chat/model/user_data.dart';
import 'package:chit_chat/res/colors.dart';
import 'package:chit_chat/res/custom_widget/svg_icon.dart';
import 'package:chit_chat/res/fonts.dart';
import 'package:chit_chat/view/widget/circular_profile_image.dart';
import 'package:chit_chat/view/widget/empty_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';
import 'package:popover/popover.dart';
import '../widget/file_upload_dialog.dart';

class ChatPage extends StatefulWidget {
  final UserData userData;
  const ChatPage({super.key, required this.userData});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  late ChatCubit _chatRoomsCubit;
  @override
  void initState() {
    BlocProvider.of<ChatCubit>(context).onInit(widget.userData.uid!);

    super.initState();
  }

  listListener() {
    if (listScrollController.position.pixels == 0) {
      // BlocProvider.of<ChatCubit>(context).addPreviewsData();
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
    _chatRoomsCubit.stopStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () async {
              await BlocProvider.of<ChatCubit>(context).stopStream().then((e) {
                Navigator.pop(context);
              });
            },
            icon: const Icon(Icons.arrow_back)),
        titleSpacing: 0,
        title: Row(
          children: [
            if (widget.userData.profileURL != null)
              Container(
                width: 30,
                height: 30,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: CircularProfileImage(
                  image: widget.userData.profileURL,
                  isNetworkImage: true,
                ),
              ),
            const Gap(10),
            Text(
                widget.userData.userName!.replaceRange(0, 1,
                    widget.userData.userName!.split('').first.toUpperCase()),
                style: const TextStyle(
                    color: AppColor.white, fontFamily: Roboto.medium)),
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
                    if (state.messageList.isNotEmpty) {
                      //chat messages
                      return ListView.builder(
                        controller: listScrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        itemCount: state.messageList.length,
                        itemBuilder: (context, index) {
                          final MessageModel message = state.messageList[index];
                          return Column(
                            children: [
                              //date
                              Builder(builder: (context) {
                                if (index > 0 &&
                                    message.date ==
                                        state.messageList[index - 1].date) {
                                  return const SizedBox();
                                } else {
                                  return Text('${message.date}');
                                }
                              }),
                              //message bubble
                              Align(
                                alignment:
                                    widget.userData.uid == message.senderID
                                        ? Alignment.centerLeft
                                        : Alignment.centerRight,
                                child: Container(
                                  constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.sizeOf(context).width *
                                              0.55),
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .inverseSurface,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Column(
                                    crossAxisAlignment:
                                        widget.userData.uid == message.senderID
                                            ? CrossAxisAlignment.start
                                            : CrossAxisAlignment.end,
                                    children: [
                                      if (message.messageType == 'text')
                                        SelectableText(
                                          '${message.message}',
                                          style: const TextStyle(
                                              fontSize: AppFontSize.xs),
                                        ),
                                      if (message.messageType == 'image') ...[
                                        SizedBox(
                                          height: MediaQuery.sizeOf(context)
                                                  .height *
                                              0.35,
                                          child: CachedNetworkImage(
                                            imageUrl: message.message!,
                                          ),
                                        ),
                                        const Gap(5)
                                      ],
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            DateFormat('hh:mm a').format(
                                                message.timestamp!.toDate()),
                                            style: const TextStyle(
                                                fontSize: AppFontSize.xxs,
                                                color: AppColor.greyText),
                                          ),
                                          const Gap(3),
                                          if (widget.userData.uid !=
                                              message.senderID)
                                            if (message.status == 'unread')
                                              const SVGIcon(
                                                name: "svg/check.svg",
                                                size: AppFontSize.xxs + 1,
                                                color: AppColor.greyText,
                                              )
                                            else ...[
                                              const SVGIcon(
                                                name: "svg/read.svg",
                                                size: AppFontSize.xxs + 1,
                                                color: AppColor.blue,
                                              ),
                                            ]
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      return EmptyChat(
                        onPress: () async {
                          context
                              .read<ChatCubit>()
                              .sendMessage('Hi', widget.userData, 'text');
                        },
                      );
                    }
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
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text(
                  'Cannot send empty message',
                  style: TextStyle(fontSize: AppFontSize.sm),
                ),
                actions: [
                  TextButton(
                    child: const Text('Ok'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              ));
    } else if (state is UploadFile) {
      if (state.fileStatus == FileStatus.preview) {
        showDialog(
          context: context,
          builder: (context) => FileUploadDialog(
            state: state,
          ),
        );
      }
    } else if (state is FileUploaded) {
      Navigator.pop(context);
      context
          .read<ChatCubit>()
          .sendMessage(state.fileUrl, widget.userData, 'image');
    } else if (state is ChatDataPopulated) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        listScrollController.animateTo(
            duration: Durations.extralong4,
            curve: Curves.bounceInOut,
            listScrollController.position.maxScrollExtent);
      });
    }
  }
}

class ChatTextField extends StatelessWidget {
  const ChatTextField({
    super.key,
    required this.messageController,
    required this.widget,
  });

  final TextEditingController messageController;
  final ChatPage widget;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (value) {
              context.read<ChatCubit>().sendMessage(
                  messageController.text.trim(), widget.userData, 'text');
              messageController.clear();
            },
            controller: messageController,
            cursorColor: AppColor.blue,
            style: const TextStyle(fontSize: AppFontSize.sm),
            decoration: InputDecoration(
              prefixIcon: IconButton(
                icon: const Icon(
                  Icons.filter,
                  size: 25,
                ),
                onPressed: () {
                  showPopover(
                    backgroundColor: Theme.of(context).colorScheme.onTertiary,
                    context: context,
                    bodyBuilder: (context) => const AssetsPopover(),
                  );
                },
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0),
              focusColor: AppColor.green,
              hintText: "Type here",
              hintStyle: const TextStyle(fontSize: AppFontSize.sm),
              contentPadding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
              fillColor: Theme.of(context).colorScheme.inverseSurface,
              filled: true,
              enabled: true,
              enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColor.greyline),
                  borderRadius: BorderRadius.circular(50)),
              focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColor.greyline),
                  borderRadius: BorderRadius.circular(50)),
            ),
          ),
        ),
        ElevatedButton(
            style: ButtonStyle(
                backgroundColor: const WidgetStatePropertyAll(AppColor.blue),
                overlayColor:
                    WidgetStatePropertyAll(AppColor.white.withOpacity(0.2)),
                padding: const WidgetStatePropertyAll(EdgeInsets.all(12)),
                shape: const WidgetStatePropertyAll(
                    CircleBorder(eccentricity: 0))),
            onPressed: () {
              context
                  .read<ChatCubit>()
                  .sendMessage(messageController.text, widget.userData, 'text');
              messageController.clear();
            },
            child: const Icon(
              Icons.send_sharp,
              color: AppColor.white,
            )),
      ],
    );
  }
}

class AssetsPopover extends StatelessWidget {
  const AssetsPopover({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => context.read<ChatCubit>().openGallery(),
          child: Container(
            width: MediaQuery.sizeOf(context).width * 0.4,
            padding: const EdgeInsets.all(10),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.image),
                Gap(10),
                Text(
                  'pickImage',
                ),
              ],
            ),
          ),
        ),
        InkWell(
          // onTap: () =>
          //     context.read<ChatCubit>().openVideoGallery(),
          child: Container(
            width: MediaQuery.sizeOf(context).width * 0.4,
            padding: const EdgeInsets.all(10),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.video_collection),
                Gap(10),
                Text(
                  'Video',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
