import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:chit_chat/model/message_model.dart';
import 'package:chit_chat/model/user_data.dart';
import 'package:chit_chat/res/common_instants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

class NetworkApiService {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future sendMessage(UserData userData, MessageModel message, String msgId,
      String chatRoomId) async {
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
          'data': {
            'title': firebaseAuth.currentUser!.displayName,
            'body': message.message,
            "user": jsonEncode(UserData(
              uid: firebaseAuth.currentUser!.uid,
              userEmail: firebaseAuth.currentUser!.email,
              userName: firebaseAuth.currentUser!.displayName,
              profileURL: firebaseAuth.currentUser?.photoURL,
            ).toJson()),
            "messageDocId": msgId,
            "chatRoomId": chatRoomId,
          },
          "android": {
            "priority": 10,
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

  Future checkUpdate() async {
    try {
      final response = await http.get(
        Uri.parse(
          "https://api.github.com/repos/gnanasurya19/chit_chat/releases/latest",
        ),
        headers: {
          'Authorization': 'Bearer $token',
          "Accept": "application/vnd.github+json",
          "X-GitHub-Api-Version": "2022-11-28"
        },
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw response.statusCode;
      }
    } on SocketException {
      rethrow;
    } on TimeoutException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<Uint8List?> getGetApiRespone(String url) async {
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 50));
      return response.bodyBytes;
    } catch (e) {
      return null;
    }
  }

  dynamic returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        final responseJson = jsonDecode(response.body);
        return responseJson;
      default:
        return response.body;
    }
  }
}
