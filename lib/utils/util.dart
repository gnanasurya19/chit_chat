// import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io';
import 'dart:typed_data';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:chit_chat/res/colors.dart';
import 'package:chit_chat/res/common_instants.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'dart:ui' as ui;
import 'package:media_store_plus/media_store_plus.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Util {
  final mediaStorePlugin = MediaStore();

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

  showDeleteConfirmation(context, int msgCount, bool isDeleteForAll,
      Function() deleteForAll, Function() deleteForMe) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        clipBehavior: Clip.none,
        backgroundColor: Theme.of(context).colorScheme.onTertiary,
        child: Container(
          padding: EdgeInsets.all(style.insets.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(style.insets.md, style.insets.lg,
                    style.insets.lg, style.insets.lg),
                child: Text(
                    'Are you sure want to delete ${msgCount > 1 ? 'these messages' : 'this message'}?'),
              ),
              Container(
                padding: EdgeInsets.only(right: style.insets.md),
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isDeleteForAll)
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          deleteForAll();
                        },
                        child: Text('Delete for everyone'),
                      ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        deleteForMe();
                      },
                      child: Text('Delete for me'),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Cancel'),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
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
    final cachedFile = await DefaultCacheManager().getSingleFile(url);
    final cachedFilepath = path.dirname(cachedFile.path);

    String mediaExtention = mediaType == 'image' ? "jpeg" : 'mp4';
    String prefix = mediaType == 'image' ? 'IMG' : 'VID';

    // generate image name
    final String fileID = DateFormat('yyyyMMddhhmmS').format(DateTime.now());
    final String fileName = "$prefix-$fileID-CC.$mediaExtention";

    final newFile =
        await cachedFile.copy('$cachedFilepath${path.separator}$fileName');

    //stores to device
    await MediaStore().saveFile(
      dirName: DirName.download,
      dirType: DirType.download,
      tempFilePath: newFile.path,
    );

    util.showSnackbar(context,
        "${mediaType == 'image' ? 'Image' : 'Video'} Downloaded", 'success');
  }

  Future<Uint8List?> createCircularBitmap(Uint8List imageBytes) async {
    try {
      // Decode the image bytes into an image
      final ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image originalImage = frameInfo.image;

      // Determine the smaller dimension (width or height) to create a square
      final int size = originalImage.width < originalImage.height
          ? originalImage.width
          : originalImage.height;

      // Create a square canvas to center the image
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      // Fill the canvas with transparency
      final Paint paint = Paint()..color = const Color(0x00000000);
      canvas.drawRect(
          Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()), paint);

      // Calculate offsets to center the image on the square canvas
      final double dx = (size - originalImage.width) / 2;
      final double dy = (size - originalImage.height) / 2;

      // Clip the canvas to a circle
      final Path clipPath = Path()
        ..addOval(Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()));
      canvas.clipPath(clipPath);

      // Draw the original image centered on the square canvas
      canvas.drawImage(originalImage, Offset(dx, dy), Paint());

      // Render the canvas as an image
      final ui.Image circularImage =
          await recorder.endRecording().toImage(size, size);

      // Convert the image back to bytes
      final ByteData? byteData =
          await circularImage.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  Future<Uint8List> getProfileFromLocal(String url) async {
    final chachedFile = await DefaultCacheManager().getSingleFile(url);
    return await chachedFile.readAsBytes();
  }

  Directory? directory;
  Future<String?> checkCacheAudio(String path) async {
    directory = directory ?? await getApplicationDocumentsDirectory();
    String fullPath = directory!.path + Platform.pathSeparator + path;
    if (await File(fullPath).exists()) {
      return fullPath;
    }
    return null;
  }

  Future<String> downloadtoCache(String audioUrl, String path) async {
    final localPath = await networkApiService.downloadAudio(audioUrl, path);
    return localPath;
  }

  changeTheme(ThemeSwitcherState? themestate, BuildContext context) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String currentTheme = sp.getString('thememode') ?? 'light';
    if (currentTheme == 'system' && context.mounted) {
      final brightness = MediaQuery.platformBrightnessOf(context);
      themestate?.changeTheme(
          theme: brightness == Brightness.light
              ? MyAppTheme.darkTheme
              : MyAppTheme.lightTheme);
    }
  }

  Future<void> setUpMediaStore() async {
    if (Platform.isAndroid) {
      await MediaStore.ensureInitialized();
    }

    List<Permission> permissions = [
      Permission.storage,
    ];

    if ((await mediaStorePlugin.getPlatformSDKInt()) >= 33) {
      permissions.add(Permission.photos);
      permissions.add(Permission.audio);
      permissions.add(Permission.videos);
    }

    await permissions.request();

    MediaStore.appFolder = "ChitChat";
  }
}
