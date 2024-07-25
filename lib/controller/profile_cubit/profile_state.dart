part of 'profile_cubit.dart';

@immutable
sealed class ProfileState {}

sealed class ProfileActionState extends ProfileState {}

final class ProfileInitial extends ProfileState {
  final UserModel user;
  final bool? isNotification;
  final bool? isDarkTheme;

  ProfileInitial({
    required this.user,
    this.isNotification,
    this.isDarkTheme,
  });
}

final class SignOut extends ProfileActionState {}
