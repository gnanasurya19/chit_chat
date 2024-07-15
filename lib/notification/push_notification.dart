import 'dart:async';
import 'dart:convert';
import 'package:chit_chat/main.dart';
import 'package:chit_chat/model/user_data.dart';
import 'package:chit_chat/view/screen/chat_page.dart';
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
      const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/launcher_icon')),
    );
    FirebaseMessaging.onMessage.listen(onArriveForegroundMsg);

    FirebaseMessaging.onMessageOpenedApp.listen(onClickFirebaseBackgroundMsg);
  }
}

Future onArriveForegroundMsg(RemoteMessage message) async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  String receiverId = sp.getString('receiverId') ?? '';
  final data = jsonDecode(message.data['user']);
  final UserData userData = UserData.fromJson(data);

  if (receiverId != userData.uid) {
    await FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
            'high_importance_channel', 'High Importance Notifications'));

    FlutterLocalNotificationsPlugin().show(
      1,
      message.notification!.title,
      message.notification!.body,
      const NotificationDetails(
        iOS: DarwinNotificationDetails(),
        android: AndroidNotificationDetails(
          "high_importance_channel",
          "High Importance Notifications",
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
}

Future onClickFirebaseBackgroundMsg(RemoteMessage message) async {
  print(
      'kzjdnnnnnnjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjdddddddddddddddddddddddddddddddd');
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
