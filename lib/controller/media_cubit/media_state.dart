part of 'media_cubit.dart';

@immutable
sealed class MediaState {}

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
