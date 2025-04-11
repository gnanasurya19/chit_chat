import 'dart:io';

import 'package:chit_chat/res/common_instants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
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
    util.checkNetwork().then((value) {
      downloadFromURL(mediaUrl, type, context);
    }).catchError((err) {
      util.downloadFromCache(mediaUrl, type, context);
    });
  }

  void downloadFromURL(String url, String mediaType, context) async {
    final saveDirectory =
        Directory('/storage/emulated/0/Download').absolute.path;

    String mediaExtention = mediaType == 'image' ? "jpeg" : 'mp4';
    String prefix = mediaType == 'image' ? 'IMG' : 'VID';

    final String fileID = DateFormat('yyyyMMddhhmmS').format(DateTime.now());
    final String fileName = "$prefix-$fileID-CC.$mediaExtention";

    await FlutterDownloader.enqueue(
      url: url,
      savedDir: saveDirectory,
      fileName: fileName,
      openFileFromNotification: true,
      showNotification: true,
      saveInPublicStorage: true,
      allowCellular: true,
    );

    // util.showSnackbar(context,
    //     "${mediaType == 'image' ? 'Image' : 'Video'} Downloaded", 'success');
  }
}
