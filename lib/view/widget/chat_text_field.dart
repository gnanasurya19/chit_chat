import 'package:chit_chat_1/controller/chat_cubit/chat_cubit.dart';
import 'package:chit_chat_1/res/colors.dart';
import 'package:chit_chat_1/res/common_instants.dart';
import 'package:chit_chat_1/view/screen/chat_page.dart';
import 'package:chit_chat_1/view/widget/media_popover.dart';
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
            style: style.text.regular,
            decoration: InputDecoration(
              prefixIcon: const MediaOptionBtn(),
              prefixIconConstraints: const BoxConstraints(minWidth: 0),
              focusColor: AppColor.green,
              hintText: "Type here",
              hintStyle: style.text.regular,
              contentPadding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
              fillColor: Theme.of(context).colorScheme.inverseSurface,
              filled: true,
              enabled: true,
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColor.greyline),
                borderRadius: BorderRadius.circular(50),
              ),
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
      onPressed: () {
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
