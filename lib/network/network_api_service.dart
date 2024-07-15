import 'dart:convert';
import 'package:chit_chat/model/message_model.dart';
import 'package:chit_chat/model/user_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

class NetworkApiService {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future sendMessage(UserData userData, MessageModel message) async {
    final jsonCredentials =
        await rootBundle.loadString('assets/chit-chat-19491-a3bf7aad3fbf.json');
    final creds = auth.ServiceAccountCredentials.fromJson(jsonCredentials);

    final client = await auth.clientViaServiceAccount(
      creds,
      ['https://www.googleapis.com/auth/cloud-platform'],
    );

    if (userData.fCM != null) {
      final notificationData = {
        'message': {
          'token': userData.fCM,
          'notification': {
            'title': firebaseAuth.currentUser!.displayName,
            'body': message.messageType == 'image'
                ? 'sent an image'
                : message.message,
          },
          'data': {
            'title': firebaseAuth.currentUser!.displayName,
            'body': message.message,
            "user": jsonEncode(UserData(
              uid: firebaseAuth.currentUser!.uid,
              userEmail: firebaseAuth.currentUser!.email,
              userName: firebaseAuth.currentUser!.displayName,
            ).toJson())
          }
        }
      };
      const String senderId = '789734382133';
      final http.Response response = await client.post(
        Uri.parse(
            'https://fcm.googleapis.com/v1/projects/$senderId/messages:send'),
        headers: {
          'content-type': 'application/json',
        },
        body: jsonEncode(notificationData),
      );
      returnResponse(response);
    }
  }

  dynamic returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        final responseJson = jsonDecode(response.body);
        return responseJson;
      default:
        throw response.body;
    }
  }
}
