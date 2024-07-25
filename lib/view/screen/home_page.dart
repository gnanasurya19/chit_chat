import 'package:animations/animations.dart';
import 'package:chit_chat/controller/chat_cubit/chat_cubit.dart';
import 'package:chit_chat/controller/home_cubit/home_cubit.dart';
import 'package:chit_chat/controller/profile_cubit/profile_cubit.dart';
import 'package:chit_chat/res/colors.dart';
import 'package:chit_chat/res/custom_widget/loading_widget.dart';
import 'package:chit_chat/res/custom_widget/svg_icon.dart';
import 'package:chit_chat/res/fonts.dart';
import 'package:chit_chat/view/screen/chat_page.dart';
import 'package:chit_chat/view/screen/search_page.dart';
import 'package:chit_chat/view/widget/circular_profile_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../widget/user_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    BlocProvider.of<HomeCubit>(context).onInit();
    BlocProvider.of<ProfileCubit>(context).getProfile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceDim,
      appBar: AppBar(
        toolbarHeight: kTextTabBarHeight + 30,
        titleSpacing: 20,
        title: const Text('Chitchat',
            style:
                TextStyle(color: AppColor.darkBlue, fontFamily: Roboto.medium)),
        backgroundColor: Theme.of(context).colorScheme.surfaceDim,
        actions: [
          BlocBuilder<ProfileCubit, ProfileState>(
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
                      BlocProvider.of<ChatCubit>(context)
                          .onInit(state.userList[index].uid!);
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
  }

  void listener(
      HomeState state, BuildContext context, HomeCubit homeController) {
    if (state is HomeSignOut) {
      Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
    } else if (state is HomeToSearch) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserSearch(chatList: homeController.userList),
        ),
      );
    } else if (state is HomeEditProfile) {
      // showDialog(
      //   context: context,
      //   builder: (context) {
      //     return Dialog(
      //       clipBehavior: Clip.antiAliasWithSaveLayer,
      //       child: Column(
      //         mainAxisSize: MainAxisSize.min,
      //         children: [
      //           ListTile(
      //             onTap: () {
      //               Navigator.pop(context);
      //               BlocProvider.of<HomeCubit>(context)
      //                   .pickImage(ImageSource.camera);
      //             },
      //             leading: const Icon(
      //               Icons.camera,
      //             ),
      //             title: const Text('Capture Image'),
      //           ),
      //           ListTile(
      //             onTap: () {
      //               Navigator.pop(context);
      //               BlocProvider.of<HomeCubit>(context)
      //                   .pickImage(ImageSource.gallery);
      //             },
      //             leading: const Icon(Icons.image),
      //             title: const Text('Pick from galary'),
      //           ),
      //         ],
      //       ),
      //     );
      //   },
      // );
    } else if (state is HomeScreenLoading) {
      showDialog(
        context: context,
        builder: (context) => const LoadingScreen(),
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
              style: const TextStyle(
                fontFamily: Roboto.bold,
                fontSize: AppFontSize.xl,
              ),
            ),
            const Text(
              'Click the 👇 Button below to connect with your friends...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppFontSize.sm,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
