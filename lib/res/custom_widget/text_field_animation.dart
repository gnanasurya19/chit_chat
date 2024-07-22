import 'package:chit_chat/res/colors.dart';
import 'package:chit_chat/res/custom_widget/svg_icon.dart';
import 'package:chit_chat/res/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:popover/popover.dart';

class TextFieldAnimation extends StatefulWidget {
  final Color color;
  final String text;
  final FocusNode? focus;
  final TextEditingController controller;
  final Function(String?)? onChange;
  final bool? isPassword;
  final bool? isPassWordVisible;
  final Function()? onSufClick;
  final bool? issignUpEmail;
  const TextFieldAnimation({
    required this.controller,
    required this.color,
    required this.text,
    super.key,
    this.focus,
    this.onChange,
    isPassword,
    this.isPassWordVisible,
    this.onSufClick,
    this.issignUpEmail,
  }) : isPassword = isPassword ?? false;

  @override
  State<TextFieldAnimation> createState() => _TextFieldAnimationState();
}

class _TextFieldAnimationState extends State<TextFieldAnimation>
    with TickerProviderStateMixin {
  late AnimationController animationController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 200));
  late Animation animation;
  late AnimationController sufficIconController;
  late Animation sufficIconanimation;
  @override
  void initState() {
    sufficIconController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    sufficIconanimation =
        Tween<double>(begin: 22, end: 0).animate(sufficIconController);
    super.initState();
    animation = Tween<double>(begin: 0, end: 1).animate(animationController);
    animate();
  }

  animate() async {
    await Future.delayed(
      const Duration(milliseconds: 300),
      () {
        animationController.forward();
      },
    );
  }

  @override
  void dispose() {
    sufficIconController.dispose();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isPassWordVisible ?? false) {
      sufficIconController.forward();
    } else {
      sufficIconController.reverse();
    }
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animationController.value,
          child: Container(
            margin: const EdgeInsets.only(top: 10),
            padding: EdgeInsets.fromLTRB(
                5, (1 - animationController.value) * 10, 5, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.text,
                  style:
                      TextStyle(color: widget.color, fontSize: AppFontSize.xs),
                ),
                TextFormField(
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(
                        widget.isPassword ?? false ? 6 : null),
                    if (widget.text == 'Name')
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]'))
                  ],
                  cursorColor: widget.color,
                  obscureText: (widget.isPassword ?? false) &&
                      (widget.isPassWordVisible != true),
                  onChanged: (value) {
                    if (widget.onChange != null) {
                      widget.onChange!(value);
                    }
                  },
                  focusNode: widget.focus,
                  style: TextStyle(color: widget.color),
                  controller: widget.controller,
                  decoration: InputDecoration(
                    suffixIcon: (widget.isPassword ?? false)
                        ? InkWell(
                            onTap: () {
                              if (widget.onSufClick != null) {
                                widget.onSufClick!();
                              }
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                        alignment: Alignment.center,
                                        child: SVGIcon(
                                          name: 'svg/eye.svg',
                                          color: widget.color,
                                          size: 16.0,
                                        )),
                                    AnimatedBuilder(
                                      animation: sufficIconanimation,
                                      child: Container(
                                        color: widget.color,
                                        height: sufficIconanimation.value,
                                        width: 2,
                                      ),
                                      builder: (context, child) {
                                        return Transform(
                                          alignment: Alignment.topLeft,
                                          transform: Matrix4.identity()
                                            ..rotateZ(-3.14 * 0.25),
                                          child: child,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        : widget.issignUpEmail ?? false
                            ? const EmailNotePopoverBtn()
                            : null,
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: widget.color),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: widget.color),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class EmailNotePopoverBtn extends StatelessWidget {
  const EmailNotePopoverBtn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showPopover(
          context: context,
          direction: PopoverDirection.top,
          backgroundColor: Theme.of(context).colorScheme.inverseSurface,
          width: MediaQuery.sizeOf(context).width * 0.8,
          bodyBuilder: (context) => Container(
            padding: const EdgeInsets.all(20),
            child: const Text(
                'Please note: You will need to verify your email address before logging in.'),
          ),
        );
      },
      child: const Icon(
        Icons.info,
        color: AppColor.white,
      ),
    );
  }
}
