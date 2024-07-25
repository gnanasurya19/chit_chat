// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SVGIcon extends StatelessWidget {
  final String name;
  final double? size;
  final Color? color;
  const SVGIcon({
    super.key,
    required this.name,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      "assets/svg/$name.svg",
      height: size ?? 10.0,
      width: size ?? 10.0,
      color: color,
    );
  }
}
