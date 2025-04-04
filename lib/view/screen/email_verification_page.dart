// ignore_for_file: use_build_context_synchronously

import 'package:chit_chat/controller/auth_cubit/auth_cubit.dart';
import 'package:chit_chat/res/colors.dart';
import 'package:chit_chat/res/common_instants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  int counterValue = 600;
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

  void checkDuration() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    final value = sp.getInt('resendMailcounter');
    if (value != null && value != 0) {
      setState(() {
        counterValue = value;
        isCountDown = true;
      });
    }
  }

  setCounterValue(double value) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setInt('resendMailcounter', value.toInt());
  }

  @override
  void initState() {
    // BlocProvider.of<AuthCubit>(context).verifyEmail(context);
    WidgetsBinding.instance.addObserver(this);
    checkDuration();
    super.initState();
  }

  @override
  didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      verifyEmail();
    }
  }

  verifyEmail([bool? verified]) async {
    SharedPreferences sp = await SharedPreferences.getInstance();

    FirebaseAuth.instance.currentUser!.reload();
    if (FirebaseAuth.instance.currentUser!.emailVerified) {
      animationController.forward().then((v) async {
        await sp.remove('resendMailcounter');
        Navigator.pushNamedAndRemoveUntil(context, 'home', (r) => false);
      });
    } else if (verified ?? false) {
      util.doAlert(context, 'Your Email is not yet verified', 'info');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Email Verification',
          style: style.text.regularXLarge,
        ),
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
                      style: style.text.semiBoldMedium.copyWith(
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
                            child: Text(
                              'Email Verified!',
                              style: style.text.semiBold,
                            ),
                          ),
                          TextButton(
                            onPressed: !(isCountDown)
                                ? () {
                                    BlocProvider.of<AuthCubit>(context)
                                        .verifyEmail(context);
                                    setState(() {
                                      counterValue = 600;
                                      isCountDown = true;
                                    });
                                  }
                                : null,
                            style: TextButton.styleFrom(
                                foregroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer),
                            child: Text(
                              'Resent Verification mail',
                              style: style.text.semiBold,
                            ),
                          ),
                          if (isCountDown)
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Countdown(
                                seconds: counterValue,
                                controller: countdownController,
                                onFinished: () {
                                  setState(() {
                                    isCountDown = false;
                                  });
                                },
                                build: (context, value) {
                                  setCounterValue(value);
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "${value ~/ 60}m : ${(value % 60).toStringAsFixed(0).padLeft(2, '0')}s ",
                                        style: style.text.boldMedium
                                            .copyWith(color: AppColor.darkBlue),
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
                style: style.text.regular
                    .copyWith(color: Theme.of(context).colorScheme.tertiary),
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
