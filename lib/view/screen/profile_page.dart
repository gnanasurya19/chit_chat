import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:chit_chat/controller/profile_cubit/profile_cubit.dart';
import 'package:chit_chat/controller/update_cubit/update_cubit.dart';
import 'package:chit_chat/res/colors.dart';
import 'package:chit_chat/res/common_instants.dart';
import 'package:chit_chat/res/custom_widget/loading_widget.dart';
import 'package:chit_chat/res/custom_widget/svg_icon.dart';
import 'package:chit_chat/view/widget/circular_profile_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../widget/logout_confirmation.dart';
import '../widget/password_reset_widget.dart';
import '../widget/profile_pref_tile.dart';

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
      'subTitle': 'Change profile picture,name,phone number',
    },
    {
      'icon': "lock",
      'title': 'Change Password',
      'subTitle': 'Update and Strengthen account security',
    },
    {
      'icon': "update",
      'title': 'Check for Update',
      'subTitle': 'Keep your application up to date',
    },
  ];

  @override
  void initState() {
    super.initState();
    BlocProvider.of<ProfileCubit>(context).onProfilePage();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeSwitchingArea(
      child: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            backgroundColor: Theme.of(context).colorScheme.surfaceDim,
            centerTitle: true,
            title: Text(
              'PROFILE SETTING',
              style: style.text.boldLarge,
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
              } else if (state is ChangePasswordState) {
                util.slideInDialog(
                  context,
                  const PasswordResetWidget(),
                );
              } else if (state is SigningOutState) {
                util.slideInDialog(
                  context,
                  const LogoutConfirmation(),
                );
              } else if (state is AlertToast) {
                util.showSnackbar(context, state.text, state.type);
              } else if (state is AlertState) {
                util.doAlert(context, state.text, state.type);
              } else if (state is PasswordUpdated) {
                Navigator.pop(context);
                util.showSnackbar(context, 'Password updated', 'success');
              } else if (state is ProfileUpdate) {
                Navigator.pop(context);
                util.showSnackbar(context, 'Profile updated', 'success');
              } else if (state is ProfileLoader) {
                showDialog(
                  context: context,
                  builder: (context) => const LoadingScreen(),
                );
              } else if (state is ProfileLoaderCancel) {
                Navigator.pop(context);
              }
            },
            builder: (context, state) {
              if (state is ProfileInitial) {
                return SingleChildScrollView(
                  child: Padding(
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
                            (state.user.userName ?? '').toUpperCase(),
                            textAlign: TextAlign.center,
                            style: style.text.boldXLarge,
                          ),
                        ),
                        Text(
                          state.user.userEmail ?? '',
                          style: style.text.semiBoldMedium.copyWith(
                            color: AppColor.greyText,
                          ),
                        ),
                        if ((state.user.phoneNumber ?? '').isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.phone,
                                size: style.icon.sm - 2,
                              ),
                              const Gap(5),
                              Text(
                                state.user.phoneNumber ?? '',
                                style: style.text.semiBoldMedium.copyWith(
                                  color: AppColor.greyText,
                                ),
                              ),
                            ],
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
                                child: Text(
                                  'General',
                                  style: style.text.boldLarge
                                      .copyWith(color: AppColor.greyText),
                                ),
                              ),
                              const Gap(10),
                              ...general.map(
                                (e) => Material(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inverseSurface,
                                  child: InkWell(
                                    onTap: () {
                                      if (e['title'] == "Change Password") {
                                        context
                                            .read<ProfileCubit>()
                                            .passwordResetDialog();
                                      } else if (e['title'] == "Edit Profile") {
                                        Navigator.pushNamed(
                                            context, 'profile-edit');
                                      } else {
                                        context
                                            .read<UpdateCubit>()
                                            .checkforUpdate('manual');
                                      }
                                    },
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
                                              size: style.icon.sm,
                                            ),
                                          ),
                                          const Gap(15),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                            e['title'],
                                                            style: style
                                                                .text.boldMedium
                                                                .copyWith(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .tertiaryContainer),
                                                          ),
                                                          if (e['title'] ==
                                                              'Check for Update')
                                                            BlocBuilder<
                                                                UpdateCubit,
                                                                UpdateState>(
                                                              builder: (context,
                                                                  state) {
                                                                return Expanded(
                                                                  child: Text(
                                                                    '  (Version: ${context.read<UpdateCubit>().currentVersion})',
                                                                    style: style
                                                                        .text
                                                                        .regularSmall,
                                                                  ),
                                                                );
                                                              },
                                                            )
                                                        ],
                                                      ),
                                                      Text(e['subTitle'],
                                                          style: style.text
                                                              .semiBoldSmall
                                                              .copyWith(
                                                                  color: AppColor
                                                                      .greyText))
                                                    ],
                                                  ),
                                                ),
                                                if (e['title'] !=
                                                    'Check for Update')
                                                  SVGIcon(
                                                    name: 'arrow-right',
                                                    size: style.icon.sm,
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
                                child: Text(
                                  'Preference',
                                  style: style.text.semiBoldLarge,
                                ),
                              ),
                              const Gap(10),
                              ProfilePrefTile(
                                  leadingIcon: 'bell',
                                  title: 'Notification',
                                  subtitle:
                                      'Customize your notification preference',
                                  action: Switch(
                                      inactiveThumbColor: AppColor.greyText,
                                      activeColor: AppColor.blue,
                                      value: state.isNotification ?? false,
                                      onChanged: (v) {
                                        context
                                            .read<ProfileCubit>()
                                            .changeNotificationPref();
                                      })),
                              ThemeSwitcher.switcher(builder: (context, theme) {
                                return ProfilePrefTile(
                                  title: "Theme",
                                  subtitle: 'Change theme',
                                  leadingIcon: 'themes',
                                  action: ThemeToggleBtn(
                                    onChange: (value) {
                                      BlocProvider.of<ProfileCubit>(context)
                                          .changeTheme(theme);
                                    },
                                    value: state.isDarkTheme ?? false,
                                  ),
                                );
                              }),
                              Material(
                                color: Theme.of(context)
                                    .colorScheme
                                    .inverseSurface,
                                child: InkWell(
                                  onTap: () {
                                    context.read<ProfileCubit>().signoutAlert();
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
      }),
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
                color: Colors.amber,
              ),
      ),
    );
  }
}
