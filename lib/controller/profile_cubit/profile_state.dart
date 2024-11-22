part of 'profile_cubit.dart';

@immutable
sealed class ProfileState {}

sealed class ProfileActionState extends ProfileState {}

final class ProfileInitial extends ProfileState {
  final UserData user;
  final bool? isNotification;
  final bool? isDarkTheme;
  final String? editedprofile;

  ProfileInitial({
    required this.user,
    this.isNotification,
    this.isDarkTheme,
    this.editedprofile,
  });
}

final class AddDataToFeild extends ProfileActionState {
  final String? name;
  final String? phoneNo;

  AddDataToFeild({this.name, this.phoneNo});
}

final class SignOut extends ProfileActionState {}

final class ChangePasswordState extends ProfileActionState {}

final class SigningOutState extends ProfileActionState {}

final class AlertToast extends ProfileActionState {
  final String type;
  final String text;

  AlertToast({required this.type, required this.text});
}

final class PasswordUpdated extends ProfileActionState {}

final class AlertState extends ProfileActionState {
  final String type;
  final String text;

  AlertState({required this.type, required this.text});
}

final class ProfileUpdate extends ProfileActionState {}

final class ProfileLoader extends ProfileActionState {}

final class ProfileLoaderCancel extends ProfileActionState {}
