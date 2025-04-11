// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chit_chat/model/message_model.dart';
import 'package:chit_chat/model/user_data.dart';
import 'package:chit_chat/res/colors.dart';
import 'package:chit_chat/res/common_instants.dart';
import 'package:chit_chat/res/custom_widget/svg_icon.dart';
import 'package:chit_chat/view/screen/chat_page.dart';
import 'package:chit_chat/view/widget/circular_profile_image.dart';
import 'package:chit_chat/view/widget/view_media.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class UserCard extends StatelessWidget {
  final UserData user;
  final Function(UserData userData) onTap;
  const UserCard({
    super.key,
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ProfileImage(
        user: user,
      ),
      onTap: () => onTap(user),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1.5),
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
                      if (user.lastMessage?.senderID ==
                          FirebaseAuth.instance.currentUser?.uid) ...[
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
                        if (user.lastMessage?.messageType == 'image')
                          Icon(
                            Icons.image,
                            size: style.icon.sm,
                            color: AppColor.greyText,
                          )
                        else if (user.lastMessage?.messageType == 'audio')
                          Icon(
                            Icons.headphones,
                            size: style.icon.sm,
                            color: AppColor.greyText,
                          )
                        else if (user.lastMessage?.messageType == 'video')
                          Icon(
                            Icons.videocam_rounded,
                            size: style.icon.sm,
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
                                                .instance.currentUser?.uid
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

class ProfileImage extends StatelessWidget {
  const ProfileImage({
    super.key,
    required this.user,
  });
  final UserData user;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 50,
        height: 50,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: GestureDetector(
          onTap: () {
            if (user.profileURL == null) {
              util.showSnackbar(context, 'User have not set profile', 'info');
            } else {
              _showProfile(context, user);
            }
          },
          child: Hero(
            createRectTween: (Rect? begin, Rect? end) {
              // Define a custom Tween with a specific curve
              return RectTween(begin: begin, end: end);
            },
            flightShuttleBuilder: (flightContext, animation, flightDirection,
                fromHeroContext, toHeroContext) {
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return ClipPath(
                    clipper: ShapeMorphClipper(animation.value),
                    child: fromHeroContext.widget,
                  );
                },
              );
            },
            tag: user.userName ?? '',
            child: ClipOval(
              child: CircularProfileImage(
                  image: user.profileURL,
                  isNetworkImage: user.profileURL != null),
            ),
          ),
        ));
  }

  _showProfile(context, UserData user) {
    Navigator.push(
        context,
        HeroDialogRoute(
          builder: (context) => ProfileModal(user: user),
        ));
  }
}

class ProfileModal extends StatelessWidget {
  const ProfileModal({
    super.key,
    required this.user,
  });

  final UserData user;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      alignment: const Alignment(0, -0.5),
      shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(style.radius.lg)),
      clipBehavior: Clip.hardEdge,
      insetPadding: EdgeInsets.symmetric(
          horizontal: MediaQuery.sizeOf(context).width * 0.15, vertical: 0),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).width * 0.7,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewMediaPage(
                      message: MessageModel(
                          message: user.profileURL, messageType: 'image'),
                    ),
                  ),
                );
              },
              child: Hero(
                tag: user.userName!,
                child: ProfileImageSquare(
                  image: user.profileURL!,
                ),
              ),
            ),
            Flexible(
              fit: FlexFit.loose,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChatPage(
                                    userData: user,
                                  )));
                    },
                    icon: const Icon(Icons.message),
                  ),
                  IconButton(
                    onPressed: () async {
                      await util
                          .downloadFromCache(user.profileURL!, 'image', context)
                          .then((v) {
                        Navigator.pop(context);
                      });
                    },
                    icon: const Icon(Icons.download_rounded),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileImageSquare extends StatelessWidget {
  const ProfileImageSquare({
    super.key,
    required this.image,
  });
  final String image;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: image,
      fit: BoxFit.cover,
      width: MediaQuery.sizeOf(context).width * 0.6,
      height: MediaQuery.sizeOf(context).width * 0.6,
      placeholder: (context, url) => Image.asset(
        'assets/images/profile.png',
        fit: BoxFit.cover,
      ),
      errorWidget: (context, url, error) => Image.asset(
        'assets/images/profile.png',
        fit: BoxFit.cover,
      ),
    );
  }
}

class ShapeMorphClipper extends CustomClipper<Path> {
  final double progress; // Animation progress: 0.0 (circle) to 1.0 (rectangle)

  ShapeMorphClipper(this.progress);

  @override
  Path getClip(Size size) {
    final Path path = Path();

    // Circle center and radius
    final double maxRadius = size.shortestSide / 2.0;

    // Calculate current radius based on animation progress
    final double currentRadius = maxRadius * (1.0 - progress);

    // Add a rounded rectangle or circle based on progress
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(currentRadius),
    ));

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true; // Always reclip when animation progresses
  }
}

class HeroDialogRoute<T> extends PageRoute<T> {
  HeroDialogRoute({required this.builder}) : super();

  final WidgetBuilder builder;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 400);

  @override
  bool get maintainState => true;

  @override
  Color get barrierColor => Colors.black54;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(opacity: animation, child: child);
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return builder(context);
  }

  @override
  String? get barrierLabel => 'label';
}
