import 'package:chit_chat/res/colors.dart';
import 'package:chit_chat/res/fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColor.darkBlue,
        shape:
            ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Text(
          text,
          style: const TextStyle(fontSize: 15, color: AppColor.white),
        )));
  }

  doAlert(context, String content, String type) {
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
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 25,
                          ))
                    ],
                  ),
                  if (type == 'error')
                    Container(
                      alignment: Alignment.center,
                      child: Lottie.asset(
                        "assets/json/error.json",
                        repeat: false,
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                    ),
                  if (type == 'info')
                    Transform.rotate(
                      angle: 3.14,
                      child: Container(
                        alignment: Alignment.center,
                        child: Lottie.asset(
                          "assets/json/info.json",
                          repeat: false,
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                        ),
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
                      style: const TextStyle(
                          fontFamily: Roboto.bold,
                          color: AppColor.black,
                          fontSize: 16),
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
                                        ? AppColor.green
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
        }));
    // showDialog(
    //   context: context,
    //   builder: (context) => Dialog(
    //     clipBehavior: Clip.antiAliasWithSaveLayer,
    //     child:
    //           ),
    // );
  }

  slideInDialog(context, Widget widget) {
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
        barrierDismissible: true,
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
}
