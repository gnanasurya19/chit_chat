part of 'home_cubit.dart';

@immutable
sealed class HomeState {}

sealed class HomeActionState extends HomeState {}

final class HomeReadyState extends HomeState {
  final List<UserData> userList;
  final UserModel user;
  HomeReadyState({required this.userList, required this.user});
}

final class HomeSignOut extends HomeActionState {}

final class HomeToSearch extends HomeActionState {}
