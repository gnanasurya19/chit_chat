import 'package:chit_chat/controller/update_cubit/update_cubit.dart';
import 'package:chit_chat/res/colors.dart';
import 'package:chit_chat/res/common_instants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class UpdateDialog extends StatelessWidget {
  const UpdateDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Theme.of(context).colorScheme.onTertiary,
        elevation: 20,
        shadowColor: AppColor.black,
        child: BlocBuilder<UpdateCubit, UpdateState>(
          builder: (context, state) {
            if (state is DownloadState) {
              return Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        state.state == UpdateStatus.hasUpdate
                            ? "Update Available"
                            : state.state == UpdateStatus.downloading
                                ? "Downloading..."
                                : "Install",
                        style: style.text.boldLarge,
                      ),
                    ),
                    const Gap(10),
                    if (state.state == UpdateStatus.hasUpdate)
                      Text(
                        'Please update to enjoy the latest features of our app',
                        style: style.text.regular,
                      )
                    else if (state.state == UpdateStatus.downloaded)
                      Text(
                        'Install the latest application',
                        style: style.text.semiBold,
                      ),
                    if (state.state == UpdateStatus.downloading)
                      LinearProgressIndicator(
                        value: state.progress,
                        backgroundColor: AppColor.greyBg,
                        color: AppColor.blue,
                      ),
                    const Gap(10),
                    if (state.releaseNote != null &&
                        state.state == UpdateStatus.hasUpdate) ...[
                      Text('Release Notes', style: style.text.semiBold),
                      Text(state.releaseNote ?? ''),
                    ],
                    const Gap(10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: AppColor.greyText,
                          ),
                          onPressed: state.state == UpdateStatus.downloading
                              ? null
                              : () {
                                  Navigator.pop(context);
                                },
                          child: Text(
                            'Cancel',
                            style: style.text.regular,
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: AppColor.blue,
                          ),
                          onPressed: state.state == UpdateStatus.downloading
                              ? null
                              : () {
                                  context
                                      .read<UpdateCubit>()
                                      .downloadUpdate(context);
                                },
                          child: Text(
                            state.state == UpdateStatus.downloaded
                                ? 'Install'
                                : "Update",
                            style: style.text.regular,
                          ),
                        )
                      ],
                    ),
                  ],
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
