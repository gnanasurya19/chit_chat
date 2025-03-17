part of 'update_cubit.dart';

@immutable
sealed class UpdateState {}

final class UpdateInitial extends UpdateState {}

final class UpdateAvailableState extends UpdateState {}

final class DownloadState extends UpdateState {
  final double progress;
  final UpdateStatus state;

  DownloadState({required this.progress, required this.state});
}

enum UpdateStatus { hasUpdate, downloading, downloaded }

final class UptoDateState extends UpdateState {}

final class NetworkErrorState extends UpdateState {}

final class UpdateAlertState extends UpdateState {
  final String type;
  final String text;

  UpdateAlertState({required this.type, required this.text});
}
