import 'package:animations/animations.dart';
import 'package:chit_chat/controller/home_cubit/home_cubit.dart';
import 'package:chit_chat/res/colors.dart';
import 'package:chit_chat/res/fonts.dart';
import 'package:chit_chat/view/screen/chat_page.dart';
import 'package:chit_chat/view/screen/search_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widget/side_menu.dart';
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final homeController = BlocProvider.of<HomeCubit>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.inverseSurface,
      drawer: SideMenu(homeController: homeController),
      appBar: AppBar(
        titleSpacing: 0,
        title: const Text('Chitchat',
            style: TextStyle(color: AppColor.white, fontFamily: Roboto.medium)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        iconTheme: const IconThemeData(color: AppColor.white),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          homeController.toSearch();
        },
        child: const Icon(
          Icons.message_rounded,
          color: AppColor.white,
        ),
      ),
      body: BlocListener<HomeCubit, HomeState>(
        listenWhen: (previous, current) => current is HomeActionState,
        listener: (context, state) {
          if (state is HomeSignOut) {
            Navigator.pushNamedAndRemoveUntil(
                context, 'login', (route) => false);
          } else if (state is HomeToSearch) {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      UserSearch(chatList: homeController.userList),
                ));
          }
        },
        child: BlocBuilder<HomeCubit, HomeState>(
          buildWhen: (previous, current) => current is! HomeActionState,
          builder: (context, state) {
            if (state is HomeReadyState) {
              return ListView.builder(
                itemCount: state.userList.length,
                itemBuilder: (context, index) {
                  // if (state.userList[index].lastMessage != null) {
                  return OpenContainer(
                    openColor: Theme.of(context).colorScheme.inverseSurface,
                    closedColor: Theme.of(context).colorScheme.inverseSurface,
                    openBuilder: (context, action) =>
                        ChatPage(userData: state.userList[index]),
                    closedBuilder: (context, action) => UserCard(
                      user: state.userList[index],
                      onTap: null,
                    ),
                  );
                  // }
                  // return const SizedBox();
                },
              );
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }
}
