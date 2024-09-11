import 'package:chit_chat_1/controller/profile_cubit/profile_cubit.dart';
import 'package:chit_chat_1/res/colors.dart';
import 'package:chit_chat_1/res/common_instants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class LogoutConfirmation extends StatelessWidget {
  const LogoutConfirmation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shadowColor: AppColor.black,
      elevation: 20,
      backgroundColor: Theme.of(context).colorScheme.onTertiary,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Container(
        color: Theme.of(context).colorScheme.onTertiary,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Are you sure want to logout',
                style: style.text.regular,
              ),
            ),
            Gap(style.insets.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style:
                      TextButton.styleFrom(foregroundColor: AppColor.greyText),
                  child: Text(
                    'Cancel',
                    style: style.text.regularSmall,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.read<ProfileCubit>().signout();
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: Text(
                    'Logout',
                    style: style.text.regularSmall,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
