import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  String? userName;
  String? userEmail;
  String? uid;
  int? batch;
  Timestamp? timestamp;
  String? time;
  String? lastMessage;
  String? fCM;
  String? profileURL;

  UserData(
      {this.userName,
      this.userEmail,
      this.uid,
      this.batch,
      this.lastMessage,
      this.time,
      this.timestamp,
      this.fCM,
      this.profileURL});

  UserData.fromJson(Map<String, dynamic> json) {
    userName = json['userName'];
    userEmail = json['userEmail'];
    uid = json['uid'];
    fCM = json['fcm'];
    profileURL = json['profileURL'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userName'] = userName;
    data['userEmail'] = userEmail;
    data['uid'] = uid;
    data['fcm'] = fCM;
    data['profileURL'] = profileURL;
    return data;
  }
}
