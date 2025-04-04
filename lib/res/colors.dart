import 'package:flutter/material.dart';

class AppColor {
  static const Color white = Color(0xffffffff);
  static const Color black = Color(0xff000000);
  static const Color blackGrey = Color(0xff242e38);
  static const Color blueGrey = Color(0xff233040);
  static const Color darkblueGrey = Color(0xff1d232f);
  static const Color lightgreyText = Color(0xFFE0E2FF);
  static const Color greyText = Color(0xFF607D8B);
  static const Color darkGreyText = Color(0xFF455A64);
  static const Color blue = Color(0xFF2196F3);
  static const Color darkBlue = Color(0xFF1976D2);
  static const Color pink = Color(0xFFff469c);
  static const Color green = Colors.green;
  static const Color loginBg = Color(0xffd6e2ea);
  static const Color darkLoginBg = Color(0xff262c3a);
  static const Color greyline = Color(0xFFCCCCCC);
  static const Color greyBg = Color(0xFFeeeeee);
  static const Color redBg = Color(0xFFF9AAAA);
}

class MyAppTheme {
  static ThemeData lightTheme = ThemeData(
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColor.white,
      selectionColor: AppColor.blue.withValues(alpha: 0.5),
      selectionHandleColor: AppColor.blueGrey,
    ),
    brightness: Brightness.light,
    fontFamily: 'Roboto-Regular',
    colorScheme: const ColorScheme.light(
      inversePrimary: AppColor.blue,
      inverseSurface: AppColor.white,
      tertiaryContainer: AppColor.black,
      onTertiary: AppColor.white,
      surface: AppColor.loginBg,
      surfaceTint: AppColor.redBg,
      primary: AppColor.blue,
      primaryContainer: AppColor.blue,
      secondary: AppColor.darkGreyText,
      tertiary: AppColor.greyText,
      surfaceDim: AppColor.greyBg,
      onSecondary: AppColor.blue,
    ),
  );
  static ThemeData darkTheme = ThemeData(
    textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColor.blue,
        selectionColor: AppColor.blue.withValues(alpha: 0.5),
        selectionHandleColor: AppColor.blue),
    brightness: Brightness.dark,
    fontFamily: 'Roboto-Regular',
    colorScheme: const ColorScheme.dark(
        inversePrimary: AppColor.blueGrey,
        inverseSurface: AppColor.darkblueGrey,
        tertiaryContainer: AppColor.white,
        onTertiary: AppColor.blackGrey,
        surface: AppColor.darkLoginBg,
        surfaceTint: AppColor.darkLoginBg,
        primary: AppColor.darkLoginBg,
        primaryContainer: AppColor.darkBlue,
        secondary: AppColor.white,
        tertiary: AppColor.white,
        surfaceDim: AppColor.blueGrey,
        onSecondary: AppColor.white),
  );
}
