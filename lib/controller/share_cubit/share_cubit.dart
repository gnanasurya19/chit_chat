import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

part 'share_state.dart';

class ShareCubit extends Cubit<ShareState> {
  ShareCubit() : super(ShareInitial());
  StreamSubscription? _intentSub;
  List<SharedMediaFile> mediaFiles = [];

  void receiveshareIntent() {
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen(
      (sharedFiles) {
        mediaFiles.clear();
        mediaFiles.addAll(sharedFiles);
      },
    );

    ReceiveSharingIntent.instance.getInitialMedia().then((sharedFiles) {
      mediaFiles.clear();
      mediaFiles.addAll(sharedFiles);
      ReceiveSharingIntent.instance.reset();
    });
  }

  @override
  Future<void> close() {
    _intentSub?.cancel();
    return super.close();
  }
}
