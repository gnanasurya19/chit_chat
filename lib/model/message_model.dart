import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MessageModel {
  String? id;
  String? senderID;
  String? receiverID;
  String? senderEmail;
  String? message;
  int? batch;
  String? status;
  Timestamp? timestamp;
  String? date;
  String? time;
  String? messageType;
  String? thumbnail;
  String? audioUrl;
  List<double>? audioFormData;
  bool? isAudioDownloaded;
  bool? isAudioDownloading;
  bool? isAudioUploading;
  String? audioDuration = '0.00';
  String? audioCurrentDuration = '0.00';
  double? imageHeight;
  double? imageWidth;
  bool? isSelected;
  String? fileName;
  String? thumbnailName;
  String? deletedBy;
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
      this.thumbnailName});

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
