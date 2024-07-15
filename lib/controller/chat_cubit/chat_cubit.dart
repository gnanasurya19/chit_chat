import 'dart:async';

import 'package:chit_chat/firebase/firebase_repository.dart';
import 'package:chit_chat/model/message_model.dart';
import 'package:chit_chat/model/user_data.dart';
import 'package:chit_chat/network/network_api_service.dart';
import 'package:chit_chat/utils/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatLoading());

  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  FirebaseRepository firebaseRepository = FirebaseRepository();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  NetworkApiService apiService = NetworkApiService();
  List<MessageModel> messageList = [];
  Util util = Util();
  String chatRoomID = '';
  String receiverID = '';

  Future onInit(String receiverID) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString('receiverId', receiverID);
    this.receiverID = receiverID;
    final String senderID = firebaseAuth.currentUser!.uid;

    //create unique id for two user
    final List chatIds = [senderID, receiverID];
    chatIds.sort();
    chatRoomID = chatIds.join('');

    //get chat message from firebase

    chatStream = firebaseFirestore
        .collection('chatrooms')
        .doc(chatRoomID)
        .collection('message')
        .orderBy('timestamp')
        .snapshots()
        .listen((element) {
      messageList = [];
      for (var e in element.docs) {
        final MessageModel message = MessageModel.fromJson(e.data(), e.id);
        messageList.add(message);
      }
      emit(ChatReady(messageList: messageList));
      emit(ChatDataPopulated());

      for (var message in messageList) {
        if (message.receiverID == firebaseAuth.currentUser!.uid &&
            message.status == 'unread') {
          updateChatStatus(message);
        }
      }
    });
  }

  updateChatStatus(MessageModel message) {
    DocumentReference messageRef = firebaseFirestore
        .collection('chatrooms')
        .doc(chatRoomID)
        .collection('message')
        .doc(message.id);

    messageRef.update({"status": "read", "batch": 0});
    message.status = 'read';
    emit(ChatReady(messageList: messageList));
  }

  Future sendMessage(String message, UserData receiver, String msgType) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setBool('oldUser', true);

    if (message.isEmpty) {
      emit(EmptyMessage());
      throw false;
    }

    final String senderID = firebaseAuth.currentUser!.uid;

    //creates unique id for two user
    final List<String> chatIds = [senderID, receiver.uid!];
    chatIds.sort();
    final String chatRoomID = chatIds.join('');

    //checking the no of unread message
    final int batchCount = messageList
        .where((e) {
          if (e.status != null) {
            return e.status == 'unread' &&
                e.receiverID != firebaseAuth.currentUser!.uid;
          } else {
            return false;
          }
        })
        .toList()
        .length;

    //new message to send
    final MessageModel newMessage = MessageModel(
      message: message,
      receiverID: receiver.uid,
      senderEmail: firebaseAuth.currentUser!.email!,
      senderID: senderID,
      batch: batchCount + 1,
      status: 'unread',
      timestamp: Timestamp.now(),
      messageType: msgType,
    );

    //posting to firebase
    firebaseRepository.sendMessage(chatRoomID, newMessage, chatIds);

    apiService.sendMessage(receiver, newMessage);
  }

  late StreamSubscription chatStream;

  Future stopStream() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString('receiverId', '');
    chatStream.cancel();
  }

  Future openGallery() async {
    util.captureImage(ImageSource.gallery).then((value) {
      if (value != null) {
        emit(UploadFile(value.path, fileStatus: FileStatus.preview));
      }
    });
  }

  openVideoGallery() {
    util.captureVideo().then((value) {
      if (value != null) {
        emit(UploadFile(value.path, fileStatus: FileStatus.preview));
      }
    });
  }

  Future uploadFileToFirebase(String filepath) async {
    emit(UploadFile(filepath, fileStatus: FileStatus.uploading));
    firebaseRepository.uploadFile(XFile(filepath), 'chat_media').then((value) {
      emit(FileUploaded(fileUrl: value));
    });
  }
}
