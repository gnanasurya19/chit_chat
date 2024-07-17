part of 'media_cubit.dart';

@immutable
sealed class MediaState {}

final class MediaInitial extends MediaState {
  final bool isAppbarVisible;
  final MediaType? mediaType;

  MediaInitial({required this.isAppbarVisible, this.mediaType});
}

enum MediaType {
  image,
  video,
  gif,
}
