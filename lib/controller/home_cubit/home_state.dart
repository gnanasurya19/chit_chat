part of 'home_cubit.dart';

@immutable
sealed class HomeState {}

sealed class HomeActionState extends HomeState {}

final class HomeReadyState extends HomeState {
  final List<UserData> userList;
  HomeReadyState({required this.userList});
}

final class HomeChatLoading extends HomeState {}

final class HomeSignOut extends HomeActionState {}

final class HomeScreenLoading extends HomeActionState {}

final class HomeEditProfile extends HomeActionState {}

final class HomeProfileUploading extends HomeActionState {}

final class HomeToSearch extends HomeActionState {}
