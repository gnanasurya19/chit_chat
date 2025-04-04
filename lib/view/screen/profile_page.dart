import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:chit_chat/controller/profile_cubit/profile_cubit.dart';
import 'package:chit_chat/controller/update_cubit/update_cubit.dart';
import 'package:chit_chat/model/message_model.dart';
import 'package:chit_chat/res/colors.dart';
import 'package:chit_chat/res/common_instants.dart';
import 'package:chit_chat/res/custom_widget/loading_widget.dart';
import 'package:chit_chat/res/custom_widget/svg_icon.dart';
import 'package:chit_chat/view/widget/circular_profile_image.dart';
import 'package:chit_chat/view/widget/view_media.dart';
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

class _ProfilePageState extends State<ProfilePage> with WidgetsBindingObserver {
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
  ThemeSwitcherState? themeSwitcherState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    BlocProvider.of<ProfileCubit>(context).onProfilePage();
  }

  @override
  void didChangePlatformBrightness() {
    util.changeTheme(themeSwitcherState, context);
    super.didChangePlatformBrightness();
  }

  @override
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeSwitchingArea(
      child: ThemeSwitcher.switcher(
        builder: (p0, switcher) => Builder(builder: (context) {
          themeSwitcherState ??= switcher;
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
              listener: listener,
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
                              child: GestureDetector(
                                onTap: () {
                                  if (state.user.profileURL != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ViewMediaPage(
                                          message: MessageModel(
                                              message: state.user.profileURL,
                                              messageType: 'image'),
                                        ),
                                      ),
                                    );
                                  } else {
                                    util.showSnackbar(
                                        context, 'No profile', 'info');
                                  }
                                },
                                child: CircularProfileImage(
                                  isNetworkImage: state.user.profileURL != null,
                                  image: state.user.profileURL,
                                ),
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
                          GeneralOptions(general: general),
                          const Gap(12),
                          PreferenceOptions(state: state),
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
      ),
    );
  }

  void listener(context, state) {
    if (state is SignOut) {
      Navigator.pushNamedAndRemoveUntil(context, 'auth', (route) => false);
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
  }
}

class GeneralOptions extends StatelessWidget {
  const GeneralOptions({
    super.key,
    required this.general,
  });

  final List general;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              style: style.text.boldLarge.copyWith(color: AppColor.greyText),
            ),
          ),
          const Gap(10),
          ...general.map(
            (e) => Material(
              color: Theme.of(context).colorScheme.inverseSurface,
              child: InkWell(
                onTap: () {
                  if (e['title'] == "Change Password") {
                    context.read<ProfileCubit>().passwordResetDialog();
                  } else if (e['title'] == "Edit Profile") {
                    Navigator.pushNamed(context, 'profile-edit');
                  } else {
                    context.read<UpdateCubit>().checkforUpdate('manual');
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
                              .withValues(alpha: 0.5),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        e['title'],
                                        style: style.text.boldMedium.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .tertiaryContainer),
                                      ),
                                      if (e['title'] == 'Check for Update')
                                        BlocBuilder<UpdateCubit, UpdateState>(
                                          builder: (context, state) {
                                            return Expanded(
                                              child: Text(
                                                '  (Version: ${context.read<UpdateCubit>().currentVersion})',
                                                style: style.text.regularSmall,
                                              ),
                                            );
                                          },
                                        )
                                    ],
                                  ),
                                  Text(e['subTitle'],
                                      style: style.text.semiBoldSmall
                                          .copyWith(color: AppColor.greyText))
                                ],
                              ),
                            ),
                            if (e['title'] != 'Check for Update')
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
    );
  }
}

class PreferenceOptions extends StatelessWidget {
  final ProfileInitial state;
  const PreferenceOptions({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          ThemeSwitcher.switcher(builder: (context, theme) {
            return ProfilePrefTile(
              title: "Theme",
              subtitle: 'Change theme',
              leadingIcon: 'themes',
              action: ThemeDropDown(
                selectedTheme: state.appTheme,
                onchange: (value) {
                  BlocProvider.of<ProfileCubit>(context)
                      .changeTheme(theme, value);
                },
              ),
            );
          }),
          ProfilePrefTile(
              leadingIcon: 'bell',
              title: 'Notification',
              subtitle: 'Customize your notification preference',
              action: Switch(
                  inactiveThumbColor: AppColor.greyText,
                  activeColor: AppColor.blue,
                  value: state.isNotification ?? false,
                  onChanged: (v) {
                    context.read<ProfileCubit>().changeNotificationPref();
                  })),
          Material(
            color: Theme.of(context).colorScheme.inverseSurface,
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
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ThemeDropDown extends StatefulWidget {
  const ThemeDropDown({
    super.key,
    required this.onchange,
    this.selectedTheme,
  });

  final AppTheme? selectedTheme;
  final Function(AppTheme value) onchange;

  @override
  State<ThemeDropDown> createState() => _ThemeDropDownState();
}

class _ThemeDropDownState extends State<ThemeDropDown> {
  final List themes = [
    {
      'name': 'Light',
      'value': AppTheme.light,
      'icon': Icons.light_mode,
    },
    {
      'name': 'Dark',
      'value': AppTheme.dark,
      'icon': Icons.dark_mode,
    },
    {
      'name': 'Device',
      'value': AppTheme.system,
      'icon': Icons.phone_android,
    }
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: style.insets.sm),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(style.radius.sm),
          border: Border.all(
              color: Theme.of(context).colorScheme.tertiaryContainer)),
      child: DropdownButton<AppTheme>(
          padding: EdgeInsets.all(5),
          style: style.text.regular
              .copyWith(color: Theme.of(context).colorScheme.tertiaryContainer),
          isDense: true,
          value: widget.selectedTheme ?? AppTheme.light,
          dropdownColor: Theme.of(context).colorScheme.onTertiary,
          underline: SizedBox(),
          items: List.generate(themes.length, (index) {
            return DropdownMenuItem<AppTheme>(
              value: themes[index]['value'],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  spacing: style.insets.sm,
                  children: [
                    Icon(
                      themes[index]['icon'],
                      size: 18,
                      color: AppColor.blue,
                    ),
                    Text(
                      themes[index]['name'],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              widget.onchange(value);
            }
          }),
    );
  }
}
