import 'package:chit_chat_1/model/message_model.dart';

class UserData {
  String? userName;
  String? userEmail;
  String? uid;
  MessageModel? lastMessage;
  String? fCM;
  String? profileURL;

  String? password;

  String? phoneNumber;

  UserData(
      {this.userName,
      this.userEmail,
      this.uid,
      this.lastMessage,
      this.fCM,
      this.profileURL,
      this.password,
      this.phoneNumber});

  UserData.fromJson(Map<String, dynamic> json) {
    userName = json['userName'];
    userEmail = json['userEmail'];
    uid = json['uid'];
    fCM = json['fcm'];
    profileURL = json['profileURL'];
    phoneNumber = json['mobileNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userName'] = userName;
    data['userEmail'] = userEmail;
    data['uid'] = uid;
    data['fcm'] = fCM;
    data['profileURL'] = profileURL;
    data['mobileNumber'] = phoneNumber;
    return data;
  }
}
