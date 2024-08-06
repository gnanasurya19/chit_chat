import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:chit_chat/main.dart';
import 'package:chit_chat/model/user_data.dart';
import 'package:chit_chat/view/screen/chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

// int id = 0;

Future<Uint8List> getBytesFromAsset(String path, int width) async {
  ByteData data = await rootBundle.load(path);
  final codec = await instantiateImageCodec(data.buffer.asUint8List(),
      targetWidth: width);
  FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ImageByteFormat.png))!
      .buffer
      .asUint8List();
}

// Future onForegruondMsg(RemoteMessage message) async {
//   SharedPreferences sp = await SharedPreferences.getInstance();
//   String receiverId = sp.getString('receiverId') ?? '';
//   final data = jsonDecode(message.data['user']);
//   final UserData userData = UserData.fromJson(data);

//   if (receiverId != userData.uid) {
//     String groupKey = 'com.myapps.chit_chat.${userData.userName}';
//     String groupChannelId = userData.uid!;
//     String groupChannelName = 'Grouped_${userData.userName}';
//     const String groupChannelDescription =
//         'This channel is used for grouped notifications.';

//     final AndroidNotificationDetails androidNotificationDetails =
//         AndroidNotificationDetails(groupChannelId, groupChannelName,
//             channelDescription: groupChannelDescription,
//             importance: Importance.max,
//             priority: Priority.high,
//             groupKey: groupKey,
//             actions: [const AndroidNotificationAction('0', 'Ok')]);

//     await FlutterLocalNotificationsPlugin().show(
//       message.hashCode,
//       message.notification?.title,
//       message.notification?.body,
//       NotificationDetails(android: androidNotificationDetails),
//     );
//   }
// }

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
      payload: message.data['user'],
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
              )
            ]),
      ),
    );
  }
}
