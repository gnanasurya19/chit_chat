part of 'auth_cubit.dart';

@immutable
sealed class AuthState {}

sealed class AuthActionState extends AuthState {}

enum PageStatus { notSignedIn, signIn, signUp, signedIn }

final class AuthViewState extends AuthState {
  final PageStatus status;
  final UserModel userModel;
  final bool buttonLoader;
  AuthViewState(
      {required this.buttonLoader,
      required this.status,
      required this.userModel});
}

final class AuthToast extends AuthActionState {
  final String type;
  final String text;

  AuthToast({required this.type, required this.text});

  @override
  String toString() {
    return text;
  }
}

final class AuthAlert extends AuthActionState {
  final String type;
  final String text;

  AuthAlert({required this.type, required this.text});
}

final class AuthUserNotFound extends AuthActionState {}

final class AuthUserRegisterSuccess extends AuthActionState {}

final class AuthPasswordResetMailSent extends AuthActionState {}

final class AuthUserLoginSuccess extends AuthActionState {}

final class AuthVerifyUserEmail extends AuthActionState {}

final class AuthLoading extends AuthActionState {}

final class AuthCancelLoading extends AuthActionState {}
