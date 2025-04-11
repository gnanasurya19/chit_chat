import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:animations/animations.dart';
import 'package:chit_chat/controller/home_cubit/home_cubit.dart';
import 'package:chit_chat/controller/profile_cubit/profile_cubit.dart';
import 'package:chit_chat/controller/update_cubit/update_cubit.dart';
import 'package:chit_chat/res/colors.dart';
import 'package:chit_chat/res/common_instants.dart';
import 'package:chit_chat/res/custom_widget/svg_icon.dart';
import 'package:chit_chat/view/screen/chat_page.dart';
import 'package:chit_chat/view/screen/search_page.dart';
import 'package:chit_chat/view/widget/circular_profile_image.dart';
import 'package:chit_chat/view/widget/update_dialog.dart';
import 'package:chit_chat/view/widget/user_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late HomeCubit _homeCubit;
  @override
  void initState() {
    BlocProvider.of<HomeCubit>(context).onInit();
    BlocProvider.of<HomeCubit>(context).downloadListener();
    BlocProvider.of<ProfileCubit>(context).getProfile();

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((target) {
      BlocProvider.of<HomeCubit>(context).checkNotificationStack();
    });
    super.initState();
  }

  ThemeSwitcherState? themeSwitcherState;

  @override
  void didChangePlatformBrightness() {
    util.changeTheme(themeSwitcherState, context);
    super.didChangePlatformBrightness();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _homeCubit.pauseStream();
    } else if (state == AppLifecycleState.resumed) {
      _homeCubit.resumeStream();
    }
  }

  @override
  void didChangeDependencies() {
    _homeCubit = BlocProvider.of<HomeCubit>(context);
    super.didChangeDependencies();
  }

  @override
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    _homeCubit.stopStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeSwitcher.switcher(
      builder: (p0, switcher) => Builder(builder: (context) {
        themeSwitcherState ??= switcher;
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surfaceDim,
          appBar: AppBar(
            toolbarHeight: kTextTabBarHeight + 30,
            titleSpacing: 20,
            title: Text(
              'ChitChat',
              style: style.text.regularLarge.copyWith(color: AppColor.darkBlue),
            ),
            backgroundColor: Theme.of(context).colorScheme.surfaceDim,
            actions: [
              BlocListener<UpdateCubit, UpdateState>(
                listener: (context, state) {
                  if (state is UpdateAvailableState) {
                    util.slideInDialog(context, UpdateDialog(), false);
                  } else if (state is NetworkErrorState) {
                    util.doAlert(
                        context, 'Please connect to internet', 'network');
                  } else if (state is UptoDateState) {
                    util.showSnackbar(context, 'You are up to date', 'success');
                  } else if (state is UpdateAlertState) {
                    util.doAlert(context, state.text, state.type);
                  }
                },
                child: BlocBuilder<ProfileCubit, ProfileState>(
                  buildWhen: (previous, current) =>
                      current is! ProfileActionState,
                  builder: (context, state) {
                    if (state is ProfileInitial) {
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          Navigator.pushNamed(context, 'profile');
                        },
                        child: Hero(
                          tag: 'profile',
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            height: 40,
                            width: 40,
                            child: CircularProfileImage(
                              isNetworkImage: state.user.profileURL != null,
                              image: state.user.profileURL,
                            ),
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
              )
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              context.read<HomeCubit>().toSearch();
            },
            child: const SVGIcon(
              name: 'message-plus',
              color: AppColor.white,
              size: 30,
            ),
          ),
          body: BlocConsumer<HomeCubit, HomeState>(
            listenWhen: (previous, current) => current is HomeActionState,
            listener: (context, state) {
              listener(state, context, context.read<HomeCubit>());
            },
            buildWhen: (previous, current) => current is! HomeActionState,
            builder: (context, state) {
              if (state is HomeReadyState) {
                if (state.userList.isEmpty) {
                  return WelcomeWidget(
                    username: FirebaseAuth.instance.currentUser!.displayName!
                        .toUpperCase(),
                  );
                }
                return ListView.builder(
                  itemCount: state.userList.length,
                  itemBuilder: (context, index) {
                    return OpenContainer(
                      closedElevation: 0,
                      tappable: false,
                      openColor: Theme.of(context).colorScheme.surfaceDim,
                      closedColor: Theme.of(context).colorScheme.surfaceDim,
                      openBuilder: (context, action) =>
                          ChatPage(userData: state.userList[index]),
                      closedBuilder: (context, action) => UserCard(
                        user: state.userList[index],
                        onTap: (userData) {
                          // BlocProvider.of<ChatCubit>(context)
                          //     .onInit(state.userList[index].uid!, userData);
                          action.call();
                        },
                      ),
                    );
                  },
                );
              } else if (state is HomeChatLoading) {
                return ListView.builder(
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return ListTile(
                          leading: Container(
                              width: 50,
                              height: 50,
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              decoration:
                                  const BoxDecoration(shape: BoxShape.circle),
                              child: const CircularProfileImage(
                                  isNetworkImage: false)),
                          contentPadding: const EdgeInsets.all(15),
                          title: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              height: 20,
                              width: MediaQuery.sizeOf(context).width * 0.3,
                              color: AppColor.greyline,
                            ),
                          ),
                          subtitle: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              height: 10,
                              width: MediaQuery.sizeOf(context).width * 0.15,
                              color: AppColor.greyline,
                            ),
                          ));
                    });
              } else {
                return const SizedBox();
              }
            },
          ),
        );
      }),
    );
  }

  void listener(
      HomeState state, BuildContext context, HomeCubit homeController) {
    if (state is HomeToSearch) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchPage(chatList: homeController.userList),
        ),
      );
    }
  }
}

class WelcomeWidget extends StatelessWidget {
  final String username;
  const WelcomeWidget({
    super.key,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LottieBuilder.asset(
              'assets/lottie/welcome_animation.json',
              width: MediaQuery.of(context).size.width * 0.35,
            ),
            Text(
              'Welcome ${username.toUpperCase()}',
              style: style.text.boldXLarge,
            ),
            Text('Click the  Button below to connect with your friends...',
                textAlign: TextAlign.center, style: style.text.regular),
          ],
        ),
      ),
    );
  }
}
