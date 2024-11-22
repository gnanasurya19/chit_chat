import 'dart:async';

import 'package:chit_chat/network/network_api_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'package:chit_chat/controller/media_cubit/media_cubit.dart';
import 'package:chit_chat/firebase/firebase_repository.dart';
import 'package:chit_chat/model/message_model.dart';
import 'package:chit_chat/model/user_data.dart';
import 'package:chit_chat/res/common_instants.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatError());

  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  FirebaseRepository firebaseRepository = FirebaseRepository();
  // FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  NetworkApiService apiService = NetworkApiService();
  List<MessageModel> messageList = [];
  String chatRoomID = '';
  String receiverID = '';
  DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  StreamSubscription? chatStream;
  String? thumbnailUrl;

  Future onInit(String receiverID) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString('receiverId', receiverID);
    this.receiverID = receiverID;
    final String senderID = currentUserId;

    //create unique id for two user
    final List chatIds = [senderID, receiverID];
    chatIds.sort();
    chatRoomID = chatIds.join('');

    //get chat message from firebase

    await firebaseFirestore
        .collection('chatrooms')
        .doc(chatRoomID)
        .collection('message')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .get()
        .then((element) {
      populateList(element.docs);
    });
    listenNewmsg();
  }

  listenNewmsg() {
    if (chatStream != null) {
      chatStream!.cancel();
    }
    Query<Map<String, dynamic>> query = firebaseFirestore
        .collection('chatrooms')
        .doc(chatRoomID)
        .collection('message')
        .orderBy('timestamp');

    if (lastDocument != null) {
      query = query.startAtDocument(lastDocument!);
    }

    chatStream = query.snapshots().listen((element) {
      populateList(element.docs.reversed.toList());
    });
  }

  Future loadMore() async {
    if (lastDocument == null) return;
    emit(ChatReady(messageList: messageList, loadingOldchat: true));
    await firebaseFirestore
        .collection('chatrooms')
        .doc(chatRoomID)
        .collection('message')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .startAfterDocument(lastDocument!)
        .get()
        .then((element) {
      if (element.docs.isEmpty) {
        emit(ChatReady(messageList: messageList, loadingOldchat: false));
        return;
      }

      lastDocument = element.docs.last;

      for (var e in element.docs) {
        final MessageModel message = MessageModel.fromJson(e.data(), e.id);
        messageList.add(message);
      }
      emit(ChatReady(messageList: messageList, loadingOldchat: false));
    });
    listenNewmsg();
  }

  void populateList(List<QueryDocumentSnapshot<Map<String, dynamic>>> element) {
    if (element.isEmpty) {
      emit(ChatListEmpty());
    } else {
      lastDocument = element.last;
      messageList = [];
      for (var e in element) {
        final MessageModel message = MessageModel.fromJson(e.data(), e.id);
        messageList.add(message);
      }
      emit(ChatReady(messageList: messageList));
      for (var message in messageList) {
        if (message.receiverID == firebaseAuth.currentUser!.uid &&
            (message.status == 'unread' || message.status == 'delivered')) {
          updateChatStatus(message);
        }
      }
    }
  }

  Future updateChatStatus(MessageModel message) async {
    DocumentReference messageRef = firebaseFirestore
        .collection('chatrooms')
        .doc(chatRoomID)
        .collection('message')
        .doc(message.id);

    await messageRef.update({"status": "read", "batch": 0});
    message.status = 'read';
    emit(ChatReady(messageList: messageList));
  }

  pauseChatStream() {
    if (chatStream != null) {
      chatStream!.pause();
    }
  }

  resumeChatStream() async {
    listenNewmsg();
    if (lastDocument == null) return;
    final newSnapshots = await firebaseFirestore
        .collection('chatrooms')
        .doc(chatRoomID)
        .collection('message')
        .orderBy('timestamp')
        .startAtDocument(lastDocument!)
        .get();
    final List<MessageModel> newList = [];
    for (var e in newSnapshots.docs) {
      final MessageModel message = MessageModel.fromJson(e.data(), e.id);
      newList.add(message);
    }

    messageList = newList.reversed.toList();
    emit(ChatReady(messageList: messageList));

    for (var message in messageList) {
      if (message.receiverID == firebaseAuth.currentUser!.uid &&
          (message.status == 'unread' || message.status == 'delivered')) {
        updateChatStatus(message);
      }
    }
  }

  Future uploadFileToFirebase(
      List<String> filepaths, MediaType mediatype) async {
    emit(
      UploadFile(
        mediaType: mediatype,
        filePath: filepaths,
        fileStatus: FileStatus.uploading,
      ),
    );
    List<String> fileUrls = [];
    await Future.forEach(filepaths, (path) async {
      final String url =
          await firebaseRepository.uploadFile(XFile(path), 'chat_media');
      fileUrls.add(url);
      if (mediatype == MediaType.video) {
        String? thumbnailPath = await VideoThumbnail.thumbnailFile(
          video: path,
          imageFormat: ImageFormat.JPEG,
          quality: 100,
        );
        thumbnailUrl = await firebaseRepository.uploadFile(
            XFile(thumbnailPath!), 'chat_media');
      }
    });
    emit(FileUploaded(fileUrl: fileUrls, mediaType: mediatype));
  }

  Future sendMessage(String message, UserData receiver, String msgType) async {
    if (message.isNotEmpty) {
      final String senderID = firebaseAuth.currentUser!.uid;

      //creates unique id for two user
      final List<String> chatIds = [senderID, receiver.uid!];
      chatIds.sort();
      final String chatRoomID = chatIds.join('');

      //checking the no of unread message
      final int batchCount = messageList
          .where((e) {
            if (e.status != null) {
              return (e.status == 'unread' || e.status == 'delivered') &&
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
        thumbnail: thumbnailUrl,
      );

      //posting to firebase
      firebaseRepository
          .sendMessage(chatRoomID, newMessage, chatIds)
          .then((msgId) async {
        // accessing receiver fcm;
        await firebaseFirestore
            .collection('users')
            .where('uid', isEqualTo: receiverID)
            .limit(1)
            .get()
            .then((value) {
          if (value.docs.isNotEmpty) {
            receiver.fCM = value.docs.first.data()['fcm'];
          }
        });

        if (receiver.fCM != null && receiver.fCM != '' && msgId != '') {
          apiService.sendMessage(receiver, newMessage, msgId, chatRoomID);
        }
      });
    }
  }

  Future sendMultipleMessage(
      List<String> messages, UserData receiver, String msgType) async {
    Future.forEach(messages, (message) async {
      await sendMessage(message, receiver, msgType);
    });
  }

  Future stopStream() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString('receiverId', '');
    messageList.clear();
    emit(ChatReady(messageList: const []));
    chatStream!.cancel();
  }

  Future openGallery() async {
    util.captureMultiImage().then((value) {
      if (value != null) {
        emit(UploadFile(
            mediaType: MediaType.image,
            filePath: value.map((e) => e.path).toList(),
            fileStatus: FileStatus.preview));
      }
    });
  }

  Future openVideoGallery() async {
    util.captureVideo().then((value) {
      if (value != null) {
        emit(UploadFile(
            mediaType: MediaType.video,
            filePath: [value.path],
            fileStatus: FileStatus.preview));
      }
    });
  }
}
