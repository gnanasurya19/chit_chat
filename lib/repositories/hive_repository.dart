import 'package:chit_chat/model/message_model.dart';
import 'package:chit_chat/res/common_instants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HiveRepository {
  addToPending(List<MessageModel> messages) {
    for (var message in messages) {
      hivebox.put(message.mediaID, message);
    }
  }

  List<MessageModel> getSingleUserPendings(String receicerID) {
    final response = hivebox.values.where((ele) {
      return ele.receiverID == receicerID;
    }).map((ele) {
      ele.timestamp = Timestamp.fromDate(ele.timestampAsDateTime!);
      return ele;
    });

    return response.toList();
  }

  List<MessageModel> getAllPendings() {
    return hivebox.values.map((ele) {
      ele.timestamp = Timestamp.fromDate(ele.timestampAsDateTime!);
      return ele;
    }).toList();
  }
}
