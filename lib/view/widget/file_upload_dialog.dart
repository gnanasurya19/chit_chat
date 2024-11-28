import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:chit_chat/controller/chat_cubit/chat_cubit.dart';
import 'package:chit_chat/controller/media_cubit/media_cubit.dart';
import 'package:chit_chat/res/colors.dart';
import 'package:chit_chat/res/common_instants.dart';
import 'package:chit_chat/view/widget/video_preview.dart';

class FileUploadDialog extends StatelessWidget {
  const FileUploadDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      buildWhen: (previous, current) => current is UploadFile,
      builder: (context, state) {
        if (state is UploadFile) {
          return PopScope(
            canPop: false,
            child: Dialog(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Are you sure want to send this file?',
                      style: style.text.regular,
                    ),
                    ImageCollageWidget(
                        mediaType: state.mediaType, medialist: state.filePath),
                    // buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (state.fileStatus == FileStatus.preview)
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.tertiary),
                            ),
                          ),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: AppColor.blue,
                          ),
                          iconAlignment: IconAlignment.end,
                          icon: state.fileStatus == FileStatus.preview
                              ? const Icon(Icons.upload)
                              : const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  )),
                          onPressed: state.fileStatus == FileStatus.preview
                              ? () {
                                  context
                                      .read<ChatCubit>()
                                      .uploadFileToFirebase(
                                          state.filePath, state.mediaType);
                                }
                              : null,
                          label: Text(
                            state.fileStatus == FileStatus.preview
                                ? 'upload'
                                : 'uploading',
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}

class ImageCollageWidget extends StatelessWidget {
  const ImageCollageWidget(
      {super.key, required this.mediaType, required this.medialist});
  final MediaType mediaType;
  final List<String> medialist;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: style.insets.lg),
      height: MediaQuery.sizeOf(context).width * 0.45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: medialist.length,
        itemBuilder: (context, index) => Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              margin: EdgeInsets.only(right: style.insets.sm),
              width: MediaQuery.sizeOf(context).width * 0.35,
              height: MediaQuery.sizeOf(context).width * 0.45,
              child: mediaType == MediaType.image
                  ? Image.file(
                      File(medialist[index]),
                      fit: BoxFit.cover,
                    )
                  : VideoPreview(filepath: medialist[index]),
            ),
            Positioned(
              right: 4,
              child: IconButton(
                  style: IconButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      backgroundColor: AppColor.black.withOpacity(0.3),
                      foregroundColor: AppColor.white),
                  onPressed: () {
                    if (medialist.length == 1) {
                      Navigator.pop(context);
                    }
                    context
                        .read<ChatCubit>()
                        .deleteSelectedMedia(index, mediaType);
                  },
                  icon: Icon(Icons.delete, size: style.icon.xs)),
            )
          ],
        ),
      ),
    );
  }
}
