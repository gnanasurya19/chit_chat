import 'package:flutter/material.dart';
import 'package:chit_chat/res/colors.dart';
import 'package:chit_chat/res/fonts.dart';

class AnimatedButton extends StatefulWidget {
  const AnimatedButton({
    super.key,
    required this.visible,
    required this.isLogin,
    required this.onClick,
    required this.onInit,
  });
  final Function(double) onInit;
  final Function() onClick;
  final bool visible;
  final bool isLogin;

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500));
  late Animation animation;
  final buttonKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    animation = Tween(begin: 1, end: 0).animate(animationController);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.onInit(buttonKey.currentContext!.size!.width);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: widget.visible ? 1 : 0,
      duration: const Duration(milliseconds: 500),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            key: buttonKey,
            style: ButtonStyle(
                side: MaterialStatePropertyAll(BorderSide(
                    color:
                        widget.isLogin ? Colors.transparent : AppColor.white)),
                padding: const MaterialStatePropertyAll(EdgeInsets.all(15)),
                backgroundColor: const MaterialStatePropertyAll(AppColor.blue),
                foregroundColor: const MaterialStatePropertyAll(AppColor.white),
                overlayColor:
                    MaterialStatePropertyAll(AppColor.white.withOpacity(0.3))),
            onPressed: () {
              widget.onClick();
            },
            child: Text(
              "CREATE AN ACCOUNT",
              textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
              style: const TextStyle(
                  color: AppColor.white,
                  fontFamily: Roboto.medium,
                  fontSize: AppFontSize.xs),
            ),
          ),
          // InkWell(
          //   borderRadius: BorderRadius.circular(30),
          //   onTap: () {
          //     widget.onClick();
          //   },
          //   child: Container(
          //     key: buttonKey,
          //     padding: const EdgeInsets.all(12),
          //     decoration: BoxDecoration(
          //       color: widget.isLogin           ? Theme.of(context).colorScheme.primaryContainer           : Colors.transparent,
          //       border: Border.all(
          //           color:
          //               widget.isLogin ? Colors.transparent : AppColor.white),
          //       borderRadius: BorderRadius.circular(30),
          //     ),
          //     child: Text(
          //       "CREATE AN ACCOUNT",
          //       textScaler:
          //           TextScaler.linear(ScaleSize.textScaleFactor(context)),
          //       style: const TextStyle(
          //           color: AppColor.white,
          //           fontFamily: Roboto.medium,
          //           fontSize: AppFontSize.xs),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
