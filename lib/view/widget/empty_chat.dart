import 'package:chit_chat/res/colors.dart';
import 'package:chit_chat/res/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';

class EmptyChat extends StatefulWidget {
  const EmptyChat({super.key, required this.onPress});
  final Function() onPress;

  @override
  State<EmptyChat> createState() => _EmptyChatState();
}

class _EmptyChatState extends State<EmptyChat>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 200));
  late Animation<double> animation;
  @override
  void initState() {
    super.initState();
    animation = Tween<double>(begin: 1, end: 0.9).animate(animationController);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
        onLongPress: () {
          animationController.forward();
        },
        onLongPressEnd: (details) {
          animationController.reverse();
          widget.onPress();
        },
        onTap: () {
          animationController
              .forward()
              .whenComplete(() => animationController.reverse());
          widget.onPress();
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(color: AppColor.white.withOpacity(0.5)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Chat is Empty',
                style: TextStyle(fontSize: AppFontSize.md),
              ),
              const Text(
                "Click here to say 'HI' to your friend",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: AppFontSize.xs),
              ),
              ScaleTransition(
                scale: animation,
                child: LottieBuilder.asset(
                  'assets/lottie/greeting_animated.json',
                  width: MediaQuery.of(context).size.width * 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
