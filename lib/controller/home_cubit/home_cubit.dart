import 'package:chit_chat/firebase/firebase_repository.dart';
import 'package:chit_chat/model/message_model.dart';
import 'package:chit_chat/model/user_data.dart';
import 'package:chit_chat/model/user_model.dart';
import 'package:chit_chat/res/common_instants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeReadyState(user: UserModel(), userList: const [])) {
    getLocalInfo();
  }

  getLocalInfo() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString('receiverId', '');
  }

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseRepository firebaseRepository = FirebaseRepository();
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  UserModel userModel = UserModel();

  List<UserData> userList = [];

  // getCurrentUserData() {
  //   userModel = UserModel(
  //       email: firebaseAuth.currentUser!.email,
  //       name: firebaseAuth.currentUser!.displayName!,
  //       profileURL: firebaseAuth.currentUser!.photoURL);

  //   emit(HomeReadyState(userList: userList, user: userModel));
  // }

  // onInit() async {
  //   firebaseFirestore
  //       .collection('chat_rooms')
  //       .snapshots()
  //       .listen((chatrooms) async {
  //     userList = [];
  //     for (var chatroom in chatrooms.docs) {
  //       if (chatroom.id.contains(currentUserId)) {
  //         final receiverIndex = chatroom.id.indexOf(currentUserId);
  //         String receiverID = '';
  //         if (receiverIndex > 0) {
  //           receiverID = chatroom.id.substring(0, receiverIndex);
  //         } else {
  //           receiverID = chatroom.id.substring(currentUserId.length);
  //         }

  //         await firebaseFirestore
  //             .collection('users')
  //             .where('uid', isEqualTo: receiverID)
  //             .get()
  //             .then((users) async {
  //           final UserData user = UserData.fromJson(users.docs[0].data());
  //           userList.add(user);
  //         });
  //       }
  //     }
  //     emit(HomeReadyState(userList: userList, user: userModel));
  //   });
  // }

  onInit() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    final bool value = sp.getBool('oldUser') ?? false;
    if (value == true) {
      emit(HomeChatLoading());
    }
    userModel = UserModel(
      email: firebaseAuth.currentUser!.email,
      name: firebaseAuth.currentUser!.displayName!,
      profileURL: firebaseAuth.currentUser!.photoURL,
    );

    String currentUserId = firebaseAuth.currentUser!.uid;

    firebaseFirestore
        .collection('chatrooms')
        .where('roomid', arrayContains: currentUserId)
        .snapshots()
        .listen((chatRooms) async {
      userList = [];
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
      emit(HomeReadyState(userList: userList, user: userModel));
      bindlatestData();
    });

    if (userList.isNotEmpty) {
      SharedPreferences sp = await SharedPreferences.getInstance();
      sp.setBool('oldUser', false);
    }
  }

  Future<void> bindlatestData() async {
    await Future.forEach(userList, (element) {
      if (firebaseAuth.currentUser!.uid != element.uid) {
        final List ids = [firebaseAuth.currentUser!.uid, element.uid];
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
                if (message.receiverID == firebaseAuth.currentUser!.uid) {
                  ele.batch = message.batch;
                }
                ele.timestamp = message.timestamp;
                ele.lastMessage = message.message;
                ele.time = message.time;
              }
            }
            userList.sort((a, b) {
              if (a.timestamp != null && b.timestamp != null) {
                return (b.timestamp!).compareTo(a.timestamp!);
              } else {
                return 0;
              }
            });
            emit(HomeReadyState(userList: userList, user: userModel));
          }
        });
      }
    });
  }

  pickImage(ImageSource type) {
    util.captureImage(type).then((value) {
      if (value != null) {
        updateProfile(value);
      }
    });
  }

  updateProfile(XFile? value) {
    firebaseRepository.uploadFile(value!, 'profile').then((value) async {
      userModel.profileURL = value;
      firebaseRepository
          .updateUser(firebaseAuth.currentUser!.uid, {"profileURL": value});
      await firebaseAuth.currentUser!.updatePhotoURL(value);
      emit(HomeReadyState(userList: userList, user: userModel));
    });
  }

  editProfile() {
    emit(HomeEditProfile());
  }

  toSearch() {
    emit(HomeToSearch());
  }

  getCurrentUserData() {
    emit(HomeReadyState(userList: userList, user: userModel));
  }

  signout() async {
    emit(HomeScreenLoading());
    firebaseRepository
        .updateUser(firebaseAuth.currentUser!.uid, {"fcm": ''}).then((value) {
      firebaseAuth.signOut().then((value) {
        emit(HomeSignOut());
      });
    });
  }
}
