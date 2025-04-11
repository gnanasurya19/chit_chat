// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageModelAdapter extends TypeAdapter<MessageModel> {
  @override
  final int typeId = 0;

  @override
  MessageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageModel(
      senderID: fields[1] as String?,
      receiverID: fields[2] as String?,
      senderEmail: fields[3] as String?,
      message: fields[4] as String?,
      status: fields[6] as String?,
      batch: fields[5] as int?,
      time: fields[9] as String?,
      date: fields[8] as String?,
      messageType: fields[10] as String?,
      id: fields[0] as String?,
      thumbnail: fields[11] as String?,
      audioUrl: fields[12] as String?,
      audioFormData: (fields[13] as List?)?.cast<double>(),
      audioDuration: fields[17] as String?,
      audioCurrentDuration: fields[18] as String?,
      isAudioUploading: fields[16] as bool?,
      isAudioDownloading: fields[15] as bool?,
      isAudioDownloaded: fields[14] as bool?,
      imageHeight: fields[19] as double?,
      imageWidth: fields[20] as double?,
      isSelected: fields[21] as bool?,
      fileName: fields[22] as String?,
      thumbnailName: fields[23] as String?,
      mediaID: fields[26] as String?,
      timestampAsDateTime: fields[7] as DateTime?,
    )
      ..deletedBy = fields[24] as String?
      ..mediaStatus = fields[25] as String?;
  }

  @override
  void write(BinaryWriter writer, MessageModel obj) {
    writer
      ..writeByte(27)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.senderID)
      ..writeByte(2)
      ..write(obj.receiverID)
      ..writeByte(3)
      ..write(obj.senderEmail)
      ..writeByte(4)
      ..write(obj.message)
      ..writeByte(5)
      ..write(obj.batch)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.timestampAsDateTime)
      ..writeByte(8)
      ..write(obj.date)
      ..writeByte(9)
      ..write(obj.time)
      ..writeByte(10)
      ..write(obj.messageType)
      ..writeByte(11)
      ..write(obj.thumbnail)
      ..writeByte(12)
      ..write(obj.audioUrl)
      ..writeByte(13)
      ..write(obj.audioFormData)
      ..writeByte(14)
      ..write(obj.isAudioDownloaded)
      ..writeByte(15)
      ..write(obj.isAudioDownloading)
      ..writeByte(16)
      ..write(obj.isAudioUploading)
      ..writeByte(17)
      ..write(obj.audioDuration)
      ..writeByte(18)
      ..write(obj.audioCurrentDuration)
      ..writeByte(19)
      ..write(obj.imageHeight)
      ..writeByte(20)
      ..write(obj.imageWidth)
      ..writeByte(21)
      ..write(obj.isSelected)
      ..writeByte(22)
      ..write(obj.fileName)
      ..writeByte(23)
      ..write(obj.thumbnailName)
      ..writeByte(24)
      ..write(obj.deletedBy)
      ..writeByte(25)
      ..write(obj.mediaStatus)
      ..writeByte(26)
      ..write(obj.mediaID);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
