import 'package:flutter/material.dart';

class AnimateHeight extends StatelessWidget {
  const AnimateHeight(
      {super.key,
      required this.child,
      required this.isOpen,
      required this.height});
  final Widget child;
  final bool isOpen;
  final double height;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
        height: isOpen ? height : 0,
        duration: const Duration(milliseconds: 400),
        child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(), child: child));
  }
}
