import 'package:chit_chat/controller/home_cubit/home_cubit.dart';
import 'package:chit_chat/controller/theme_cubit/theme_cubit.dart';
import 'package:chit_chat/res/colors.dart';
import 'package:chit_chat/res/custom_widget/svg_icon.dart';
import 'package:chit_chat/res/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'circular_profile_image.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({
    super.key,
  });

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<HomeCubit>(context).getCurrentUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      child: BlocBuilder<HomeCubit, HomeState>(
        buildWhen: (previous, current) => current is! HomeActionState,
        builder: (context, state) {
          if (state is HomeReadyState) {
            return SafeArea(
              child: ListView(
                children: [
                  Container(
                    height: (MediaQuery.of(context).size.height -
                            MediaQuery.of(context).padding.top -
                            MediaQuery.of(context).padding.bottom) *
                        0.25,
                    color: Theme.of(context).colorScheme.inversePrimary,
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  context.read<HomeCubit>().editProfile();
                                },
                                child: Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle),
                                      width: 75,
                                      height: 75,
                                      child: CircularProfileImage(
                                        image: state.user.profileURL,
                                        isNetworkImage:
                                            state.user.profileURL != null,
                                      ),
                                    ),
                                    Container(
                                      decoration: const BoxDecoration(
                                        color: AppColor.blue,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: AppColor.white,
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                state.user.name!.split('').first.toUpperCase() +
                                    state.user.name!.substring(1),
                                style: const TextStyle(
                                    letterSpacing: 0.7,
                                    fontFamily: Roboto.bold,
                                    fontSize: AppFontSize.sm,
                                    color: AppColor.white),
                              ),
                              Text(
                                state.user.email ?? '',
                                style: const TextStyle(
                                    fontFamily: Roboto.bold,
                                    fontSize: AppFontSize.sm,
                                    color: AppColor.lightgreyText),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            context.read<ThemeCubit>().changeTheme(context);
                          },
                          child: Builder(builder: (context) {
                            if (MediaQuery.of(context).platformBrightness ==
                                Brightness.light) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 10),
                                child: AnimatedSwitcher(
                                  duration: const Duration(seconds: 3),
                                  child: context.read<ThemeCubit>().themeMode ==
                                          ThemeMode.light
                                      ? const Icon(
                                          Icons.sunny,
                                          color: AppColor.white,
                                        )
                                      : const Icon(
                                          Icons.circle,
                                          color: AppColor.white,
                                        ),
                                ),
                              );
                            } else {
                              return const Icon(
                                Icons.circle,
                                color: AppColor.white,
                              );
                            }
                          }),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: (MediaQuery.of(context).size.height -
                            MediaQuery.of(context).padding.top -
                            MediaQuery.of(context).padding.bottom) *
                        0.75,
                    color: Theme.of(context).colorScheme.inverseSurface,
                    child: Column(
                      children: [
                        ListTile(
                          onTap: () {
                            context.read<HomeCubit>().signout();
                          },
                          leading: const SVGIcon(
                            name: 'svg/signout.svg',
                            size: 20.0,
                            color: AppColor.greyText,
                          ),
                          title: const Text('Sign out'),
                        ),
                      ],
                    ),
                  ),
                ],
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
