import 'dart:convert';
import 'dart:typed_data';

import 'package:chit_chat/firebase_options.dart';
import 'package:chit_chat/network/network_api_service.dart';
import 'package:chit_chat/notification/notification_service.dart';
// import 'package:chit_chat/notification/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_app_badger/flutter_app_badger.dart';
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
final notificationService = NotificationService();
String token = "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";

@pragma('vm:entry-point')
Future<void> onBackgroundMsg(RemoteMessage message) async {
  List<RemoteMessage> messages = [];
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final String? docId = message.data['messageDocId'];
  final String? roomId = message.data['chatRoomId'];

  const String groupChannelId = 'grouped channel id';
  const String groupChannelName = 'Chat Messages';
  const String groupChannelDescription = 'grouped channel description';

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
    // store notification to local
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

    // FlutterLocalNotificationsPlugin().show(
    //   DateTime.now().microsecondsSinceEpoch % 10000000,
    //   userData.userName,
    //   message.data['body'],
    //   payload: jsonEncode(message.data),
    //   NotificationDetails(
    //     iOS: const DarwinNotificationDetails(),
    //     android: AndroidNotificationDetails(
    //         "grouped channel id", "grouped channel name",
    //         channelDescription: 'Description',
    //         importance: Importance.max,
    //         priority: Priority.max,
    //         groupKey: userId,
    //         actions: [
    //           const AndroidNotificationAction(
    //             '0',
    //             'mark as read',
    //             titleColor: Colors.lightBlue,
    //             cancelNotification: true,
    //           )
    //         ]),
    //   ),
    // );
  }
}

@pragma('vm:entry-point')
setBadgeCount(int count) async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  sp.setInt('badgeCount', count);
  print('entered');

  print(count);
  if (count == 0) {
    // FlutterAppBadger.removeBadge(0);
    // FlutterAppBadgeControl().getPlatformVersion();
    print('badge');
  } else {
    // print(await FlutterAppBadgeControl.isAppBadgeSupported());
    // FlutterAppBadger.updateBadgeCount(2);
    print('count');
    // FlutterAppBadgeControl.updateBadgeCount(count).then((value) {
    // print('success');
    // });
  }
}

@pragma('vm:entry-point')
decreaseBadgeCount() async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  int count = sp.getInt('badgeCount') ?? 0;
  count--;
  if (count <= 0) {
    // FlutterAppBadger.removeBadge();
    // FlutterAppBadgeControl.removeBadge();
  } else {
    await sp.setInt('badgeCount', count);
    // FlutterAppBadger.updateBadgeCount(count);
    // FlutterAppBadgeControl.updateBadgeCount(count);
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

    removeReadMsg(roomId);
    // decreaseBadgeCount();

    collection.where('status', isNotEqualTo: 'read').get().then((value) {
      for (var element in value.docs) {
        collection.doc(element.id).update({'status': 'read', 'batch': 0});
      }
    });
  }
}

@pragma('vm:entry-point')
Future<void> removeReadMsg(String roomId) async {
  List<RemoteMessage> messages = [];
  SharedPreferences sp = await SharedPreferences.getInstance();
  final localnotiMessages = sp.getStringList('notificationMessages') ?? [];
  messages = localnotiMessages
      .map((ele) => RemoteMessage.fromMap(json.decode(ele)))
      .toList();
  messages.removeWhere((ele) => ele.data['chatRoomId'] == roomId);
  await sp.setStringList('notificationMessages',
      messages.map((ele) => json.encode(ele.toMap())).toList());
}

@pragma('vm:entry-point')
Future<void> groupNotification(
    String groupChannelId,
    String groupChannelName,
    String groupChannelDescription,
    String userId,
    String userName,
    List<RemoteMessage> messages,
    String? image) async {
  Uint8List? imageBytes;
  Uint8List? circularImage;
  if (image != null) {
    imageBytes = await util.getProfileFromLocal(image);
  }
  if (imageBytes != null) {
    circularImage = await util.createCircularBitmap(imageBytes);
  }

  AndroidNotificationDetails summaryNotificationDetails =
      AndroidNotificationDetails(
    groupChannelId,
    groupChannelName,
    channelDescription: groupChannelDescription,
    importance: Importance.max,
    priority: Priority.max,
    groupKey: userId,
    playSound: false,
    groupAlertBehavior: GroupAlertBehavior.summary,
    actions: [
      const AndroidNotificationAction(
        '0',
        'mark as read',
        titleColor: Colors.lightBlue,
        cancelNotification: true,
      )
    ],
    setAsGroupSummary: true,
    styleInformation: MessagingStyleInformation(
      Person(
          name: userName.toUpperCase(),
          icon: circularImage != null
              ? ByteArrayAndroidIcon(circularImage)
              : const DrawableResourceAndroidIcon('@mipmap/launcher_icon')),
      conversationTitle: userName.toUpperCase(),
      messages: messages
          .map(
            (msg) => Message(
              msg.data['body'],
              DateTime.now(),
              Person(
                  name: userName.toUpperCase(),
                  important: true,
                  key: userId,
                  icon: circularImage != null
                      ? ByteArrayAndroidIcon(circularImage)
                      : null),
            ),
          )
          .toList(),
    ),
  );

  RegExp regExp = RegExp(r'\d+');
  final integer =
      regExp.allMatches(userId).map((match) => match.group(0)).join();

  await notificationService.localNotification.show(
    int.parse(integer),
    userName.toUpperCase(),
    messages.last.data['body'],
    payload: jsonEncode(messages.first.data),
    NotificationDetails(android: summaryNotificationDetails),
  );
}
