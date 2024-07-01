import 'dart:math';

import 'package:flutter/material.dart';

class Roboto {
  static const String bold = 'Roboto-Bold';
  static const String regular = 'Roboto-Regular';
  static const String light = 'Roboto-Light';
  static const String medium = 'Roboto-Medium';
  static const String thin = 'Roboto-Thin';
}

class AppFontSize {
  static const double xxxs = 10;
  static const double xxs = 12;
  static const double xs = 14;
  static const double sm = 16;
  static const double md = 18;
  static const double lg = 20;
  static const double xl = 22;
  static const double xxl = 24;
  static const double xxxl = 26;
}

class ScaleSize {
  static double textScaleFactor(BuildContext context,
      {double maxTextScaleFactor = 1.5}) {
    final width = MediaQuery.of(context).size.width;
    double val = (width / 1400) * maxTextScaleFactor;
    return max(1, min(val, maxTextScaleFactor));
  }
}
