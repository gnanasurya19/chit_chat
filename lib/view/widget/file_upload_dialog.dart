import 'dart:io';
import 'package:chit_chat/controller/chat_cubit/chat_cubit.dart';
import 'package:chit_chat/controller/media_cubit/media_cubit.dart';
import 'package:chit_chat/res/colors.dart';
import 'package:chit_chat/res/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'video_widget.dart';

class FileUploadDialog extends StatelessWidget {
  final UploadFile state;
  const FileUploadDialog({
    super.key,
    required this.state,
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
                    const Text(
                      'Are you sure want to send this file?',
                      style: TextStyle(fontSize: AppFontSize.sm),
                    ),
                    if (state.mediaType != MediaType.image)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Image.file(
                          File(state.filePath),
                          width: MediaQuery.sizeOf(context).width * 0.35,
                          height: MediaQuery.sizeOf(context).width * 0.35,
                        ),
                      )
                    else if (state.mediaType != MediaType.video)
                      const VideoWidget(),
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
