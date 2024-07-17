import 'package:chit_chat/model/user_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit()
      : super(SearchReadyState(userList: const [], chatList: const []));
  List<UserData> userList = [];
  List<UserData> chatList = [];
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  onInit(List<UserData> list) {
    chatList = list;
    emit(SearchReadyState(userList: const [], chatList: chatList));
  }

  List<UserData> newUserList = [];

  onSearch(String email) async {
    List<UserData> list = [];
    userList = [];

    list = chatList
        .where((element) =>
            (element.userEmail!.toLowerCase().contains(email.toLowerCase()) ||
                element.userName!.toLowerCase().contains(email.toLowerCase())))
        .toList();

    await firebaseFirestore
        .collection('users')
        .where(
          'userEmail',
          isEqualTo: email,
          isNotEqualTo: firebaseAuth.currentUser!.email,
        )
        .get()
        .then((value) {
      for (var element in value.docs) {
        final user = UserData.fromJson(element.data());
        if (!chatList.contains(user)) {
          userList.add(user);
        }
      }
      emit(SearchReadyState(
        userList: userList,
        chatList: list,
      ));
    });
  }

  // navTochat(UserData user) {
  //   emit(SearchToChatState(user: user));
  // }
}
