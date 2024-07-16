part of 'chat_cubit.dart';

@immutable
sealed class ChatState {}

sealed class ChatActionState extends ChatState {}

final class EmptyMessage extends ChatActionState {}

final class UploadFile extends ChatActionState {
  final String filePath;
  final FileStatus fileStatus;

  UploadFile(this.filePath, {required this.fileStatus});
}

final class FileUploaded extends ChatActionState {
  final String fileUrl;

  FileUploaded({required this.fileUrl});
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
