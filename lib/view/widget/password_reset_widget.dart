import 'package:chit_chat/controller/profile_cubit/profile_cubit.dart';
import 'package:chit_chat/res/colors.dart';
import 'package:chit_chat/res/common_instants.dart';
import 'package:chit_chat/res/custom_widget/svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class PasswordResetWidget extends StatefulWidget {
  const PasswordResetWidget({
    super.key,
  });

  @override
  State<PasswordResetWidget> createState() => _PasswordResetWidgetState();
}

class _PasswordResetWidgetState extends State<PasswordResetWidget> {
  final InputDecoration inputDecoration = InputDecoration(
      isDense: true,
      enabled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(style.radius.xs),
        borderSide: const BorderSide(color: AppColor.greyText),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(style.radius.xs),
        borderSide: const BorderSide(color: AppColor.greyText),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(style.radius.xs),
        borderSide: const BorderSide(color: Colors.red),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(style.radius.xs),
        borderSide: const BorderSide(color: Colors.red),
      ));
  final currentPassControl = TextEditingController();
  final newPasswordControl = TextEditingController();
  final confirmPasswordControl = TextEditingController();
  final formkey = GlobalKey<FormState>();
  bool isPasswordVisible = false;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shadowColor: AppColor.black,
      elevation: 20,
      backgroundColor: Theme.of(context).colorScheme.onTertiary,
      child: Form(
        key: formkey,
        child: Container(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
                child: Text(
                  'RESET PASSWORD',
                  style: style.text.boldLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "Current password",
                  style: style.text.regular,
                ),
              ),
              TextFormField(
                obscureText: !isPasswordVisible,
                controller: currentPassControl,
                inputFormatters: [LengthLimitingTextInputFormatter(6)],
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: inputDecoration.copyWith(
                    suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                  icon: SVGIcon(
                    name: isPasswordVisible ? 'eye' : 'hide-eye',
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    size: style.icon.sm,
                  ),
                )),
                validator: (value) {
                  if (value == '') {
                    return 'Please enter current password';
                  } else {
                    return null;
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "New password",
                  style: style.text.regular,
                ),
              ),
              TextFormField(
                controller: newPasswordControl,
                inputFormatters: [LengthLimitingTextInputFormatter(6)],
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: inputDecoration,
                validator: (value) {
                  if (value == '') {
                    return 'Please enter new password';
                  } else {
                    return null;
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "Confirm new password",
                  style: style.text.regular,
                ),
              ),
              TextFormField(
                controller: confirmPasswordControl,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                inputFormatters: [LengthLimitingTextInputFormatter(6)],
                decoration: inputDecoration,
                validator: (value) {
                  if (value == '') {
                    return 'Please enter confirm password';
                  } else if (newPasswordControl.text != value) {
                    return 'New and confirm password should match';
                  } else {
                    return null;
                  }
                },
              ),
              Gap(style.insets.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                        foregroundColor: AppColor.greyText),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Cancel',
                      style: style.text.semiBold,
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: AppColor.blue),
                    onPressed: () {
                      if (formkey.currentState!.validate()) {
                        BlocProvider.of<ProfileCubit>(context).changePassword(
                            currentPassControl.text, newPasswordControl.text);
                      }
                    },
                    child: Text(
                      'Update',
                      style: style.text.semiBold,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
