import 'package:chit_chat/controller/chat_cubit/chat_cubit.dart';
import 'package:chit_chat/controller/home_cubit/home_cubit.dart';
import 'package:chit_chat/model/message_model.dart';
import 'package:chit_chat/model/user_data.dart';
import 'package:chit_chat/res/colors.dart';
import 'package:chit_chat/res/fonts.dart';
import 'package:chit_chat/view/widget/empty_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final UserData userData;
  const ChatPage({super.key, required this.userData});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController listScrollController = ScrollController();

  @override
  void initState() {
    BlocProvider.of<ChatCubit>(context).onInit(widget.userData.uid!);
    super.initState();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatController = BlocProvider.of<ChatCubit>(context);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text(
            widget.userData.userName!.replaceRange(
                0, 1, widget.userData.userName!.split('').first.toUpperCase()),
            style: const TextStyle(
                color: AppColor.white, fontFamily: Roboto.medium)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        iconTheme: const IconThemeData(color: AppColor.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Expanded(
              child: BlocConsumer<ChatCubit, ChatState>(
                listenWhen: (previous, current) => current is ChatActionState,
                listener: (context, state) {
                  if (state is ChatFirstMessage) {
                    BlocProvider.of<HomeCubit>(context).onInit();
                  }
                },
                builder: (context, state) {
                  if (state is ChatReady) {
                    if (state.messageList.isNotEmpty) {
                      //chat messages
                      return ListView.builder(
                        controller: listScrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        itemCount: state.messageList.length,
                        itemBuilder: (context, index) {
                          final MessageModel messaege =
                              state.messageList[index];

                          return Column(
                            children: [
                              //date
                              Builder(builder: (context) {
                                if (index > 0 &&
                                    messaege.date ==
                                        state.messageList[index - 1].date) {
                                  return const SizedBox();
                                } else {
                                  return Text('${messaege.date}');
                                }
                              }),
                              //message bubble
                              Align(
                                alignment:
                                    widget.userData.uid == messaege.senderID
                                        ? Alignment.centerLeft
                                        : Alignment.centerRight,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .inverseSurface,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Column(
                                    crossAxisAlignment:
                                        widget.userData.uid == messaege.senderID
                                            ? CrossAxisAlignment.start
                                            : CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${messaege.message}',
                                        style: const TextStyle(
                                            fontSize: AppFontSize.xs),
                                      ),
                                      Text(
                                        DateFormat('hh:mm a').format(
                                            messaege.timestamp!.toDate()),
                                        style: const TextStyle(
                                            fontSize: AppFontSize.xxs,
                                            color: AppColor.greyText),
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
                          chatController
                              .sendMessage('Hi', widget.userData)
                              .then((value) =>
                                  BlocProvider.of<HomeCubit>(context).onInit());
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (value) {
                      chatController.sendMessage(
                          messageController.text.trim(), widget.userData);
                      messageController.clear();
                    },
                    controller: messageController,
                    cursorColor: AppColor.blue,
                    style: const TextStyle(fontSize: AppFontSize.sm),
                    decoration: InputDecoration(
                      hintText: "Type here",
                      hintStyle: const TextStyle(fontSize: AppFontSize.sm),
                      contentPadding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                      fillColor: Theme.of(context).colorScheme.inverseSurface,
                      filled: true,
                      enabled: true,
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: AppColor.greyline),
                          borderRadius: BorderRadius.circular(50)),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: AppColor.greyline),
                          borderRadius: BorderRadius.circular(50)),
                    ),
                  ),
                ),
                ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            const MaterialStatePropertyAll(AppColor.blue),
                        overlayColor: MaterialStatePropertyAll(
                            AppColor.white.withOpacity(0.2)),
                        padding:
                            const MaterialStatePropertyAll(EdgeInsets.all(12)),
                        shape: const MaterialStatePropertyAll(
                            CircleBorder(eccentricity: 0))),
                    onPressed: () {
                      chatController.sendMessage(
                          messageController.text, widget.userData);
                      messageController.clear();
                    },
                    child: const Icon(
                      Icons.send_sharp,
                      color: AppColor.white,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
