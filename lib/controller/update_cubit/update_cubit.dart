import 'dart:async';
import 'dart:io';

import 'package:chit_chat/res/common_instants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:open_file_plus/open_file_plus.dart';

part 'update_state.dart';

class UpdateCubit extends Cubit<UpdateState> {
  UpdateCubit() : super(UpdateInitial()) {
    oninit();
  }

  String currentVersion = '';
  String latestVersion = '';
  String downloadUrl = '';
  bool isFileDownloaded = false;

  oninit() async {
    await PackageInfo.fromPlatform().then((value) {
      currentVersion = value.version;
    });
  }

  Future checkforUpdate(String type) async {
    util.checkNetwork().then((e) async {
      if (latestVersion == '') {
        dynamic value = await networkApiService.checkUpdate().catchError((e) {
          if (type == 'manual') {
            if (e is TimeoutException || e is SocketException) {
              emit(NetworkErrorState());
            }
          }
        });
        latestVersion = value["tag_name"];
        List loop = value['assets'];
        for (var element in loop) {
          downloadUrl = element['url'];
        }
      }
      if (currentVersion == '') {
        await oninit();
      }
      if (downloadUrl != '' && currentVersion != latestVersion) {
        emit(UpdateAvailableState());
        emit(DownloadState(
          progress: 0,
          state: UpdateStatus.hasUpdate,
        ));
      } else if (currentVersion == latestVersion && type == 'manual') {
        emit(UptoDateState());
      }
    }).catchError((e) {
      if (type == 'manual') {
        emit(NetworkErrorState());
      }
    });
  }

  downLoadUpdate() async {
    final path = Directory('/storage/emulated/0/Download');
    final String downloadPath =
        "${path.path}${Platform.pathSeparator}chit_chat$latestVersion.apk";
    bool isExists = await File(
            "${path.path}${Platform.pathSeparator}chit_chat$latestVersion.apk")
        .exists();
    if (isExists) {
      OpenFile.open(downloadPath);
    } else {
      await util.checkNetwork().then((value) async {
        Dio dio = Dio();
        if (!downloadUrl.contains('api')) {
          downloadUrl =
              downloadUrl.split("github.com").join("api.github.com/repos");
        }
        await dio.download(
          downloadUrl,
          "${path.path}${Platform.pathSeparator}chit_chat$latestVersion.apk",
          deleteOnError: true,
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/octet-stream',
            "X-GitHub-Api-Version": "2022-11-28",
          }),
          onReceiveProgress: (count, total) {
            double progress = count / total;
            emit(DownloadState(
                state: UpdateStatus.downloading, progress: progress));
          },
        ).then((value) {
          emit(DownloadState(state: UpdateStatus.downloaded, progress: 1));
          OpenFile.open(
              "${path.path}${Platform.pathSeparator}chit_chat$latestVersion.apk");
          isFileDownloaded = true;
        });
      });
    }
  }

  @override
  void onChange(Change<UpdateState> change) {
    super.onChange(change);
  }
}
