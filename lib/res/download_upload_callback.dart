import 'dart:isolate';
import 'dart:ui';

import 'package:chit_chat/res/common_instants.dart';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

BuildContext? setContext;

final fileUploadtask = 'workmanager_file_upload';

@pragma('vm:entry-point')
void downloadcallback(String id, int statusInt, int progress) {
  final SendPort? send =
      IsolateNameServer.lookupPortByName('downloader_send_port1');
  send?.send([id, statusInt, progress]);
}

void onDownloadComplete() {
  try {
    final context = setContext;
    print("${context?.mounted} mounted");
    if (context != null) {
      util.showSnackbar(context, 'Download completed', 'error');
    }
  } on Exception catch (e) {
    print("Toast Exception: $e");
  }
}

@pragma('vm:entry-point')
callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) {
    if (taskName == fileUploadtask) {}
    return Future.value(true);
  });
}
