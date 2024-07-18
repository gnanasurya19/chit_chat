import 'package:chit_chat/controller/chat_cubit/chat_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

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
          onTap: () {
            Navigator.pop(context);
            context.read<ChatCubit>().openGallery();
          },
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
          onTap: () {
            Navigator.pop(context);
            context.read<ChatCubit>().openVideoGallery();
          },
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
