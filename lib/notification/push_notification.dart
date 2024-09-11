import 'dart:async';
import 'dart:convert';
import 'package:chit_chat_1/main.dart';
import 'package:chit_chat_1/model/user_data.dart';
import 'package:chit_chat_1/res/common_instants.dart';
import 'package:chit_chat_1/view/screen/chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PuchNotification {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin localNotification =
      FlutterLocalNotificationsPlugin();

  initialize() async {
    await firebaseMessaging.requestPermission();
    await localNotification.initialize(
      onDidReceiveNotificationResponse: onClickLocalNotification,
      onDidReceiveBackgroundNotificationResponse: onNotificationAction,
      const InitializationSettings(
        android: AndroidInitializationSettings(
          '@mipmap/ic_launcher',
        ),
      ),
    );

    FirebaseMessaging.onMessage.listen(onArriveForegroundMsg);

    // FirebaseMessaging.onMessageOpenedApp.listen(onClickFirebaseMessage);
  }

  void onClickLocalNotification(NotificationResponse details) {
    if (navigationKey.currentState != null) {
      final data = jsonDecode(details.payload!);
      final UserData userData = UserData.fromJson(jsonDecode(data['user']));
      Navigator.push(
          navigationKey.currentContext!,
          MaterialPageRoute(
            builder: (context) => ChatPage(userData: userData),
          ));
    }
  }
}

// Future onClickFirebaseMessage(RemoteMessage message) async {
//   if (navigationKey.currentState != null) {
//     final data = jsonDecode(message.data['user']);
//     final UserData userData = UserData.fromJson(data);
//     Navigator.push(
//         navigationKey.currentContext!,
//         MaterialPageRoute(
//           builder: (context) => ChatPage(userData: userData),
//         ));
//   }
// }

Future onArriveForegroundMsg(RemoteMessage message) async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  String receiverId = sp.getString('receiverId') ?? '';
  final Map<String, dynamic> data = jsonDecode(message.data['user']);
  final UserData userData = UserData.fromJson(data);

  final String? docId = message.data['messageDocId'];
  final String? roomId = message.data['chatRoomId'];

  if (docId != null && roomId != null) {
    FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(roomId)
        .collection('message')
        .doc(docId)
        .update({'status': 'delivered'});
  }

  if (receiverId != userData.uid) {
    FlutterLocalNotificationsPlugin().show(
      DateTime.now().microsecondsSinceEpoch % 10000000,
      userData.userName,
      message.data['body'],
      payload: jsonEncode(message.data),
      const NotificationDetails(
        iOS: DarwinNotificationDetails(),
        android: AndroidNotificationDetails(
            "grouped channel id", "grouped channel name",
            importance: Importance.max,
            priority: Priority.max,
            actions: [
              AndroidNotificationAction(
                '0',
                'mark as read',
                titleColor: Colors.lightBlue,
                cancelNotification: true,
              )
            ]),
      ),
    );
  }
}
