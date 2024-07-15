import 'package:chit_chat/model/user_data.dart';
import 'package:chit_chat/res/colors.dart';
import 'package:chit_chat/res/fonts.dart';
import 'package:chit_chat/view/widget/circular_profile_image.dart';
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
            Text(
              user.time ?? '',
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
                  if (user.lastMessage!.contains('http'))
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.image,
                          size: 20,
                          color: AppColor.greyText,
                        ),
                        const Gap(5),
                        Text(
                          'Image',
                          style: TextStyle(
                            color: AppColor.greyText,
                            fontFamily: user.batch != null || user.batch != 0
                                ? Roboto.regular
                                : Roboto.bold,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      user.lastMessage ?? '',
                      softWrap: true,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColor.greyText,
                        fontFamily: user.batch != null || user.batch != 0
                            ? Roboto.regular
                            : Roboto.bold,
                      ),
                    ),
                  if (user.batch != null && user.batch != 0)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                          color: AppColor.blue, shape: BoxShape.circle),
                      child: Text(
                        '${user.batch}',
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
