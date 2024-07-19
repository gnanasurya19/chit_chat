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
      onDidReceiveNotificationResponse: onClickLocalNotification,
      const InitializationSettings(
        android: AndroidInitializationSettings(
          '@mipmap/launcher_icon',
        ),
      ),
    );
    FirebaseMessaging.onMessage.listen(onArriveForegroundMsg);

    FirebaseMessaging.onMessageOpenedApp.listen(onClickFirebaseMessage);
  }

  void onClickLocalNotification(NotificationResponse details) {
    if (navigationKey.currentState != null) {
      final data = jsonDecode(details.payload!);
      final UserData userData = UserData.fromJson(data);
      Navigator.push(
          navigationKey.currentContext!,
          MaterialPageRoute(
            builder: (context) => ChatPage(userData: userData),
          ));
    }
  }
}

int id = 0;
Future onArriveForegroundMsg(RemoteMessage message) async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  String receiverId = sp.getString('receiverId') ?? '';
  final Map<String, dynamic> data = jsonDecode(message.data['user']);
  final UserData userData = UserData.fromJson(data);

  if (receiverId != userData.uid) {
    FlutterLocalNotificationsPlugin().show(
      id++,
      message.notification!.title,
      message.notification!.body,
      payload: message.data['user'],
      const NotificationDetails(
        iOS: DarwinNotificationDetails(),
        android: AndroidNotificationDetails(
          "grouped channel id",
          "grouped channel name",
          importance: Importance.max,
          priority: Priority.max,
        ),
      ),
    );
  }
}

Future onForegruondMsg(RemoteMessage message) async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  String receiverId = sp.getString('receiverId') ?? '';
  final data = jsonDecode(message.data['user']);
  final UserData userData = UserData.fromJson(data);

  if (receiverId != userData.uid) {
    String groupKey = 'com.example.chit_chat.${userData.userName}';
    String groupChannelId = userData.uid!;
    String groupChannelName = 'Grouped_${userData.userName}';
    const String groupChannelDescription =
        'This channel is used for grouped notifications.';

    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      groupChannelId,
      groupChannelName,
      channelDescription: groupChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
      groupKey: groupKey,
    );

    await FlutterLocalNotificationsPlugin().show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      NotificationDetails(android: androidNotificationDetails),
    );
  }
}

Future onClickFirebaseMessage(RemoteMessage message) async {
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
