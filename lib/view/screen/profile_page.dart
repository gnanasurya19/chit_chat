import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:chit_chat/controller/theme_cubit/theme_cubit.dart';
import 'package:chit_chat/res/colors.dart';
import 'package:chit_chat/res/custom_widget/svg_icon.dart';
import 'package:chit_chat/res/fonts.dart';
import 'package:chit_chat/view/widget/circular_profile_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final List general = [
    {
      'icon': "user",
      'title': 'Edit Profile',
      'subTitle': 'Change profile picture,number,DOB',
    },
    {
      'icon': "lock",
      'title': 'Change Password',
      'subTitle': 'Update and Strengthen account security',
    },
  ];

  bool isDark = false;

  @override
  void initState() {
    super.initState();
    final ThemeMode theme = BlocProvider.of<ThemeCubit>(context).themeMode;
    if (theme == ThemeMode.dark) {
      SchedulerBinding.instance.addPostFrameCallback((e) {
        setState(() {
          isDark = true;
        });
      });
    }
  }

  bool notification = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surfaceDim,
        centerTitle: true,
        title: const Text(
          'PROFILE SETTING',
          style: TextStyle(fontFamily: Roboto.bold, fontSize: 20),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceDim,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const Gap(30),
              const Center(
                child: SizedBox(
                  height: 120,
                  width: 120,
                  child: CircularProfileImage(
                    isNetworkImage: true,
                    image:
                        'https://firebasestorage.googleapis.com/v0/b/chit-chat-19491.appspot.com/o/users%2Fprofile%2F1000023451.jpg?alt=media&token=7d3ae088-85a1-4486-8a5a-fa80aceebe45',
                  ),
                ),
              ),
              const Gap(20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  'Gnanasurya Poovaragavan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontFamily: Roboto.bold,
                  ),
                ),
              ),
              const Text(
                'gnanasurya108@gmail.com',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: Roboto.medium,
                  color: AppColor.greyText,
                ),
              ),
              const Gap(20),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).colorScheme.inverseSurface,
                ),
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'General',
                        style: TextStyle(
                          color: AppColor.greyText,
                          fontSize: 20,
                          fontFamily: Roboto.medium,
                        ),
                      ),
                    ),
                    const Gap(10),
                    ...general.map((e) => ListTile(
                          onTap: () {},
                          minVerticalPadding: 15,
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surface
                                  .withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: SVGIcon(
                              name: e['icon'],
                              size: 20,
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e['title'],
                                      style: TextStyle(
                                        fontFamily: Roboto.bold,
                                        fontSize: 17,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiaryContainer,
                                      ),
                                    ),
                                    Text(
                                      e['subTitle'],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontFamily: Roboto.medium,
                                        color: AppColor.greyText,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              SVGIcon(
                                name: 'arrow-right',
                                size: 20,
                                color: Theme.of(context)
                                    .colorScheme
                                    .tertiaryContainer,
                              )
                            ],
                          ),
                        ))
                  ],
                ),
              ),
              const Gap(12),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).colorScheme.inverseSurface,
                ),
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Preference',
                        style: TextStyle(
                          color: AppColor.greyText,
                          fontSize: 20,
                          fontFamily: Roboto.medium,
                        ),
                      ),
                    ),
                    const Gap(10),
                    ProfilePrefTile(
                        leadingIcon: 'bell',
                        title: 'Notification',
                        subtitle: 'Customize your notification preference',
                        action: Switch(
                            inactiveThumbColor: AppColor.blackGrey,
                            activeColor: AppColor.blue,
                            value: notification,
                            onChanged: (v) {
                              setState(() {
                                notification = !notification;
                              });
                            })),
                    ProfilePrefTile(
                      title: "Theme",
                      subtitle: 'Change theme',
                      leadingIcon: 'bell',
                      action: ThemeToggleBtn(
                        onChange: (value) {
                          setState(() {
                            isDark = !isDark;
                          });
                          BlocProvider.of<ThemeCubit>(context)
                              .changeTheme(context);
                        },
                        value: isDark,
                      ),
                    ),
                    ProfilePrefTile(
                      leadingIcon: 'logout',
                      title: 'Logout',
                      subtitle: 'securely logout of Account',
                      action: SVGIcon(
                        name: 'arrow-right',
                        size: 20,
                        color: Theme.of(context).colorScheme.tertiaryContainer,
                      ),
                    )
                  ],
                ),
              ),
              const Gap(20),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfilePrefTile extends StatelessWidget {
  const ProfilePrefTile({
    super.key,
    required this.leadingIcon,
    required this.title,
    required this.subtitle,
    required this.action,
  });

  final String leadingIcon;
  final String title;
  final String subtitle;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: 15,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: leadingIcon == 'logout'
              ? Theme.of(context).colorScheme.surfaceTint.withOpacity(0.5)
              : Theme.of(context).colorScheme.surface.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: SVGIcon(
          name: leadingIcon,
          size: 17,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: Roboto.bold,
                    fontSize: 17,
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: Roboto.medium,
                    color: AppColor.greyText,
                  ),
                )
              ],
            ),
          ),
          action,
        ],
      ),
    );
  }
}

class ThemeToggleBtn extends StatelessWidget {
  final bool value;
  final Function(bool value) onChange;
  const ThemeToggleBtn({
    super.key,
    required this.value,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 55,
      child: AnimatedToggleSwitch<bool>.dual(
        current: !value,
        first: true,
        second: false,
        spacing: 10.0,
        style: const ToggleStyle(
          borderColor: Colors.transparent,
          indicatorColor: Colors.transparent,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              spreadRadius: 1,
              blurRadius: 2,
              offset: Offset(0, 1.5),
            ),
          ],
        ),
        borderWidth: 5.0,
        height: 30,
        onChanged: (value) {
          onChange(value);
        },
        styleBuilder: (b) => ToggleStyle(
            backgroundColor: !value ? Colors.white : AppColor.black),
        iconBuilder: (value) => value
            ? const Icon(
                Icons.sunny,
                size: 15,
                color: Colors.amber,
              )
            : const Icon(
                Icons.nightlight_round_sharp,
                size: 15,
                color: AppColor.white,
              ),
      ),
    );
  }
}
