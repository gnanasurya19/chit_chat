import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:chit_chat/controller/profile_cubit/profile_cubit.dart';
import 'package:chit_chat/controller/theme_cubit/theme_cubit.dart';
import 'package:chit_chat/res/colors.dart';
import 'package:chit_chat/res/custom_widget/svg_icon.dart';
import 'package:chit_chat/res/fonts.dart';
import 'package:chit_chat/view/widget/circular_profile_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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

  @override
  void initState() {
    super.initState();
  }

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
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listenWhen: (previous, current) => current is ProfileActionState,
        buildWhen: (previous, current) => current is! ProfileActionState,
        listener: (context, state) {
          if (state is SignOut) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              'auth',
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileInitial) {
            return SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    const Gap(30),
                    Hero(
                      tag: 'profile',
                      child: SizedBox(
                        height: 120,
                        width: 120,
                        child: CircularProfileImage(
                          isNetworkImage: state.user.profileURL != null,
                          image: state.user.profileURL,
                        ),
                      ),
                    ),
                    const Gap(20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        state.user.name ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontFamily: Roboto.bold,
                        ),
                      ),
                    ),
                    Text(
                      state.user.email ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: Roboto.medium,
                        color: AppColor.greyText,
                      ),
                    ),
                    const Gap(20),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Theme.of(context).colorScheme.inverseSurface,
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 15),
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              'General',
                              style: TextStyle(
                                color: AppColor.greyText,
                                fontSize: 20,
                                fontFamily: Roboto.medium,
                              ),
                            ),
                          ),
                          const Gap(10),
                          ...general.map(
                            (e) => Material(
                              color:
                                  Theme.of(context).colorScheme.inverseSurface,
                              child: InkWell(
                                onTap: () {},
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Row(
                                    children: [
                                      Container(
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
                                      const Gap(15),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
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
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(12),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Theme.of(context).colorScheme.inverseSurface,
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 15),
                            alignment: Alignment.centerLeft,
                            child: const Text(
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
                              subtitle:
                                  'Customize your notification preference',
                              action: Switch(
                                  inactiveThumbColor: AppColor.blackGrey,
                                  activeColor: AppColor.blue,
                                  value: state.isNotification ?? false,
                                  onChanged: (v) {})),
                          ProfilePrefTile(
                            title: "Theme",
                            subtitle: 'Change theme',
                            leadingIcon: 'bell',
                            action: ThemeToggleBtn(
                              onChange: (value) {
                                BlocProvider.of<ThemeCubit>(context)
                                    .changeTheme(context);
                                BlocProvider.of<ProfileCubit>(context)
                                    .changeTheme();
                              },
                              value: state.isDarkTheme ?? false,
                            ),
                          ),
                          Material(
                            color: Theme.of(context).colorScheme.inverseSurface,
                            child: InkWell(
                              onTap: () {
                                context.read<ProfileCubit>().signout();
                              },
                              child: ProfilePrefTile(
                                leadingIcon: 'logout',
                                title: 'Logout',
                                subtitle: 'securely logout of Account',
                                action: SVGIcon(
                                  name: 'arrow-right',
                                  size: 20,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .tertiaryContainer,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const Gap(20),
                  ],
                ),
              ),
            );
          } else {
            return const SizedBox();
          }
        },
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
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        children: [
          Container(
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
          const Gap(15),
          Expanded(
            child: Row(
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
                          color:
                              Theme.of(context).colorScheme.tertiaryContainer,
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
          ),
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
