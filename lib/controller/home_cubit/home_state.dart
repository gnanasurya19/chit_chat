part of 'home_cubit.dart';

@immutable
sealed class HomeState {}

sealed class HomeActionState extends HomeState {}

final class HomeReadyState extends HomeState {
  final List<UserData> userList;
  HomeReadyState({required this.userList});
}

final class HomeChatLoading extends HomeState {}

final class HomeToSearch extends HomeActionState {}
