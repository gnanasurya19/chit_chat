import 'package:flutter/material.dart';

class OpacityPageTransition extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    return _OpacityPageTransition(
      opacity: animation,
      child: child,
    );
  }
}

class _OpacityPageTransition extends StatelessWidget {
  _OpacityPageTransition({required opacity, required this.child})
      : opacity = CurvedAnimation(
          parent: opacity,
          curve: Curves.linear,
        ).drive(opacityTween);

  final Animation<double> opacity;
  final Widget child;

  static final Animatable<double> opacityTween = Tween(begin: 0, end: 1);

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: opacity,
      child: child,
    );
  }
}
