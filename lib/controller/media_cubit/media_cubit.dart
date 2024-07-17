import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
part 'media_state.dart';

class MediaCubit extends Cubit<MediaState> {
  MediaCubit() : super(MediaInitial(isAppbarVisible: true));

  onInit() {
    emit(MediaInitial(isAppbarVisible: true));
  }

  toggleStatusbar(MediaInitial state) {
    if (!state.isAppbarVisible) {
      emit(MediaInitial(isAppbarVisible: true));
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    } else {
      emit(MediaInitial(isAppbarVisible: false));
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.bottom]);
    }
  }

  downloadImage(String url) async {
    // get's the cache of the image if not available downloads from network
    final chachedFile = await DefaultCacheManager().getSingleFile(url);
    Directory documentDirectory = Directory('/storage/emulated/0/Download');

    Uint8List bytes = await chachedFile.readAsBytes();

    // generate image name
    final String imageName = DateFormat('yyyyMMddhhmm').format(DateTime.now());

    //generate file
    File newFile = File('${documentDirectory.path}/IMG-$imageName-CC.png');

    //checking existing file
    int count = 1;
    while (await newFile.exists()) {
      String newImageName = "$imageName$count";
      File file = File('${documentDirectory.path}/IMG-$newImageName-CC.png');
      newFile = file;
      count++;
    }

    //stores to device
    await newFile.writeAsBytes(bytes);
  }

  shareFile(String fileurl) async {
    final chachedFile = await DefaultCacheManager().getSingleFile(fileurl);
    Share.shareXFiles([XFile(chachedFile.path)]);
  }
}
