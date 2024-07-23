import 'package:chit_chat/model/message_model.dart';

class UserData {
  String? userName;
  String? userEmail;
  String? uid;
  MessageModel? lastMessage;
  String? fCM;
  String? profileURL;

  UserData(
      {this.userName,
      this.userEmail,
      this.uid,
      this.lastMessage,
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
