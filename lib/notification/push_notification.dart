import 'dart:async';
import 'dart:convert';
import 'package:chit_chat/main.dart';
import 'package:chit_chat/model/user_data.dart';
import 'package:chit_chat/view/screen/chat_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PuchNotification {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin localNotification =
      FlutterLocalNotificationsPlugin();

  initialize() async {
    await firebaseMessaging.requestPermission();
    await localNotification.initialize(
      const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/launcher_icon')),
    );
    FirebaseMessaging.onMessage.listen(onArriveForegroundMsg);
    FirebaseMessaging.onMessageOpenedApp.listen(onClickFirebaseBackgroundMsg);
  }
}

Future onArriveForegroundMsg(RemoteMessage message) async {
  FlutterLocalNotificationsPlugin().show(
      1,
      message.notification!.title,
      message.notification!.body,
      NotificationDetails(
          iOS: const DarwinNotificationDetails(),
          android: AndroidNotificationDetails(
              message.messageId!, message.notification!.body!)));
}

Future onClickFirebaseBackgroundMsg(RemoteMessage message) async {
  if (navigationKey.currentState != null) {
    final data = jsonDecode(message.data['user']);
    final UserData userData = UserData.fromJson(data);
    Navigator.push(
        navigationKey.currentContext!,
        MaterialPageRoute(
          builder: (context) => ChatPage(userData: userData),
        ));
  }
}
