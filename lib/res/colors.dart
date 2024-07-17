import 'package:chit_chat/res/fonts.dart';
import 'package:flutter/material.dart';

class AppColor {
  static const Color white = Color(0xffffffff);
  static const Color black = Color(0xff000000);
  static const Color blackGrey = Color(0xff242e38);
  static const Color blueGrey = Color(0xff233040);
  static const Color darkblueGrey = Color(0xff1d232f);
  static const Color lightgreyText = Color(0xFFE0E2FF);
  static const Color greyText = Color(0xFF607D8B);
  static Color darkGreyText = Colors.blueGrey[700]!;
  static const Color blue = Color(0xFF2196F3);
  static Color darkBlue = Colors.blue.shade700;
  static const Color pink = Color(0xFFff469c);
  static const Color green = Colors.green;
  static const Color loginBg = Color(0xffd6e2ea);
  static const Color darkLoginBg = Color(0xff262c3a);
  static const Color greyline = Color(0xFFCCCCCC);
  static const Color greyBg = Color(0xFFeeeeee);
}

class MyAppTheme {
  static ThemeData lightTheme = ThemeData(
    textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColor.blue,
        selectionColor: AppColor.blue.withOpacity(0.5),
        selectionHandleColor: AppColor.blue),
    brightness: Brightness.light,
    fontFamily: Roboto.regular,
    colorScheme: ColorScheme.light(
      inversePrimary: AppColor.blue,
      inverseSurface: AppColor.white,
      tertiaryContainer: AppColor.black,
      onTertiary: AppColor.white,
      surface: AppColor.loginBg,
      primary: AppColor.blue,
      primaryContainer: AppColor.blue,
      secondary: AppColor.darkGreyText,
      tertiary: AppColor.greyText,
    ),
  );
  static ThemeData darkTheme = ThemeData(
      textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppColor.blue,
          selectionColor: AppColor.blue.withOpacity(0.5),
          selectionHandleColor: AppColor.blue),
      brightness: Brightness.dark,
      fontFamily: Roboto.regular,
      colorScheme: ColorScheme.dark(
        inversePrimary: AppColor.blueGrey,
        inverseSurface: AppColor.darkblueGrey,
        tertiaryContainer: AppColor.white,
        onTertiary: AppColor.blackGrey,
        surface: AppColor.darkLoginBg,
        primary: AppColor.darkLoginBg,
        primaryContainer: AppColor.darkBlue,
        secondary: AppColor.white,
        tertiary: AppColor.white,
      ));
}
