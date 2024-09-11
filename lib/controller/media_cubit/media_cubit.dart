import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:intl/intl.dart';
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

  Future downloadMedia(String url, String mediaType) async {
    // get's the cache of the image if not available downloads from network
    final chachedFile = await DefaultCacheManager().getSingleFile(url);
    Directory documentDirectory = Directory('/storage/emulated/0/Download');
    String mediaExtention = mediaType == 'image' ? ".jpeg" : 'mp4';
    String prefix = mediaType == 'image' ? 'IMG' : 'VID';
    Uint8List bytes = await chachedFile.readAsBytes();

    // generate image name
    final String imageName = DateFormat('yyyyMMddhhmm').format(DateTime.now());

    //generate file
    File newFile =
        File('${documentDirectory.path}/$prefix-$imageName-CC.$mediaExtention');

    //checking existing file
    int count = 1;
    while (await newFile.exists()) {
      String newImageName = "$imageName$count";
      File file = File(
          '${documentDirectory.path}/$prefix-$newImageName-CC.$mediaExtention');
      newFile = file;
      count++;
    }

    //stores to device
    await newFile.writeAsBytes(bytes);
    emit(MediaDownloaded(mediaType: mediaType == 'image' ? 'Image' : 'Video'));
  }

  shareFile(String fileurl) async {
    // final chachedFile = await DefaultCacheManager().getSingleFile(fileurl);
    // Share.shareXFiles([XFile(chachedFile.path)]);
  }
}
