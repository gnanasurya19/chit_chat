import 'package:chit_chat_1/controller/chat_cubit/chat_cubit.dart';
import 'package:chit_chat_1/controller/search_cubit/search_cubit.dart';
import 'package:chit_chat_1/model/user_data.dart';
import 'package:chit_chat_1/res/colors.dart';
import 'package:chit_chat_1/res/common_instants.dart';
import 'package:chit_chat_1/view/screen/chat_page.dart';
import 'package:chit_chat_1/view/widget/user_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchPage extends StatefulWidget {
  final List<UserData> chatList;
  const SearchPage({super.key, required this.chatList});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchEditingCtl = TextEditingController();
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
        titleSpacing: 0,
        title: TextField(
          style: const TextStyle(color: AppColor.white),
          autofocus: true,
          cursorColor: AppColor.white,
          autocorrect: true,
          controller: searchEditingCtl,
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
              style: style.text.regularXS.copyWith(
                color: Theme.of(context).colorScheme.tertiary,
              ),
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
                        child: Text(
                          'Your chat list',
                          style: style.text.semiBold.copyWith(
                            color: AppColor.greyText,
                          ),
                        ),
                      ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.chatList.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) => UserCard(
                        user: state.chatList[index],
                        onTap: (user) {
                          BlocProvider.of<ChatCubit>(context)
                              .onInit(state.chatList[index].uid!);
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
                    if (state.chatList.isEmpty &&
                        state.userList.isEmpty &&
                        searchEditingCtl.text.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.only(top: 30),
                        child: const Text(
                          'No Result Found',
                          style: TextStyle(fontSize: 20),
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
