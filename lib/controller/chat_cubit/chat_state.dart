part of 'chat_cubit.dart';

@immutable
sealed class ChatState {}

sealed class ChatActionState extends ChatState {}

final class EmptyMessage extends ChatActionState {}

final class OpenUploadFileDialog extends ChatActionState {}

final class UploadFile extends ChatActionState {
  final MediaType mediaType;
  final List<String> fileData;
  final FileStatus fileStatus;

  UploadFile(
      {required this.fileData,
      required this.fileStatus,
      required this.mediaType});
}

final class FileUploaded extends ChatActionState {}

final class ChatReadyActionState extends ChatActionState {
  final int chatlength;

  ChatReadyActionState({required this.chatlength});
}

final class ChatReady extends ChatState {
  final bool? loadingList;
  final bool? loadingOldchat;
  final List<MessageModel> messageList;

  ChatReady({required this.messageList, this.loadingList, this.loadingOldchat});
}

final class ChatListEmpty extends ChatState {}

final class ChatError extends ChatState {}

enum FileStatus {
  uploading,
  preview,
}
