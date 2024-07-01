part of 'chat_cubit.dart';

@immutable
sealed class ChatState {}

sealed class ChatActionState extends ChatState {}

final class EmptyMessage extends ChatActionState {}

final class ChatLoading extends ChatState {}

final class ChatReady extends ChatState {
  final List<MessageModel> messageList;

  ChatReady({required this.messageList});
}

final class ChatError extends ChatState {}

final class ChatFirstMessage extends ChatState {}
