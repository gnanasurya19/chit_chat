import 'package:chit_chat/model/user_data.dart';
import 'package:chit_chat/res/colors.dart';
import 'package:chit_chat/res/custom_widget/svg_icon.dart';
import 'package:chit_chat/res/fonts.dart';
import 'package:chit_chat/view/widget/circular_profile_image.dart';
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
    return Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  width: 0.5, color: AppColor.greyline.withOpacity(0.5)))),
      child: ListTile(
        leading: Container(
            width: 50,
            height: 50,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: CircularProfileImage(
                image: user.profileURL,
                isNetworkImage: user.profileURL != null)),
        onTap: () => onTap!(user),
        contentPadding: const EdgeInsets.all(15),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              user.userName!.replaceRange(
                  0, 1, user.userName!.split('').first.toUpperCase()),
              style: const TextStyle(
                  fontSize: AppFontSize.md, fontFamily: Roboto.medium),
            ),
            if (user.lastMessage != null && user.lastMessage!.time != null)
              Text(
                user.lastMessage!.time ?? '',
                style: const TextStyle(
                    color: AppColor.greyText, fontSize: AppFontSize.xxxs),
              )
          ],
        ),
        subtitle: user.lastMessage == null
            ? null
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (user.lastMessage!.senderID ==
                          FirebaseAuth.instance.currentUser!.uid) ...[
                        if (user.lastMessage!.status == 'unread')
                          const SVGIcon(
                            name: "check",
                            size: AppFontSize.xxs + 1,
                            color: AppColor.greyText,
                          )
                        else if (user.lastMessage!.status == 'delivered')
                          const SVGIcon(
                            name: "read",
                            size: AppFontSize.xxs + 1,
                            color: AppColor.greyText,
                          )
                        else
                          const SVGIcon(
                            name: "read",
                            size: AppFontSize.xxs + 1,
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
                            color: AppColor.greyText,
                            fontFamily: user.lastMessage!.batch != null ||
                                    user.lastMessage!.batch != 0
                                ? Roboto.regular
                                : Roboto.bold,
                          ),
                        ),
                      ] else
                        Text(
                          user.lastMessage!.message ?? '',
                          softWrap: true,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColor.greyText,
                            fontFamily: user.lastMessage!.batch != null &&
                                    user.lastMessage!.batch != 0 &&
                                    user.lastMessage!.receiverID ==
                                        FirebaseAuth.instance.currentUser!.uid
                                ? Roboto.bold
                                : Roboto.regular,
                          ),
                        ),
                    ],
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
                        style: const TextStyle(
                            fontSize: AppFontSize.xxs, color: AppColor.white),
                      ),
                    )
                ],
              ),
      ),
    );
  }
}
