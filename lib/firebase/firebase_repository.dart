import 'dart:io';
import 'package:chit_chat/model/message_model.dart';
import 'package:chit_chat/utils/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class FirebaseRepository {
  final Util util = Util();
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  Future sendMessage(
      String chatRoomID, MessageModel newMessage, List<String> chatIds) async {
    try {
      firebaseFirestore
          .collection('chatrooms')
          .doc(chatRoomID)
          .collection('message')
          .add(newMessage.toJson());

      DocumentReference documentRef =
          firebaseFirestore.collection('chatrooms').doc(chatRoomID);

      documentRef.set({"roomid": chatIds});
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<String> uploadFile(XFile file, String path) async {
    final ref = firebaseStorage.ref('users/$path').child(file.name);
    await ref.putFile(File(file.path));
    final url = await ref.getDownloadURL();
    return url;
  }

  Future updateUser(String userId, Map<String, String> json) async {
    final res = await firebaseFirestore
        .collection('users')
        .where('uid', isEqualTo: userId)
        .get()
        .then((value) => value.docs[0].id);
    await firebaseFirestore.collection('users').doc(res).update(json);
  }
}
