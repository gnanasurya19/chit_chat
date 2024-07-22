part of 'media_cubit.dart';

@immutable
sealed class MediaState {}

sealed class MediaActionState extends MediaState {}

final class MediaDownloaded extends MediaActionState {
  final String mediaType;

  MediaDownloaded({required this.mediaType});
}

final class MediaInitial extends MediaState {
  final bool iscontentVisible;
  final MediaType? mediaType;

  MediaInitial({required this.iscontentVisible, this.mediaType});
}

enum MediaType {
  image,
  video,
  gif,
}
