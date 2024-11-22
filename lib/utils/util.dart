// import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io';
import 'dart:typed_data';

import 'package:chit_chat/res/colors.dart';
import 'package:chit_chat/res/common_instants.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

class Util {
  PageRouteBuilder<dynamic> pageTransition(Widget name) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => name,
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  showSnackbar(context, text, type) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        backgroundColor: type == 'success' ? AppColor.green : AppColor.white,
        shape:
            ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: style.scale * 15,
              color: type == 'success' ? AppColor.white : AppColor.black),
        ),
      ),
    );
  }

  doAlert(context, String content, String type) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, -0.1);
          const end = Offset.zero;
          var curve = Curves.ease;
          final tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          final offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        opaque: false,
        barrierDismissible: true,
        pageBuilder: (BuildContext context, _, __) {
          return Dialog(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.center,
            shadowColor: AppColor.black,
            surfaceTintColor: AppColor.white,
            child: Container(
              color: AppColor.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.close_rounded,
                            size: style.icon.rg,
                          ))
                    ],
                  ),
                  if (type == 'error')
                    Container(
                      alignment: Alignment.center,
                      child: Lottie.asset(
                        "assets/lottie/error.json",
                        repeat: false,
                        width: 150,
                        height: 150,
                        fit: BoxFit.contain,
                      ),
                    ),
                  if (type == 'info')
                    Container(
                      alignment: Alignment.center,
                      child: Lottie.asset(
                        "assets/lottie/error.json",
                        repeat: false,
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                    ),
                  if (type == 'success')
                    Container(
                      alignment: Alignment.center,
                      child: Lottie.asset(
                        "assets/lottie/success_animation.json",
                        repeat: false,
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                    ),
                  if (type == 'network')
                    Container(
                      alignment: Alignment.center,
                      child: Lottie.asset(
                        "assets/lottie/no_network.json",
                        repeat: false,
                        width: 150,
                        height: 150,
                        fit: BoxFit.contain,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      content,
                      textAlign: TextAlign.center,
                      style:
                          style.text.boldMedium.copyWith(color: AppColor.black),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ButtonStyle(
                            padding: const WidgetStatePropertyAll(
                                EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 5)),
                            side: WidgetStatePropertyAll(BorderSide(
                                color: type == 'success'
                                    ? AppColor.green
                                    : type == 'info'
                                        ? AppColor.blue
                                        : type == 'network'
                                            ? AppColor.blue
                                            : const Color(0xfff98178)))),
                        child: const Text(
                          'OK',
                          style: TextStyle(
                              color: AppColor.black,
                              fontSize: 16,
                              letterSpacing: 1.2),
                        )),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  slideInDialog(context, Widget widget, [bool? isDismissible]) {
    Navigator.of(context).push(PageRouteBuilder(
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, -0.1);
          const end = Offset.zero;
          var curve = Curves.ease;
          final tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          final offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        opaque: false,
        barrierDismissible: isDismissible ?? true,
        pageBuilder: (BuildContext context, _, __) {
          return widget;
        }));
  }

  Future<XFile?> captureImage(ImageSource source) async {
    final file = await ImagePicker()
        .pickImage(source: source, preferredCameraDevice: CameraDevice.front);
    if (file != null) {
      return file;
    }
    throw false;
  }

  Future<List<XFile>?> captureMultiImage() async {
    final file =
        await ImagePicker().pickMultiImage(imageQuality: 80, limit: 10);
    if (file.isNotEmpty) {
      return file;
    }
    throw false;
  }

  Future<XFile?> captureVideo() async {
    final file = await ImagePicker().pickVideo(
      source: ImageSource.gallery,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (file != null) {
      return file;
    }
    throw false;
  }

  Future checkNetwork() async {
    List<ConnectivityResult> result = await Connectivity().checkConnectivity();
    if (result.any((element) => element == ConnectivityResult.none)) {
      throw false;
    } else {
      return true;
    }
  }

  Future downloadMedia(String url, String mediaType, context) async {
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
    showSnackbar(context, 'Image Downloaded', 'info');
  }
}
