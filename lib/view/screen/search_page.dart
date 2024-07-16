import 'package:chit_chat/controller/chat_cubit/chat_cubit.dart';
import 'package:chit_chat/controller/search_cubit/search_cubit.dart';
import 'package:chit_chat/model/user_data.dart';
import 'package:chit_chat/res/colors.dart';
import 'package:chit_chat/res/fonts.dart';
import 'package:chit_chat/view/screen/chat_page.dart';
import 'package:chit_chat/view/widget/user_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserSearch extends StatefulWidget {
  final List<UserData> chatList;
  const UserSearch({super.key, required this.chatList});

  @override
  State<UserSearch> createState() => _UserSearchState();
}

class _UserSearchState extends State<UserSearch> {
  @override
  void initState() {
    BlocProvider.of<SearchCubit>(context).onInit(widget.chatList);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = BlocProvider.of<SearchCubit>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.inverseSurface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leadingWidth: MediaQuery.of(context).size.width * 0.1,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: AppColor.white,
            )),
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: TextField(
          style: const TextStyle(color: AppColor.white),
          autofocus: true,
          cursorColor: AppColor.white,
          autocorrect: true,
          onChanged: (value) {
            searchProvider.onSearch(value);
          },
          decoration: const InputDecoration(
              focusColor: AppColor.black, border: InputBorder.none),
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '*You have to enter your receiver email address completly(who is not in your chat list) to get result. This is to protect the receivers email from intruders',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.tertiary,
                  fontSize: AppFontSize.xxs),
            ),
          ),
          BlocConsumer<SearchCubit, SearchState>(
            listenWhen: (previous, current) => current is SearchActionState,
            listener: (BuildContext context, SearchState state) {},
            buildWhen: (previous, current) => current is! SearchActionState,
            builder: (context, state) {
              if (state is SearchReadyState) {
                return Column(
                  children: [
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.userList.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) => UserCard(
                        user: state.userList[index],
                        onTap: (user) {
                          BlocProvider.of<ChatCubit>(context)
                              .onInit(state.userList[index].uid!);
                          Navigator.pop(context);
                          Navigator.push(context, PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) {
                              final Tween<Offset> tween = Tween<Offset>(
                                  begin: const Offset(1, 0),
                                  end: const Offset(0, 0));
                              final Animation<Offset> offsetAnimation =
                                  animation.drive(tween);
                              return SlideTransition(
                                  position: offsetAnimation,
                                  child: ChatPage(
                                      userData: state.userList[index]));
                            },
                          ));
                        },
                      ),
                    ),
                    if (state.chatList.isNotEmpty)
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.all(8.0),
                        child: const Text(
                          'Your chat list',
                          style: TextStyle(
                              color: AppColor.greyText,
                              fontFamily: Roboto.medium),
                        ),
                      ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.chatList.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) => UserCard(
                        user: state.chatList[index],
                        onTap: (user) {
                          Navigator.pop(context);
                          Navigator.push(context, PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) {
                              final Tween<Offset> tween = Tween<Offset>(
                                  begin: const Offset(1, 0),
                                  end: const Offset(0, 0));
                              final Animation<Offset> offsetAnimation =
                                  animation.drive(tween);
                              return SlideTransition(
                                  position: offsetAnimation,
                                  child: ChatPage(
                                      userData: state.chatList[index]));
                            },
                          ));
                        },
                      ),
                    ),
                  ],
                );
              } else {
                return Container();
              }
            },
          )
        ],
      ),
    );
  }
}
