import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:chit_chat/model/media_data_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
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
  List<MessageModel> pendingMessageList = [];
  String chatRoomID = '';
  String receiverID = '';
  DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  StreamSubscription? chatStream;
  String? thumbnailUrl;
  String? thumbnailName;
  String? thumbnailPath;
  late UserData user;

  List<MediaDataModel> mediaList = [];
  MediaType? mediaType;

  final record = AudioRecorder();

  String? activeAudioId;
  final Map<String, PlayerController> audioPlayers = {};
  final Map<String, bool> isPrepared = {};

  int selectedMsgCount = 0;
  bool get isMsgSelected => selectedMsgCount != 0;

  List<MessageModel>? selectedMsgs;

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
        .where('deletedBy', isNotEqualTo: senderID)
        .orderBy('deletedBy')
        .orderBy('timestamp')
        .limitToLast(20)
        .get();

    await query.then((element) async {
      sortMessageDocs(element);
      populateList(element.docs.toList());
    });

    listenNewmsg();
  }

  void sortMessageDocs(QuerySnapshot<Map<String, dynamic>> element) {
    element.docs.sort(
      (a, b) =>
          (b.data()['timestamp'] as Timestamp).compareTo(a.data()['timestamp']),
    );
  }

  listenNewmsg() {
    if (chatStream != null) {
      chatStream?.cancel();
    }
    final String senderID = currentUserId;

    Query<Map<String, dynamic>> query = firebaseFirestore
        .collection('chatrooms')
        .doc(chatRoomID)
        .collection('message')
        .where('deletedBy', isNotEqualTo: senderID)
        .orderBy('deletedBy')
        .orderBy('timestamp');

    if (lastDocument != null) {
      query = query.startAtDocument(lastDocument!);
    }

    chatStream = query.snapshots().listen((element) {
      pendingMessageList = hiveRepository.getSingleUserPendings(receiverID);
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
        .where('deletedBy', isNotEqualTo: currentUserId)
        .orderBy('deletedBy', descending: true)
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
    // listenNewmsg();
  }

  void populateList(List<QueryDocumentSnapshot<Map<String, dynamic>>> element) {
    if (element.isEmpty) {
      emit(ChatListEmpty());
    } else {
      lastDocument = element.first;

      messageList = element
          .map((e) => MessageModel.fromJson(e.data(), e.id))
          .toList()
          .reversed
          .toList();

      // messageList.addAll(pendingMessageList);

      // messageList.sort((a, b) => b.timestamp!.compareTo(a.timestamp!));

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
        await util.checkCacheAudio(element.audioUrl!).then((value) async {
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
      chatStream?.pause();
    }
  }

  resumeChatStream() async {
    listenNewmsg();
    if (lastDocument == null) return;
    final newSnapshots = await firebaseFirestore
        .collection('chatrooms')
        .doc(chatRoomID)
        .collection('message')
        .where('deletedBy', isNotEqualTo: currentUserId)
        .orderBy('deletedBy')
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

  Future uploadFileToFirebase() async {
    for (var media in mediaList) {
      media.fileName = media.filePath.split(Platform.pathSeparator).last;
      if (mediaType == MediaType.video) {
        thumbnailPath = await VideoThumbnail.thumbnailFile(
          video: media.filePath,
          imageFormat: ImageFormat.JPEG,
          quality: 100,
        );
        thumbnailName = thumbnailPath?.split(Platform.pathSeparator).last;
      }
    }
    util.checkNetwork().then((value) async {
      emit(
        UploadFile(
          mediaType: mediaType!,
          fileData: mediaList.map((e) => e.filePath).toList(),
          fileStatus: FileStatus.uploading,
        ),
      );
      await Future.forEach(mediaList, (media) async {
        final String url = await firebaseRepository.uploadFile(
            XFile(media.filePath), 'chat_media');
        media.fileUrl = url;
        if (mediaType == MediaType.video) {
          final thumbnailFile = XFile(thumbnailPath!);
          thumbnailUrl =
              await firebaseRepository.uploadFile(thumbnailFile, 'chat_media');
        }
      });
      emit(FileUploaded());
    }).catchError((err) {
      addToLocal();
    });
  }

  Future sendMessage(String message, UserData receiver, String msgType,
      {String? audioPath,
      List<double>? audiowave,
      String? audioDuration,
      Size? imageSize,
      String? fileName,
      String? thumbnailName}) async {
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
        audioDuration: audioDuration,
        imageHeight: imageSize?.height.toDouble(),
        imageWidth: imageSize?.width.toDouble(),
        fileName: fileName,
        thumbnailName: thumbnailName,
      );

      //posting to firebase
      final msgId =
          await firebaseRepository.sendMessage(chatRoomID, newMessage, chatIds);

      receiver.fCM = await getReceiverFCM();

      if (receiver.fCM != null && receiver.fCM != '' && msgId != '') {
        networkApiService
            .sendNotification(receiver, newMessage, msgId, chatRoomID)
            .catchError((e) {
          // Do nothing
        });
      }
    }
  }

  Future<String?> getReceiverFCM() async {
    var userCollection = firebaseFirestore.collection('users');
    final value =
        await userCollection.where('uid', isEqualTo: receiverID).limit(1).get();
    if (value.docs.isNotEmpty) {
      return value.docs.first.data()['fcm'];
    } else {
      return null;
    }
  }

  Future sendMediaMessages(UserData receiver) async {
    Future.forEach(mediaList, (media) async {
      await sendMessage(
        media.fileUrl!,
        receiver,
        mediaType == MediaType.image ? 'image' : 'video',
        imageSize:
            media.width != null ? Size(media.width!, media.height!) : null,
        fileName: media.fileName,
        thumbnailName: thumbnailName,
      );
    });
  }

  Future stopStream() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString('receiverId', '');
    messageList.clear();
    emit(ChatReady(messageList: const []));
    chatStream?.cancel();
    // remove
  }

  Future openGallery() async {
    util.captureMultiImage().then((value) async {
      if (value != null) {
        mediaList.clear();
        for (var ele in value) {
          final size = getMediaSize(ele.path);
          mediaList.add(MediaDataModel(
              filePath: ele.path,
              height: size.height,
              width: size.width,
              fileName: ele.name));
        }
        emit(OpenUploadFileDialog());
        mediaType = MediaType.image;
      }
    }).catchError((e) {});
  }

  addToLocal() {
    List<MessageModel> pendingMessages = [];
    for (var i = 0; i < mediaList.length; i++) {
      final media = mediaList[i];

      String mediaID =
          "${DateFormat('yyyyMMddHHmmssS').format(DateTime.now())}$i";

      final message = MessageModel(
        mediaID: mediaID,
        message: media.filePath,
        fileName: media.fileName,
        messageType: mediaType == MediaType.image ? 'image' : 'video',
        receiverID: receiverID,
        imageHeight: media.height!.toDouble(),
        imageWidth: media.width!.toDouble(),
        status: 'pending',
        senderID: currentUserId,
        timestampAsDateTime: Timestamp.now().toDate(),
        timestamp: Timestamp.now(),
        thumbnail: thumbnailPath,
        thumbnailName: thumbnailName,
      );

      message.getDateTime();

      print(message.toString());

      pendingMessages.add(message);
    }
    hiveRepository.addToPending(pendingMessages);
  }

  Size getMediaSize(String filepath) {
    final resultSize = ImageSizeGetter.getSizeResult(FileInput(File(filepath)));
    if (resultSize.size.needRotate) {
      final size = Size(resultSize.size.height, resultSize.size.width);
      return size;
    }
    return resultSize.size;
  }

  emitfileUploadState() {
    emit(UploadFile(
        mediaType: mediaType!,
        fileData: mediaList.map((e) => e.filePath).toList(),
        fileStatus: FileStatus.preview));
  }

  Future openVideoGallery() async {
    util.captureVideo().then((value) async {
      if (value != null) {
        mediaList.clear();
        final size = getMediaSize(value.path);
        mediaList.add(
          MediaDataModel(
            filePath: value.path,
            fileName: value.path.split(Platform.pathSeparator).last,
            height: size.height,
            width: size.width,
          ),
        );
        emit(OpenUploadFileDialog());
        mediaType = MediaType.video;
      }
    });
  }

  void deleteSelectedMedia(int index, MediaType mediaType) {
    mediaList.removeAt(index);
    emit(UploadFile(
        mediaType: mediaType,
        fileData: mediaList.map((e) => e.filePath).toList(),
        fileStatus: FileStatus.preview));
  }

  // recording
  checkMicPermission() async {
    final hasPermission = await record.hasPermission();

    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setBool('hasaudioPermission', hasPermission);
  }

  cancelRecording() {
    record.cancel();
  }

  Future<void> startRecording() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    bool audioPermission = sp.getBool('hasaudioPermission') ?? false;
    if (!audioPermission) {
      await checkMicPermission();
      throw 'mic permission required';
    }

    final directory = await getApplicationDocumentsDirectory();

    final String audioPath =
        "${DateFormat('yyyyMMddHHmmssS').format(DateTime.now())}_CC_audioFile";

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

  completeRecording() async {
    final recordedAudioPath = await record.stop();

    if (recordedAudioPath != null) {
      final controller = PlayerController();
      await controller.preparePlayer(path: recordedAudioPath);

      final audioDurationInt = await controller.getDuration();
      final audioDuration = getTime(audioDurationInt);

      final audiowavedata = await controller.extractWaveformData(
          path: recordedAudioPath, noOfSamples: 60);

      final lastAudioMessage = MessageModel(
        audioFormData: audiowavedata,
        audioUrl: recordedAudioPath,
        audioDuration: audioDuration,
        date: 'Today',
        timestamp: Timestamp.now(),
        status: 'unread',
        messageType: 'audio',
        isAudioUploading: true,
        isAudioDownloaded: true,
        audioCurrentDuration: "0:00",
      );

      messageList.insert(0, lastAudioMessage);

      emit(ChatReady(messageList: messageList));

      final audioPathName =
          recordedAudioPath.split(Platform.pathSeparator).last;

      final audioUrl = await firebaseRepository.uploadFile(
          XFile(recordedAudioPath), 'chat_media', 'audio/wav');

      sendMessage(audioUrl, user, 'audio',
          audioPath: audioPathName,
          audiowave: audiowavedata,
          audioDuration: audioDuration);
    }
  }

  PlayerController getPlayerController(String audioID) {
    if (!audioPlayers.containsKey(audioID)) {
      audioPlayers[audioID] = PlayerController();
    }
    return audioPlayers[audioID]!;
  }

  String getTime(int value) {
    return '${value ~/ 1000 ~/ 60}:${(value ~/ 1000).toString().padLeft(2, '0')}';
  }

  changeAudioDuration(MessageModel message, int currentDuration) {
    message.audioCurrentDuration = getTime(currentDuration);
    emit(ChatReady(messageList: messageList));
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
    audioMessage.isAudioDownloading = true;
    emit(ChatReady(messageList: messageList));
    final localPath = await networkApiService.downloadAudio(
        audioMessage.message!, audioMessage.audioUrl!);
    audioMessage.audioUrl = localPath;
    audioMessage.isAudioDownloading = false;
    messageList[messageIndex].isAudioDownloaded = true;
    emit(ChatReady(messageList: messageList));
  }

  selectMessages(MessageModel message) {
    if (message.isSelected == true) {
      message.isSelected = false;
      selectedMsgCount--;
    } else {
      message.isSelected = true;
      selectedMsgCount++;
    }

    if (selectedMsgCount == 0) {
      emit(ChatMessgesDeselectedState());
    } else {
      emit(ChatMessageSelectedState(
          isMessageSelected: isMsgSelected,
          selectedMsgCount: selectedMsgCount));
    }

    emit(ChatReady(messageList: messageList, isMsgsSelected: isMsgSelected));
  }

  deSelectAllMsg() {
    for (var element in messageList) {
      element.isSelected = false;
    }
    selectedMsgCount = 0;
    emit(ChatReady(messageList: messageList, isMsgsSelected: isMsgSelected));
    emit(ChatMessgesDeselectedState());
  }

  showDeleteAlert() {
    final currentUserID = firebaseAuth.currentUser?.uid;

    selectedMsgs = messageList.where((e) => e.isSelected == true).toList();

    final isDeleteForAll = selectedMsgs?.every((element) {
      return element.senderID == currentUserID;
    });

    emit(ChatDeleteDialogState(
        msgCount: selectedMsgs?.length ?? 0,
        deleteForAll: () {
          deleteMsgs();
        },
        deleteOnlyForMe: () {
          markAsDelete();
        },
        isDeleteForAll: isDeleteForAll ?? false));
  }

  deleteMsgs() async {
    Future.forEach(selectedMsgs ?? <MessageModel>[], (ele) async {
      await firebaseRepository.deleteMessage(chatRoomID, ele.id!);
      if (ele.messageType == 'image' || ele.messageType == 'video') {
        await deleteMedia(ele.message!, ele.fileName);
        if (ele.thumbnail != null) {
          await deleteMedia(ele.thumbnail!, ele.thumbnailName);
        }
      }
      if (ele.messageType == 'audio' &&
          ele.isAudioDownloaded == true &&
          ele.audioUrl != null) {
        await deleteAudio(ele.audioUrl!, ele.audioUrl);
      }
    });
    selectedMsgCount = 0;
    emit(ChatMessgesDeselectedState());
  }

  markAsDelete() async {
    final currentUserID = firebaseAuth.currentUser?.uid;
    for (var msg in selectedMsgs ?? <MessageModel>[]) {
      DocumentReference messageRef = firebaseFirestore
          .collection('chatrooms')
          .doc(chatRoomID)
          .collection('message')
          .doc(msg.id);
      await messageRef.update({"deletedBy": currentUserID});
      msg.deletedBy = currentUserID;
    }
    selectedMsgCount = 0;
    emit(ChatMessgesDeselectedState());
  }

  deleteMedia(String url, String? filename) async {
    if (filename != null) {
      firebaseRepository.deleteMedia(filename);
    }
    final cachedFile = await DefaultCacheManager().getFileFromMemory(url);
    if (cachedFile != null) {
      await cachedFile.file.delete();
    }
  }

  deleteAudio(String url, filename) async {
    if (filename != null) {
      firebaseRepository.deleteMedia(filename);
    }
    final audioPath = await util.checkCacheAudio(url);
    if (audioPath != null) {
      await File(audioPath).delete();
    }
  }
}
