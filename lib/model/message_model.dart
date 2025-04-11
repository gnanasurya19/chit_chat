import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
part 'message_model.g.dart';

@HiveType(typeId: 0)
class MessageModel {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? senderID;

  @HiveField(2)
  String? receiverID;

  @HiveField(3)
  String? senderEmail;

  @HiveField(4)
  String? message;

  @HiveField(5)
  int? batch;

  @HiveField(6)
  String? status;

  Timestamp? timestamp;

  @HiveField(7)
  DateTime? timestampAsDateTime;

  @HiveField(8)
  String? date;

  @HiveField(9)
  String? time;

  @HiveField(10)
  String? messageType;

  @HiveField(11)
  String? thumbnail;

  @HiveField(12)
  String? audioUrl;

  @HiveField(13)
  List<double>? audioFormData;

  @HiveField(14)
  bool? isAudioDownloaded;

  @HiveField(15)
  bool? isAudioDownloading;

  @HiveField(16)
  bool? isAudioUploading;

  @HiveField(17)
  String? audioDuration = '0.00';

  @HiveField(18)
  String? audioCurrentDuration = '0.00';

  @HiveField(19)
  double? imageHeight;

  @HiveField(20)
  double? imageWidth;

  @HiveField(21)
  bool? isSelected;

  @HiveField(22)
  String? fileName;

  @HiveField(23)
  String? thumbnailName;

  @HiveField(24)
  String? deletedBy;

  @HiveField(25)
  String? mediaStatus;

  @HiveField(26)
  String? mediaID;
  MessageModel(
      {this.senderID,
      this.receiverID,
      this.senderEmail,
      this.message,
      this.timestamp,
      this.status,
      this.batch,
      this.time,
      this.date,
      this.messageType,
      this.id,
      this.thumbnail,
      this.audioUrl,
      this.audioFormData,
      this.audioDuration,
      this.audioCurrentDuration,
      this.isAudioUploading,
      this.isAudioDownloading,
      this.isAudioDownloaded,
      this.imageHeight,
      this.imageWidth,
      this.isSelected,
      this.fileName,
      this.thumbnailName,
      this.mediaID,
      this.timestampAsDateTime});

  @override
  String toString() {
    return '''MessageModel{id: $id,
     senderID: $senderID,
     receiverID: $receiverID,
     senderEmail: $senderEmail,
     message: $message,
     batch: $batch,
     status: $status,
     timestamp: $timestamp,
     date: $date,
     time: $time,
     messageType: $messageType,
     thumbnail: $thumbnail,
     audioUrl: $audioUrl,
     audioFormData: $audioFormData,
     isAudioDownloaded: $isAudioDownloaded,
     isAudioDownloading: $isAudioDownloading,
     isAudioUploading: $isAudioUploading,
     audioDuration: $audioDuration,
     audioCurrentDuration: $audioCurrentDuration,
     imageHeight: $imageHeight,
     imageWidth: $imageWidth,
     isSelected: $isSelected,
     fileName: $fileName,
     thumbnailName: $thumbnailName,
     deletedBy: $deletedBy,
     mediaStatus: $mediaStatus,
     mediaID: $mediaID}''';
  }

  MessageModel.fromJson(Map<String, dynamic> json, docID) {
    id = docID;
    senderID = json['senderID'];
    receiverID = json['receiverID'];
    senderEmail = json['senderEmail'];
    message = json['message'];
    messageType = json['messageType'];
    thumbnail = json['thumbnail'];
    if (json['status'] != null) {
      status = json['status'];
    } else {
      status = 'read';
    }
    if (json["batch"] != null) {
      batch = json['batch'];
    } else {
      batch = 0;
    }
    timestamp = json['timestamp'];
    getDateTime();
    audioUrl = json['audiourl'];
    if (json['audioFormData'] != null) {
      audioFormData = List.from(json['audioFormData']);
    }
    audioDuration = json['audioDuration'];
    imageHeight = json['imageHeight'];
    imageWidth = json['imageWidth'];
    fileName = json['fileName'];
    thumbnailName = json['thumbnailName'];
    deletedBy = json['deletedBy'];
  }

  void getDateTime() {
    DateTime jsonDate = timestamp!.toDate();
    DateTime today = DateTime.now();
    if (jsonDate.day == today.day &&
        jsonDate.month == today.month &&
        jsonDate.year == today.year) {
      date = 'Today';
      time = DateFormat('hh:mm a').format(jsonDate);
    } else if (jsonDate.day == today.day - 1 &&
        jsonDate.month == today.month &&
        jsonDate.year == today.year) {
      date = 'Yesterday';
      time = 'Yesterday';
    } else if (jsonDate.month == today.month &&
        jsonDate.year == today.year &&
        (today.day - jsonDate.day) < 7) {
      time = DateFormat('dd/MM/yyyy').format(jsonDate);
      date = DateFormat('EEEE').format(jsonDate);
    } else {
      time = DateFormat('dd/MM/yyyy').format(jsonDate);
      date = DateFormat('MMM dd, yyyy').format(jsonDate);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['senderID'] = senderID;
    data['receiverID'] = receiverID;
    data['senderEmail'] = senderEmail;
    data['message'] = message;
    data['timestamp'] = timestamp;
    data['status'] = status;
    data['batch'] = batch;
    data['messageType'] = messageType;
    data['thumbnail'] = thumbnail;
    data['audiourl'] = audioUrl;
    data['audioFormData'] = audioFormData;
    data['audioDuration'] = audioDuration;
    data['imageHeight'] = imageHeight;
    data['imageWidth'] = imageWidth;
    data['fileName'] = fileName;
    data['thumbnailName'] = thumbnailName;
    data['deletedBy'] = deletedBy ?? '';
    return data;
  }
}
