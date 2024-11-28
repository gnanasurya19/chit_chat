part of 'chat_cubit.dart';

@immutable
sealed class ChatState {}

sealed class ChatActionState extends ChatState {}

final class EmptyMessage extends ChatActionState {}

final class OpenUploadFileDialog extends ChatActionState {}

final class UploadFile extends ChatActionState {
  final MediaType mediaType;
  final List<String> filePath;
  final FileStatus fileStatus;

  UploadFile(
      {required this.filePath,
      required this.fileStatus,
      required this.mediaType});
}

final class FileUploaded extends ChatActionState {
  final List<String> fileUrl;
  final MediaType mediaType;

  FileUploaded({required this.mediaType, required this.fileUrl});
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
