import 'package:chit_chat/controller/auth_cubit/auth_cubit.dart';
import 'package:chit_chat/res/colors.dart';
import 'package:chit_chat/res/common_instants.dart';
import 'package:chit_chat/res/fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({
    super.key,
  });

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final animationController =
      AnimationController(vsync: this, duration: const Duration(seconds: 3));
  final CountdownController countdownController =
      CountdownController(autoStart: true);
  bool isCountDown = false;
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    BlocProvider.of<AuthCubit>(context).verifyEmail(context);
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      verifyEmail();
    }
  }

  verifyEmail([bool? verified]) {
    FirebaseAuth.instance.currentUser!.reload();
    if (FirebaseAuth.instance.currentUser!.emailVerified) {
      animationController.forward().then((v) {
        Navigator.pushNamedAndRemoveUntil(context, 'home', (r) => false);
      });
    } else if (verified ?? false) {
      util.doAlert(context, 'Your Email is not yet verified', 'error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Verification'),
        centerTitle: true,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    'assets/lottie/email_verified.json',
                    controller: animationController,
                    width: MediaQuery.sizeOf(context).width / 2,
                    height: MediaQuery.sizeOf(context).width / 2,
                  ),
                  Container(
                    padding: const EdgeInsets.all(25),
                    child: Text(
                      'We have sent a verification mail to your "${FirebaseAuth.instance.currentUser!.email}" address please verify to sign-in into the application',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: Roboto.medium,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20, right: 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ),
                            onPressed: () {
                              verifyEmail(true);
                            },
                            child: const Text(
                              'Email Verified!',
                            ),
                          ),
                          TextButton(
                            onPressed: !(isCountDown)
                                ? () {
                                    BlocProvider.of<AuthCubit>(context)
                                        .verifyEmail(context);
                                    setState(() {
                                      isCountDown = true;
                                    });
                                  }
                                : null,
                            style: TextButton.styleFrom(
                                foregroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer),
                            child: const Text(
                              'Resent Verification mail',
                              style: TextStyle(),
                            ),
                          ),
                          if (isCountDown)
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Countdown(
                                seconds: 600,
                                controller: countdownController,
                                onFinished: () {
                                  setState(() {
                                    isCountDown = false;
                                  });
                                },
                                build: (context, value) {
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "${value ~/ 60}m : ${(value % 60).toStringAsFixed(0).padLeft(2, '0')}s ",
                                        style: const TextStyle(
                                          fontFamily: Roboto.bold,
                                          color: AppColor.darkBlue,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(25),
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                children: [
                  const TextSpan(
                    text:
                        'Please make sure to double check that your email address is valid or consider signing up with a new email address. - ',
                  ),
                  TextSpan(
                    text: 'Signup',
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.pushNamed(context, 'register');
                      },
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                      decorationColor: AppColor.blue,
                      color: AppColor.blue,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
