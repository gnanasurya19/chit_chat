part of 'chat_cubit.dart';

@immutable
sealed class ChatState {}

sealed class ChatActionState extends ChatState {}

sealed class ChatSelectionState extends ChatState {}

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

final class ChatDeleteDialogState extends ChatActionState {
  final int msgCount;
  final Function() deleteForAll;
  final Function() deleteOnlyForMe;
  final bool isDeleteForAll;
  ChatDeleteDialogState(
      {required this.deleteForAll,
      required this.msgCount,
      required this.isDeleteForAll,
      required this.deleteOnlyForMe});
}

final class ChatReady extends ChatState {
  final bool? loadingList;
  final bool? loadingOldchat;
  final List<MessageModel> messageList;
  final bool? isMsgsSelected;

  ChatReady(
      {required this.messageList,
      this.loadingList,
      this.loadingOldchat,
      this.isMsgsSelected});
}

final class ChatListEmpty extends ChatState {}

final class ChatError extends ChatState {}

final class ChatMessageSelectedState extends ChatSelectionState {
  final bool? isMessageSelected;
  final int? selectedMsgCount;

  ChatMessageSelectedState({this.isMessageSelected, this.selectedMsgCount});
}

final class ChatMessgesDeselectedState extends ChatSelectionState {}

enum FileStatus {
  uploading,
  preview,
}
