import 'package:chit_chat/res/common_instants.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Align(
          alignment: Alignment.center,
          child: Center(
            child: Lottie.asset('assets/lottie/loading_animation.json',
                width: 200 * style.scale),
          ),
        ),
      ),
    );
  }
}
