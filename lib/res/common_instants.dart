import 'dart:convert';

import 'package:chit_chat/firebase_options.dart';
import 'package:chit_chat/network/network_api_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chit_chat/main.dart';
import 'package:chit_chat/model/user_data.dart';
import 'package:chit_chat/res/style.dart';
import 'package:chit_chat/utils/util.dart';

Util util = Util();
AppStyle get style => MainApp.style;
FirebaseAuth firebaseAuth = FirebaseAuth.instance;
String get currentUserId => firebaseAuth.currentUser!.uid;
NetworkApiService networkApiService = NetworkApiService();

String token = "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";

@pragma('vm:entry-point')
Future<void> onBackgroundMsg(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final String? docId = message.data['messageDocId'];
  final String? roomId = message.data['chatRoomId'];
  FirebaseFirestore.instance
      .collection('chatrooms')
      .doc(roomId)
      .collection('message')
      .doc(docId)
      .update({'status': 'delivered'});

  SharedPreferences sp = await SharedPreferences.getInstance();
  String receiverId = sp.getString('receiverId') ?? '';
  final Map<String, dynamic> data = jsonDecode(message.data['user']);
  final UserData userData = UserData.fromJson(data);

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
            // ongoing: true,
            actions: [
              AndroidNotificationAction(
                '0',
                'mark as read',
                titleColor: Colors.lightBlue,
                cancelNotification: true,
                // cancelNotification: true,
              )
            ]),
      ),
    );
  }
}

@pragma('vm:entry-point')
Future<void> onNotificationAction(NotificationResponse details) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final message = jsonDecode(details.payload!);
  final String? docId = message['messageDocId'];
  final String? roomId = message['chatRoomId'];

  if (docId != null && roomId != null) {
    var collection = FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(roomId)
        .collection('message');

    collection.where('status', isNotEqualTo: 'read').get().then((value) {
      for (var element in value.docs) {
        collection.doc(element.id).update({'status': 'read', 'batch': 0});
      }
    });
  }
}
