import 'package:chit_chat/res/common_instants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:share_plus/share_plus.dart';

part 'media_state.dart';

class MediaCubit extends Cubit<MediaState> {
  MediaCubit() : super(MediaInitial(iscontentVisible: true));
  bool isVisible = true;

  onInit() {
    emit(MediaInitial(iscontentVisible: true));
  }

  toggleStatusbar([bool? visiblility]) {
    isVisible = visiblility ?? isVisible;
    if (isVisible) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom],
      );
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    }
    isVisible = !isVisible;
    emit(MediaInitial(iscontentVisible: isVisible));
  }

  shareFile(String fileurl) async {
    final chachedFile = await DefaultCacheManager().getSingleFile(fileurl);
    Share.shareXFiles([XFile(chachedFile.path)]);
  }

  void downloadMedia(String mediaUrl, String type, context) {
    util.downloadMedia(mediaUrl, type, context);
  }
}
