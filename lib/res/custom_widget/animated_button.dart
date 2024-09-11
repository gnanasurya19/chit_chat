import 'package:chit_chat_1/res/colors.dart';
import 'package:chit_chat_1/res/common_instants.dart';
import 'package:flutter/material.dart';

class AnimatedButton extends StatefulWidget {
  const AnimatedButton({
    super.key,
    required this.visible,
    required this.isLogin,
    required this.onClick,
    this.onInit,
  });
  final Function(double)? onInit;
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
      if (widget.onInit != null) {
        widget.onInit!(buttonKey.currentContext!.size!.width);
      }
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
                side: WidgetStatePropertyAll(BorderSide(
                    color:
                        widget.isLogin ? Colors.transparent : AppColor.white)),
                padding: const WidgetStatePropertyAll(EdgeInsets.all(15)),
                backgroundColor: const WidgetStatePropertyAll(AppColor.blue),
                foregroundColor: const WidgetStatePropertyAll(AppColor.white),
                overlayColor:
                    WidgetStatePropertyAll(AppColor.white.withOpacity(0.3))),
            onPressed: () {
              widget.onClick();
            },
            child: Text("CREATE AN ACCOUNT",
                style: style.text.semiBold.copyWith(
                  color: AppColor.white,
                )),
          ),
        ],
      ),
    );
  }
}
