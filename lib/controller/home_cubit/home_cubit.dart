import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:chit_chat/model/message_model.dart';
import 'package:chit_chat/model/user_data.dart';
import 'package:chit_chat/notification/notification_service.dart';
import 'package:chit_chat/res/common_instants.dart';
import 'package:chit_chat/res/download_upload_callback.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeReadyState(userList: const [])) {
    getLocalInfo();
  }

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? userListStream;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? chatlistStream;
  List<UserData> userList = [];

  FlutterLocalNotificationsPlugin localNotification =
      FlutterLocalNotificationsPlugin();

  final ReceivePort _port = ReceivePort();

  getLocalInfo() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString('receiverId', '');
  }

  checkNotificationStack() async {
    final appLaunchDetails =
        await localNotification.getNotificationAppLaunchDetails();
    NotificationService().onClickTerminatedLNotificatoin(appLaunchDetails);
  }

  Future onInit([bool? isRefresh]) async {
    if (isRefresh == null) {
      emit(HomeChatLoading());
      // userList = [];
    }

    // Permissions
    util.setUpMediaStore();

    // Notification token refresh
    refreshToken();

    checkPendingMessages();

    userListStream = firebaseFirestore
        .collection('chatrooms')
        .where('roomid', arrayContains: currentUserId)
        .snapshots()
        .listen((chatRooms) async {
      final List<UserData> newList = [];
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
                newList.add(UserData.fromJson(value.docs.first.data()));
              }
            },
          );
        },
      );
      userList = newList;
      emit(HomeReadyState(userList: userList));
      bindlatestData();
    });
  }

  Future<void> downloadListener() async {
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port1');

    _port.listen(
      (data) {
        final taskId = (data as List<dynamic>)[0] as String?;
        final status = DownloadTaskStatus.fromInt(data[1] as int);
        final progress = data[2] as int?;

        if (status == DownloadTaskStatus.complete &&
            progress == 100 &&
            taskId != null) {
          onDownloadComplete();
        }
      },
    );

    FlutterDownloader.registerCallback(downloadcallback);
  }

  listernThemeChange(context) {
    // MediaQuery.of(context).platformBrightness.
  }

  Future<void> bindlatestData() async {
    await Future.forEach(userList, (element) {
      if (currentUserId != element.uid) {
        final List ids = [currentUserId, element.uid];
        ids.sort();
        String chatRoomId = ids.join('');

        chatlistStream = firebaseFirestore
            .collection('chatrooms')
            .doc(chatRoomId)
            .collection('message')
            .where('deletedBy', isNotEqualTo: currentUserId)
            .orderBy('deletedBy')
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

  pauseStream() {
    userListStream?.pause();
    chatlistStream?.pause();
  }

  resumeStream() {
    onInit(true);
  }

  void stopStream() {
    userListStream?.cancel();
    chatlistStream?.cancel();
  }

  void checkPendingMessages() {
    final pendingMessages = hiveRepository.getAllPendings();
  }

  @override
  Future<void> close() {
    _port.close();
    if (userListStream != null) {
      userListStream!.cancel();
    }
    if (chatlistStream != null) {
      chatlistStream!.cancel();
    }
    return super.close();
  }
}
