import 'package:chit_chat/controller/auth_cubit/auth_cubit.dart';
import 'package:chit_chat/res/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForgotPasswordDialog extends StatefulWidget {
  final TextEditingController emailController;
  const ForgotPasswordDialog({
    super.key,
    required this.emailController,
  });

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  @override
  void dispose() {
    widget.emailController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      surfaceTintColor: AppColor.white,
      backgroundColor: Theme.of(context).colorScheme.onTertiary,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your email we will send you a password reset link',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              decoration: InputDecoration(
                  hintText: 'Please enter email',
                  filled: true,
                  fillColor: AppColor.blue.withOpacity(0.05),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  enabled: true,
                  enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: AppColor.greyline)),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: AppColor.greyline))),
              controller: widget.emailController,
            ),
            const SizedBox(
              height: 25,
            ),
            ElevatedButton(
                style: ButtonStyle(
                  foregroundColor: const WidgetStatePropertyAll(AppColor.white),
                  backgroundColor: WidgetStatePropertyAll(AppColor.darkBlue),
                  shape: WidgetStatePropertyAll(ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
                ),
                onPressed: () {
                  BlocProvider.of<AuthCubit>(context)
                      .forgotPassword(widget.emailController.text);
                },
                child: const Text("Reset password"))
          ],
        ),
      ),
    );
  }
}
