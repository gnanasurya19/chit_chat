import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'package:chit_chat/controller/media_cubit/media_cubit.dart';
import 'package:chit_chat/model/message_model.dart';
import 'package:chit_chat/model/user_data.dart';
import 'package:chit_chat/res/common_instants.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatError());

  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  List<MessageModel> messageList = [];
  String chatRoomID = '';
  String receiverID = '';
  DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  StreamSubscription? chatStream;
  String? thumbnailUrl;
  late UserData user;

  Future onInit(String receiverID, UserData user) async {
    // To display notification properly
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString('receiverId', receiverID);

    this.receiverID = receiverID;
    this.user = user;

    final String senderID = currentUserId;

    //create unique id for two user
    final List chatIds = [senderID, receiverID];
    chatIds.sort();
    chatRoomID = chatIds.join('');

    await removeReadMsgFromNotification(chatRoomID);

    //get chat message from firebase

    var query = firebaseFirestore
        .collection('chatrooms')
        .doc(chatRoomID)
        .collection('message')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .get();

    await query.then((element) async {
      // print(element.docs.map((ele) => ele.data()['message']));
      populateList(element.docs.reversed.toList());
      emit(ChatReadyActionState(chatlength: element.docs.length));
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
      populateList(element.docs.toList());
    });
  }

  Future changeBadgeCount(String? status, int? batchCount) async {
    if (status == 'unread' && batchCount != null) {
      SharedPreferences sp = await SharedPreferences.getInstance();
      int? count = sp.getInt('badgeCount');
      count = (count ?? batchCount) - batchCount;
      sp.setInt('badgeCount', count);
      if (count == 0) {
        // FlutterAppBadger.removeBadge();
        // FlutterAppIconBadge.removeBadge();
        // FlutterAppBadgeControl.removeBadge();
      } else {
        // FlutterAppBadger.updateBadgeCount(count);
        // FlutterAppBadgeControl.updateBadgeCount(count);
      }
    }
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

  justEmit() {
    messageList.add(messageList.last);
    emit(ChatReady(messageList: messageList));
  }

  void populateList(List<QueryDocumentSnapshot<Map<String, dynamic>>> element) {
    if (element.isEmpty) {
      emit(ChatListEmpty());
    } else {
      lastDocument = element.first;

      messageList = [];
      messageList =
          element.map((e) => MessageModel.fromJson(e.data(), e.id)).toList();

      audioPlayerInitialilze();
      emit(ChatReady(messageList: messageList));

      final filteredList = messageList.where((message) =>
          message.receiverID == firebaseAuth.currentUser!.uid &&
          (message.status == 'unread' || message.status == 'delivered'));

      for (var message in filteredList) {
        updateChatStatus(message);
      }
    }
  }

  audioPlayerInitialilze() async {
    await Future.forEach(messageList, (element) async {
      if (element.messageType == 'audio' && element.isAudioDownloaded != true) {
        await util.checkCache(element.audioUrl!).then((value) async {
          if (value != null) {
            element.isAudioDownloaded = true;
            element.audioUrl = value;
          }
        });
      }
    });
    emit(ChatReady(messageList: messageList));
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

    // messageList = newList.toList();
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

  Future sendMessage(String message, UserData receiver, String msgType,
      {String? audioPath, List<double>? audiowave}) async {
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
        audioUrl: audioPath,
        audioFormData: audiowave,
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
          networkApiService.sendMessage(
              receiver, newMessage, msgId, chatRoomID);
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
    // remove
  }

  List<String> mediaList = [];

  Future openGallery() async {
    util.captureMultiImage().then((value) async {
      if (value != null) {
        mediaList = value.map((e) => e.path).toList();
        emit(OpenUploadFileDialog());
      }
    });
  }

  emitfileUploadState() {
    emit(UploadFile(
        mediaType: MediaType.image,
        filePath: mediaList,
        fileStatus: FileStatus.preview));
  }

  Future openVideoGallery() async {
    util.captureVideo().then((value) async {
      if (value != null) {
        mediaList = [value.path];
        emit(OpenUploadFileDialog());
        await Future.delayed(Duration(milliseconds: 400));
        emit(UploadFile(
            mediaType: MediaType.video,
            filePath: mediaList,
            fileStatus: FileStatus.preview));
      }
    });
  }

  void deleteSelectedMedia(int index, MediaType mediaType) {
    mediaList.removeAt(index);
    emit(UploadFile(
        mediaType: mediaType,
        filePath: mediaList,
        fileStatus: FileStatus.preview));
  }

  // recording
  final record = AudioRecorder();
  Future<bool> checkMicPermission() async {
    final hasPermission = await record.hasPermission();
    return hasPermission;
  }

  cancelRecording() {
    record.cancel();
  }

  Future<void> startRecording() async {
    final directory = await getApplicationDocumentsDirectory();
    await record.cancel();

    final String audioPath =
        "${DateFormat('yyyyMMddHHmmsS').format(DateTime.now())}_CC_audioFile";

    record.start(
        RecordConfig(
            bitRate: 28000,
            sampleRate: 44100,
            noiseSuppress: true,
            encoder: AudioEncoder.wav,
            androidConfig:
                AndroidRecordConfig(audioSource: AndroidAudioSource.mic)),
        path: p.join(directory.path, '$audioPath.wav'));
  }

  stopRecording() async {
    final recordedAudioPath = await record.stop();
    if (recordedAudioPath != null) {
      final audioUrl = await firebaseRepository.uploadFile(
          XFile(recordedAudioPath), 'chat_media', 'audio/wav');

      final audioPathName =
          recordedAudioPath.split(Platform.pathSeparator).last;
      final controller = PlayerController();
      final data = await controller.extractWaveformData(
          path: recordedAudioPath, noOfSamples: 60);
      sendMessage(audioUrl, user, 'audio',
          audioPath: audioPathName, audiowave: data);
    }
  }

  PlayerController? playingController;
  String? activeAudioId;
  final Map<String, PlayerController> audioPlayers = {};
  final Map<String, bool> isPrepared = {};

  PlayerController getPlayerController(String audioID) {
    if (!audioPlayers.containsKey(audioID)) {
      audioPlayers[audioID] = PlayerController();
    }
    return audioPlayers[audioID]!;
  }

  playAudioPlayer(String audioID, String audioPath) async {
    if (activeAudioId != null && activeAudioId != audioID) {
      _stopActiveAudio();
    }

    final controller = getPlayerController(audioID);

    if (!isPrepared.containsKey(audioID)) {
      await controller.preparePlayer(path: audioPath);
      controller.setFinishMode(finishMode: FinishMode.pause);
      controller.onPlayerStateChanged.listen(
        (event) {
          if (event.isPaused) {
            activeAudioId = null;
            emit(ChatReady(messageList: messageList));
          }
        },
      );
      isPrepared[audioID] = true;
    }
    await controller.startPlayer();
    activeAudioId = audioID;
    emit(ChatReady(messageList: messageList));
  }

  void pauseAudio() {
    if (activeAudioId != null) {
      final controller = getPlayerController(activeAudioId!);
      controller.pausePlayer();
      activeAudioId = null;
      emit(ChatReady(messageList: messageList));
    }
  }

  void _stopActiveAudio() async {
    if (activeAudioId != null) {
      final controller = getPlayerController(activeAudioId!);
      await controller.pausePlayer();
      activeAudioId = null;
      emit(ChatReady(messageList: messageList));
    }
  }

  downloadAudio(String chatId) async {
    final messageIndex =
        messageList.indexWhere((element) => element.id == chatId);
    final audioMessage = messageList[messageIndex];
    audioMessage.isDownloading = true;
    emit(ChatReady(messageList: messageList));
    final localPath = await networkApiService.downloadAudio(
        audioMessage.message!, audioMessage.audioUrl!);
    audioMessage.audioUrl = localPath;
    audioMessage.isDownloading = false;
    messageList[messageIndex].isAudioDownloaded = true;
    emit(ChatReady(messageList: messageList));
  }
}
