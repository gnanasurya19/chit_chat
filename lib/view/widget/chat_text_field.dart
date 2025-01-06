import 'dart:async';

import 'package:chit_chat/controller/chat_cubit/chat_cubit.dart';
import 'package:chit_chat/res/colors.dart';
import 'package:chit_chat/res/common_instants.dart';
import 'package:chit_chat/view/screen/chat_page.dart';
import 'package:chit_chat/view/widget/media_popover.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:popover/popover.dart';

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
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.inverseSurface,
                border: Border.all(color: AppColor.greyline),
                borderRadius: BorderRadius.circular(25)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const MediaOptionBtn(),
                Expanded(
                  child: TextField(
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 4,
                    minLines: 1,
                    onSubmitted: (value) {
                      context.read<ChatCubit>().sendMessage(
                          messageController.text.trim(),
                          widget.userData,
                          'text');
                      messageController.clear();
                    },
                    controller: messageController,
                    cursorColor: AppColor.blue,
                    style: style.text.regular,
                    decoration: InputDecoration(
                      hintText: "Type here",
                      hintStyle: style.text.regular,
                      contentPadding: const EdgeInsets.fromLTRB(0, 10, 5, 10),
                      // fillColor: Theme.of(context).colorScheme.inverseSurface,
                      // filled: true,
                      enabled: true,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      // enabledBorder: OutlineInputBorder(
                      //   borderSide: const BorderSide(color: AppColor.greyline),
                      //   borderRadius: BorderRadius.circular(50),
                      // ),
                      // focusedBorder: OutlineInputBorder(
                      //     borderSide: const BorderSide(color: AppColor.greyline),
                      //     borderRadius: BorderRadius.circular(50)),
                    ),
                  ),
                ),
                MicButton(),
              ],
            ),
          ),
        ),
        ElevatedButton(
            style: ButtonStyle(
                backgroundColor: const WidgetStatePropertyAll(AppColor.blue),
                overlayColor: WidgetStatePropertyAll(
                    AppColor.white.withValues(alpha: 0.2)),
                padding: const WidgetStatePropertyAll(EdgeInsets.all(12)),
                shape: const WidgetStatePropertyAll(
                    CircleBorder(eccentricity: 0))),
            onPressed: () {
              context.read<ChatCubit>().sendMessage(
                  messageController.text.trim(), widget.userData, 'text');
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

class MicButton extends StatefulWidget {
  const MicButton({
    super.key,
  });
  @override
  State<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<MicButton> {
  bool isListening = false;
  double? draggedPosition;
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onLongPressMoveUpdate: (details) {
            if (details.localPosition.dx < 0) {
              setState(() {
                draggedPosition = details.localPosition.dx;
              });
            }
            if (draggedPosition != null && draggedPosition! < -150) {
              setState(() {
                draggedPosition = null;
                isListening = false;
                context.read<ChatCubit>().cancelRecording();
              });
            }
          },
          onTap: () {
            showPopover(
              barrierColor: Colors.transparent,
              context: context,
              bodyBuilder: (context) {
                return Container(
                  padding: EdgeInsets.all(10),
                  child: Text('Press And Hold to recoed Audio'),
                );
              },
            );
          },
          onLongPress: () async {
            if (await ChatCubit().checkMicPermission()) {
              context.read<ChatCubit>().startRecording();
            }
            setState(() {
              isListening = true;
            });
          },
          onLongPressEnd: (details) {
            context.read<ChatCubit>().stopRecording();
            setState(() {
              isListening = false;
              draggedPosition = null;
            });
          },
          child: Container(
            margin: EdgeInsets.all(5),
            padding: EdgeInsets.all(5),
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: AppColor.blue),
            child: Icon(
              Icons.mic,
              color: AppColor.white,
            ),
          ),
        ),
        AnimatedPositioned(
          left: draggedPosition,
          duration: Duration(milliseconds: 100),
          height: isListening ? 70 : 0,
          width: isListening ? 70 : 0,
          child: ClipOval(
            child: Container(
              color: AppColor.blue,
              child: Icon(
                Icons.mic,
                color: AppColor.white,
              ),
            ),
          ),
        ),
        if (isListening) TimeDurationWidget(),
      ],
    );
  }
}

class TimeDurationWidget extends StatefulWidget {
  const TimeDurationWidget({
    super.key,
  });

  @override
  State<TimeDurationWidget> createState() => _TimeDurationWidgetState();
}

class _TimeDurationWidgetState extends State<TimeDurationWidget>
    with SingleTickerProviderStateMixin {
  late final fadeController =
      AnimationController(vsync: this, duration: Duration(milliseconds: 800));
  int timer = 0;
  late final Timer countDown;
  @override
  void initState() {
    super.initState();
    countDown = Timer.periodic(Duration(seconds: 1), (value) {
      setState(() {
        timer++;
      });
    });
    fadeController.repeat(reverse: true);
  }

  @override
  void dispose() {
    countDown.cancel();
    fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: -50,
        child: Container(
          decoration: BoxDecoration(
              color: AppColor.blue,
              borderRadius: BorderRadius.circular(style.radius.sm)),
          padding: EdgeInsets.all(5),
          child: Row(
            children: [
              FadeTransition(
                  opacity: fadeController,
                  child: Icon(Icons.mic,
                      color: AppColor.lightgreyText, size: style.icon.rg)),
              Text(
                  "${(timer ~/ 60).toString().padLeft(2, '0')}:${(timer % 60).toString().padLeft(2, '0')}",
                  style: style.text.regular.copyWith(color: AppColor.white)),
            ],
          ),
        ));
  }
}

class MediaOptionBtn extends StatelessWidget {
  const MediaOptionBtn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.filter,
        size: 25,
      ),
      onPressed: () async {
        showPopover(
          direction: PopoverDirection.top,
          backgroundColor: Theme.of(context).colorScheme.onTertiary,
          context: context,
          bodyBuilder: (context) => const MediaPopover(),
        );
      },
    );
  }
}
