import 'package:flutter/material.dart';

class AppStyle {
  AppStyle({Size? screenSize}) {
    if (screenSize == null) {
      scale = 1;
    } else {
      final currentScreen = screenSize.width < screenSize.height
          ? screenSize.width
          : screenSize.height;
      if (currentScreen > 1024) {
        scale = 1.25;
      } else if (currentScreen > 768) {
        scale = 1.19;
      } else if (currentScreen > 600) {
        scale = 1.17;
      } else if (currentScreen > 480) {
        scale = 1.1;
      } else if (currentScreen > 412) {
        scale = 1.03;
      } else if (currentScreen > 360) {
        scale = 1;
      } else {
        scale = 0.85;
      }
    }
  }
  late double scale;
  late final text = _AppText(scale);
  late final insets = _Insets(scale);
  late final icon = _IconSize(scale);
  late final radius = _Radius(scale);
}

class _AppText {
  _AppText(this.scale);
  late double scale;

  // late TextStyle h = TextStyle(fontFamily: 'Roboto-Bold', fontSize: 55 * scale);

  // late TextStyle h1 =
  //     TextStyle(fontFamily: 'Roboto-Bold', fontSize: 32 * scale);
  // late TextStyle h2 =
  //     TextStyle(fontFamily: 'Roboto-Bold', fontSize: 26 * scale);
  // late TextStyle h3 =
  //     TextStyle(fontFamily: 'Roboto-Bold', fontSize: 18 * scale);
  // late TextStyle h4 =
  //     TextStyle(fontFamily: 'Roboto-Bold', fontSize: 16 * scale);
  // late TextStyle h5 =
  //     TextStyle(fontFamily: 'Roboto-Bold', fontSize: 14 * scale);

  // late TextStyle bodyTitleLg =
  //     TextStyle(fontFamily: 'Roboto-Regular', fontSize: 24 * scale);
  // late TextStyle bodyTitle =
  //     TextStyle(fontFamily: 'Roboto-Regular', fontSize: 20 * scale);

  // late TextStyle bodyContentLg =
  //     TextStyle(fontFamily: 'Roboto-Regular', fontSize: 18 * scale);
  // late TextStyle bodyContent =
  //     TextStyle(fontFamily: 'Roboto-Regular', fontSize: 16 * scale);

  // late TextStyle bodyContentSmall =
  //     TextStyle(fontFamily: 'Roboto-Regular', fontSize: 14 * scale);
  // late TextStyle bodyContentXSmall =
  //     TextStyle(fontFamily: 'Roboto-Regular', fontSize: 12 * scale);

  // late TextStyle titleLarge =
  //     TextStyle(fontFamily: 'Roboto-Medium', fontSize: 20 * scale);
  // late TextStyle titleMd =
  //     TextStyle(fontFamily: 'Roboto-Medium', fontSize: 16 * scale);
  // late TextStyle title =
  //     TextStyle(fontFamily: 'Roboto-Medium', fontSize: 14 * scale);
  // late TextStyle titleSmall =
  //     TextStyle(fontFamily: 'Roboto-Medium', fontSize: 12 * scale);

  late TextStyle loginTitle =
      TextStyle(fontFamily: 'Roboto-Bold', fontSize: 40 * scale);

  late TextStyle regularXXS =
      TextStyle(fontFamily: 'Roboto-Regular', fontSize: 08 * scale);
  late TextStyle regularXS =
      TextStyle(fontFamily: 'Roboto-Regular', fontSize: 10 * scale);
  late TextStyle regularSmall =
      TextStyle(fontFamily: 'Roboto-Regular', fontSize: 12 * scale);
  late TextStyle regular =
      TextStyle(fontFamily: 'Roboto-Regular', fontSize: 14 * scale);
  late TextStyle regularMedium =
      TextStyle(fontFamily: 'Roboto-Regular', fontSize: 17 * scale);
  late TextStyle regularLarge =
      TextStyle(fontFamily: 'Roboto-Regular', fontSize: 20 * scale);
  late TextStyle regularXLarge =
      TextStyle(fontFamily: 'Roboto-Regular', fontSize: 23 * scale);

  late TextStyle semiBoldXXS =
      TextStyle(fontFamily: 'Roboto-Medium', fontSize: 08 * scale);
  late TextStyle semiBoldXS =
      TextStyle(fontFamily: 'Roboto-Medium', fontSize: 10 * scale);
  late TextStyle semiBoldSmall =
      TextStyle(fontFamily: 'Roboto-Medium', fontSize: 12 * scale);
  late TextStyle semiBold =
      TextStyle(fontFamily: 'Roboto-Medium', fontSize: 14 * scale);
  late TextStyle semiBoldMedium =
      TextStyle(fontFamily: 'Roboto-Medium', fontSize: 17 * scale);
  late TextStyle semiBoldLarge =
      TextStyle(fontFamily: 'Roboto-Medium', fontSize: 20 * scale);
  late TextStyle semiBoldXLarge =
      TextStyle(fontFamily: 'Roboto-Medium', fontSize: 23 * scale);

  late TextStyle boldXXS =
      TextStyle(fontFamily: 'Roboto-Bold', fontSize: 08 * scale);
  late TextStyle boldXS =
      TextStyle(fontFamily: 'Roboto-Bold', fontSize: 10 * scale);
  late TextStyle boldSmall =
      TextStyle(fontFamily: 'Roboto-Bold', fontSize: 12 * scale);
  late TextStyle bold =
      TextStyle(fontFamily: 'Roboto-Bold', fontSize: 14 * scale);
  late TextStyle boldMedium =
      TextStyle(fontFamily: 'Roboto-Bold', fontSize: 17 * scale);
  late TextStyle boldLarge =
      TextStyle(fontFamily: 'Roboto-Bold', fontSize: 20 * scale);
  late TextStyle boldXLarge =
      TextStyle(fontFamily: 'Roboto-Bold', fontSize: 23 * scale);
}

class _Insets {
  _Insets(this.scale);
  late final double scale;
  late final xs = 5 * scale;
  late final sm = 8 * scale;
  late final md = 12 * scale;
  late final lg = 18 * scale;
  late final xl = 22 * scale;
  late final xxl = 30 * scale;
}

class _IconSize {
  _IconSize(this.scale);
  late final double scale;
  late final xxs = 12 * scale;
  late final xs = 15 * scale;
  late final sm = 20 * scale;
  late final rg = 25 * scale;
  late final md = 35 * scale;
  late final lg = 40 * scale;
  late final xl = 50 * scale;
}

class _Radius {
  _Radius(this.scale);
  late double scale;
  late final xs = 5 * scale;
  late final sm = 8 * scale;
  late final md = 12 * scale;
  late final lg = 16 * scale;
  late final xl = 20 * scale;
}
