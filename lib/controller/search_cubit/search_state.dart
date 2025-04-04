part of 'search_cubit.dart';

@immutable
sealed class SearchState {}

sealed class SearchActionState extends SearchCubit {}

final class SearchReadyState extends SearchState {
  final List<UserData> userList;
  final List<UserData> chatList;
  SearchReadyState({required this.chatList, required this.userList});
}

final class SearchTest extends SearchState {
  final List<UserData> userList;
  SearchTest({required this.userList});
}

final class SearchNotFoundState extends SearchState {}

final class SearchToChatState extends SearchState {
  final UserData user;

  SearchToChatState({required this.user});
}
