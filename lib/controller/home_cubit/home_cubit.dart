import 'dart:async';

import 'package:chit_chat/firebase/firebase_repository.dart';
import 'package:chit_chat/model/message_model.dart';
import 'package:chit_chat/model/user_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeReadyState(userList: const [])) {
    getLocalInfo();
  }

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? userListStream;
  getLocalInfo() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString('receiverId', '');
  }

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String get currentUserId => firebaseAuth.currentUser!.uid;
  FirebaseRepository firebaseRepository = FirebaseRepository();
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  List<UserData> userList = [];
  onInit() async {
    firebaseAuth = FirebaseAuth.instance;
    emit(HomeChatLoading());

    userList = [];
    userListStream = firebaseFirestore
        .collection('chatrooms')
        .where('roomid', arrayContains: currentUserId)
        .snapshots()
        .listen((chatRooms) async {
      await Future.forEach(
        chatRooms.docs,
        (roomdIds) async {
          String userId = (roomdIds.data()['roomid'] as List)[0];
          userId = userId == currentUserId
              ? (roomdIds.data()['roomid'] as List)[1]
              : userId;

          await firebaseFirestore
              .collection('users')
              .where('uid', isEqualTo: userId)
              .limit(1)
              .get()
              .then(
            (value) {
              if (value.docs.isNotEmpty) {
                userList.add(UserData.fromJson(value.docs.first.data()));
              }
            },
          );
        },
      );
      emit(HomeReadyState(userList: userList));
      bindlatestData();
    });
  }

  Future<void> bindlatestData() async {
    await Future.forEach(userList, (element) {
      if (currentUserId != element.uid) {
        final List ids = [currentUserId, element.uid];
        ids.sort();
        String chatRoomId = ids.join('');

        firebaseFirestore
            .collection('chatrooms')
            .doc(chatRoomId)
            .collection('message')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .snapshots()
            .listen((value) {
          if (value.docs.isNotEmpty) {
            final MessageModel message =
                MessageModel.fromJson(value.docs[0].data(), value.docs[0].id);
            for (var ele in userList) {
              if (message.receiverID == ele.uid ||
                  message.senderID == ele.uid) {
                ele.lastMessage = message;
              }
            }

            userList.sort((a, b) {
              if (a.lastMessage != null && b.lastMessage != null) {
                return (b.lastMessage!.timestamp!)
                    .compareTo(a.lastMessage!.timestamp!);
              } else {
                return 0;
              }
            });
            emit(HomeReadyState(userList: userList));
          }
        });
      }
    });
  }

  toSearch() {
    emit(HomeToSearch());
  }

  @override
  Future<void> close() {
    if (userListStream != null) {
      userListStream!.cancel();
    }
    return super.close();
  }
}
