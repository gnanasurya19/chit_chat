import 'package:chit_chat_1/model/user_data.dart';
import 'package:chit_chat_1/res/colors.dart';
import 'package:chit_chat_1/res/common_instants.dart';
import 'package:chit_chat_1/res/custom_widget/svg_icon.dart';
import 'package:chit_chat_1/view/widget/circular_profile_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class UserCard extends StatelessWidget {
  final UserData user;
  final Function(UserData userData)? onTap;
  const UserCard({
    super.key,
    required this.user,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
          width: 50,
          height: 50,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: CircularProfileImage(
              image: user.profileURL, isNetworkImage: user.profileURL != null)),
      onTap: () => onTap!(user),
      contentPadding: const EdgeInsets.all(15),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            user.userName!.replaceRange(
                0, 1, user.userName!.split('').first.toUpperCase()),
            style: style.text.semiBoldMedium,
          ),
          if (user.lastMessage != null && user.lastMessage!.time != null)
            Text(
              user.lastMessage!.time ?? '',
              style: style.text.semiBoldSmall.copyWith(
                color: AppColor.greyText,
              ),
            )
        ],
      ),
      subtitle: user.lastMessage == null
          ? null
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (user.lastMessage!.senderID ==
                          FirebaseAuth.instance.currentUser!.uid) ...[
                        if (user.lastMessage!.status == 'unread')
                          SVGIcon(
                            name: "check",
                            size: style.icon.xxs,
                            color: AppColor.greyText,
                          )
                        else if (user.lastMessage!.status == 'delivered')
                          SVGIcon(
                            name: "read",
                            size: style.icon.xxs,
                            color: AppColor.greyText,
                          )
                        else
                          SVGIcon(
                            name: "read",
                            size: style.icon.xxs,
                            color: AppColor.blue,
                          ),
                        const Gap(5),
                      ],
                      if (user.lastMessage!.messageType != 'text') ...[
                        const Icon(
                          Icons.image,
                          size: 20,
                          color: AppColor.greyText,
                        ),
                        const Gap(5),
                        Text(
                          '${user.lastMessage!.messageType}',
                          style: TextStyle(
                            fontSize: 14 * style.scale,
                            color: AppColor.greyText,
                            fontFamily: user.lastMessage!.batch != null ||
                                    user.lastMessage!.batch != 0
                                ? "Roboto.Regular"
                                : "Roboto.Bold",
                          ),
                        ),
                      ] else
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 40),
                            child: Text(
                              user.lastMessage!.message ?? '',
                              softWrap: true,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14 * style.scale,
                                color: AppColor.greyText,
                                fontFamily: user.lastMessage!.batch != null &&
                                        user.lastMessage!.batch != 0 &&
                                        user.lastMessage!.receiverID ==
                                            FirebaseAuth
                                                .instance.currentUser!.uid
                                    ? "Roboto.Bold"
                                    : "Roboto.Regular",
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (user.lastMessage!.batch != null &&
                    user.lastMessage!.batch != 0 &&
                    user.lastMessage!.senderID !=
                        FirebaseAuth.instance.currentUser!.uid)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                        color: AppColor.blue, shape: BoxShape.circle),
                    child: Text(
                      (user.lastMessage!.batch! < 100
                              ? user.lastMessage!.batch
                              : '100+')!
                          .toString(),
                      style: style.text.boldXS.copyWith(color: AppColor.white),
                    ),
                  )
              ],
            ),
    );
  }
}
