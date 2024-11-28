import 'dart:async';
import 'dart:convert';
import 'package:chit_chat/main.dart';
import 'package:chit_chat/model/user_data.dart';
import 'package:chit_chat/res/common_instants.dart';
import 'package:chit_chat/view/screen/chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin localNotification =
      FlutterLocalNotificationsPlugin();

  initialize() async {
    await firebaseMessaging.requestPermission(
        badge: true, alert: true, announcement: false, sound: true);
    await localNotification.initialize(
      onDidReceiveNotificationResponse: onClickLocalNotification,
      onDidReceiveBackgroundNotificationResponse: onNotificationAction,
      const InitializationSettings(
        android: AndroidInitializationSettings(
          '@mipmap/launcher_icon',
        ),
      ),
    );

    FirebaseMessaging.onMessage.listen(onArriveForegroundMsg);
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

  void createProgressNotification(int count, int i, int id) {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'progress channel',
      'progress channel',
      channelDescription: 'progress channel description',
      channelShowBadge: false,
      importance: Importance.min,
      priority: Priority.min,
      onlyAlertOnce: true,
      showProgress: true,
      maxProgress: count,
      progress: i,
      actions: [
        const AndroidNotificationAction('cancel', 'Cancel'),
        const AndroidNotificationAction('pause', 'Pause'),
      ],
    );
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    localNotification.show(
        id, 'CC9023029320.jpg', "$i/100", platformChannelSpecifics,
        payload: 'item x');
  }

  cancelNotification(int id) {
    localNotification.cancel(id);
  }

  cancelGroupNotification(String userId) {
    RegExp regExp = RegExp(r'\d+');
    final integer =
        regExp.allMatches(userId).map((match) => match.group(0)).join();
    int notificationId = int.parse(integer);
    localNotification.cancel(notificationId);
  }
}

Future onArriveForegroundMsg(RemoteMessage message) async {
  List<RemoteMessage> messages = [];
  SharedPreferences sp = await SharedPreferences.getInstance();
  String receiverId = sp.getString('receiverId') ?? '';
  final Map<String, dynamic> data = jsonDecode(message.data['user']);
  final UserData userData = UserData.fromJson(data);

  final String? docId = message.data['messageDocId'];
  final String? roomId = message.data['chatRoomId'];

  const String groupChannelId = 'grouped channel id';
  const String groupChannelName = 'Chat Messages';
  const String groupChannelDescription = 'grouped channel description';

  if (docId != null && roomId != null) {
    FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(roomId)
        .collection('message')
        .doc(docId)
        .update({'status': 'delivered'});
  }

  if (receiverId != userData.uid) {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.reload();
    final localnotiMessages = sp.getStringList('notificationMessages') ?? [];
    messages = localnotiMessages
        .map((ele) => RemoteMessage.fromMap(json.decode(ele)))
        .toList();

    messages.add(message);
    await sp.setStringList('notificationMessages',
        messages.map((ele) => json.encode(ele.toMap())).toList());

    String userId = json.decode(message.data['user'])['uid'];
    String userName = json.decode(message.data['user'])['userName'];
    String? userProfile = json.decode(message.data['user'])['profileURL'];

    final currentUserList = messages
        .where((message) => json.decode(message.data['user'])['uid'] == userId)
        .toList();

    // final badgeCount = messages
    //     .map((message) => json.decode(message.data['user'])['uid'] as String)
    //     .toSet()
    //     .length;

    // setBadgeCount(badgeCount);

    groupNotification(groupChannelId, groupChannelName, groupChannelDescription,
        userId, userName, currentUserList, userProfile);
  }
}
