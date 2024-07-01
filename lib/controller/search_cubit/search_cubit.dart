import 'package:chit_chat/model/user_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit()
      : super(SearchReadyState(userList: const [], chatList: const []));
  List<UserData> userList = [];
  List<UserData> chatList = [];
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  onInit(List<UserData> list) {
    chatList = list;
    emit(SearchReadyState(userList: const [], chatList: chatList));
  }

  List<UserData> newUserList = [];
  getUserList() {
    firebaseFirestore.collection('users').snapshots().listen((event) {
      newUserList = [];
      for (var element in event.docs) {
        if (element.data()['uid'] != FirebaseAuth.instance.currentUser!.uid) {
          newUserList.add(UserData.fromJson(element.data()));
        }
      }
      emit(SearchTest(userList: newUserList));
    });
  }

  onSearch(String email) async {
    userList = [];
    List<UserData> list = [];
    list = chatList
        .where((element) =>
            (element.userEmail!.toLowerCase().contains(email.toLowerCase()) ||
                element.userName!.toLowerCase().contains(email.toLowerCase())))
        .toList();
    await firebaseFirestore
        .collection('users')
        .where('userEmail', isEqualTo: email)
        .get()
        .then((value) {
      for (var element in value.docs) {
        final user = UserData.fromJson(element.data());
        if (!chatList.contains(user)) {
          userList.add(user);
        }
      }
      emit(SearchReadyState(userList: userList, chatList: list));
    });
  }

  // navTochat(UserData user) {
  //   emit(SearchToChatState(user: user));
  // }
}
