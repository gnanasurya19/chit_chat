import 'package:chit_chat/controller/auth_cubit/auth_cubit.dart';
import 'package:chit_chat/model/user_model.dart';
import 'package:chit_chat/res/colors.dart';
import 'package:chit_chat/res/custom_widget/animated_button.dart';
import 'package:chit_chat/res/custom_widget/loading_widget.dart';
import 'package:chit_chat/res/custom_widget/text_field_animation.dart';
import 'package:chit_chat/res/fonts.dart';
import 'package:chit_chat/utils/util.dart';
import 'package:chit_chat/view/widget/animated_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rive/rive.dart';

import '../widget/forgot_password_dialog.dart';
import '../widget/logo.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //bear animation
  late StateMachineController bearAnimationController;
  late SMIInput<bool> isFocusEmail;
  late SMIInput<int> charLook;
  late SMIInput<bool> isFocusPassword;
  late SMIInput<bool> isSuccess;
  late SMIInput<bool> isFail;

  //textfields
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController forgotPasswordController = TextEditingController();
  final FocusNode emailfocus = FocusNode();
  final FocusNode passwordfocus = FocusNode();
  bool isPasswordVisible = false;
  double buttonPosition = 0;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<AuthCubit>(context).onInit();
    emailfocus.addListener(emailfocusListener);
    passwordfocus.addListener(passwordfocusListener);
  }

  void emailfocusListener() {
    isFocusEmail.change(emailfocus.hasFocus);
  }

  void passwordfocusListener() {
    isFocusPassword.change(passwordfocus.hasFocus && !isPasswordVisible);
  }

  Util util = Util();

  forgotPassword() {
    util.slideInDialog(
        context,
        ForgotPasswordDialog(
          emailController: forgotPasswordController,
        ));
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    forgotPasswordController.dispose();
    bearAnimationController.dispose();
    emailfocus.removeListener(emailfocusListener);
    passwordfocus.removeListener(passwordfocusListener);
  }

  @override
  Widget build(BuildContext context) {
    final authCotroller = BlocProvider.of<AuthCubit>(context);
    return PopScope(
      canPop: false,
      child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: AnnotatedRegion(
            value: SystemUiOverlayStyle(
                statusBarColor:
                    Theme.of(context).colorScheme.surface.withOpacity(0.5)),
            child: SafeArea(
                child: SingleChildScrollView(
                    child: Container(
                        padding: const EdgeInsets.all(20),
                        child: BlocConsumer<AuthCubit, AuthState>(
                          listenWhen: (previous, current) =>
                              current is AuthActionState,
                          listener: (context, state) {
                            if (state is AuthToast) {
                              util.showSnackbar(
                                  context, state.text, state.type);
                              setState(() {
                                isFail.change(true);
                              });
                            } else if (state is AuthAlert) {
                              util.doAlert(context, state.text, state.type);
                            } else if (state is AuthUserNotFound) {
                              userNotFound();
                            } else if (state is AuthPasswordResetMailSent) {
                              Navigator.pop(context);
                              resetMailsent(context);
                            } else if (state is AuthUserLoginSuccess) {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                'home',
                                (route) => false,
                              );
                            } else if (state is AuthLoading) {
                              showDialog(
                                context: context,
                                builder: (context) => const LoadingScreen(),
                              );
                            } else if (state is AuthCancelLoading) {
                              Navigator.pop(context);
                            }
                          },
                          buildWhen: (previous, current) =>
                              current is! AuthActionState,
                          builder: (context, state) {
                            if (state is AuthViewState) {
                              return SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.9,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Logo(),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.2,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.2,
                                          child: RiveAnimation.asset(
                                              "assets/rivfiles/animated_bear.riv",
                                              fit: BoxFit.fitHeight,
                                              stateMachines: const [
                                                "Login Machine"
                                              ], onInit: (Artboard artboard) {
                                            bearAnimationController =
                                                StateMachineController
                                                    .fromArtboard(artboard,
                                                        'Login Machine')!;
                                            artboard.addController(
                                                bearAnimationController);
                                            isFocusEmail =
                                                bearAnimationController
                                                    .findInput('isChecking')!;
                                            isFocusPassword =
                                                bearAnimationController
                                                    .findInput('isHandsUp')!;
                                            isSuccess = bearAnimationController
                                                .findInput('trigSuccess')!;
                                            isFail = bearAnimationController
                                                .findInput('trigFail')!;
                                          }),
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        Text(
                                          'Connect with your loved ones',
                                          textScaler: TextScaler.linear(
                                              ScaleSize.textScaleFactor(
                                                  context)),
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .tertiary,
                                              fontSize: AppFontSize.sm),
                                        ),
                                        Text(
                                          'Let\'s Talk',
                                          textScaler: TextScaler.linear(
                                              ScaleSize.textScaleFactor(
                                                  context)),
                                          style: TextStyle(
                                            fontFamily: Roboto.bold,
                                            fontSize: 40,
                                            height: 1,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        AnimateHeight(
                                          isOpen: state.status ==
                                                  PageStatus.notSignedIn
                                              ? false
                                              : true,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.25,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (state.status ==
                                                  PageStatus.signIn) ...[
                                                TextFieldAnimation(
                                                    focus: emailfocus,
                                                    controller: emailController,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .tertiaryContainer,
                                                    text: 'Email'),
                                                TextFieldAnimation(
                                                    focus: passwordfocus,
                                                    controller:
                                                        passwordController,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .tertiaryContainer,
                                                    isPassWordVisible:
                                                        isPasswordVisible,
                                                    onSufClick: () {
                                                      setState(() {
                                                        isPasswordVisible =
                                                            !isPasswordVisible;
                                                      });
                                                      passwordfocusListener();
                                                    },
                                                    isPassword: true,
                                                    text: 'Password'),
                                              ]
                                            ],
                                          ),
                                        ),
                                        Stack(
                                          clipBehavior: Clip.none,
                                          alignment: Alignment.centerLeft,
                                          children: [
                                            const SizedBox(
                                              width: double.infinity,
                                              height: 60,
                                            ),
                                            AnimatedButton(
                                              isLogin: true,
                                              visible: state.status ==
                                                      PageStatus.notSignedIn
                                                  ? true
                                                  : false,
                                              onClick: () {
                                                if (state.status ==
                                                    PageStatus.notSignedIn) {
                                                  Navigator.pushNamed(
                                                      context, 'register');
                                                }
                                              },
                                              onInit: (value) {
                                                setState(() {
                                                  buttonPosition = value + 20;
                                                });
                                              },
                                            ),
                                            Positioned(
                                              right: 0,
                                              child: AnimatedOpacity(
                                                duration: const Duration(
                                                    milliseconds: 600),
                                                opacity: state.status ==
                                                        PageStatus.signIn
                                                    ? 1
                                                    : 0,
                                                child: TextButton(
                                                  style: ButtonStyle(
                                                      surfaceTintColor:
                                                          const WidgetStatePropertyAll(
                                                              AppColor.blue),
                                                      foregroundColor:
                                                          WidgetStatePropertyAll(
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .tertiaryContainer,
                                                      )),
                                                  onPressed: state.status ==
                                                          PageStatus.signIn
                                                      ? () {
                                                          forgotPassword();
                                                        }
                                                      : null,
                                                  child: Text(
                                                    'Forgot password?',
                                                    textScaler: TextScaler
                                                        .linear(ScaleSize
                                                            .textScaleFactor(
                                                                context)),
                                                    style: const TextStyle(
                                                        fontSize:
                                                            AppFontSize.xs,
                                                        fontFamily:
                                                            Roboto.medium),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            AnimatedPositioned(
                                              duration: const Duration(
                                                  milliseconds: 400),
                                              left: state.status ==
                                                      PageStatus.signIn
                                                  ? 0
                                                  : buttonPosition,
                                              child: Column(
                                                children: [
                                                  ElevatedButton(
                                                    style: ButtonStyle(
                                                        overlayColor:
                                                            WidgetStatePropertyAll(
                                                                AppColor.black
                                                                    .withOpacity(
                                                                        0.05)),
                                                        foregroundColor:
                                                            const WidgetStatePropertyAll(
                                                                AppColor.black),
                                                        side: const WidgetStatePropertyAll(
                                                            BorderSide(
                                                                color: AppColor
                                                                    .greyText)),
                                                        padding: const WidgetStatePropertyAll(
                                                            EdgeInsets.all(15)),
                                                        elevation:
                                                            const WidgetStatePropertyAll(
                                                                0),
                                                        backgroundColor:
                                                            const WidgetStatePropertyAll(AppColor.white)),
                                                    onPressed: () {
                                                      FocusManager.instance.primaryFocus?.unfocus();
                                                        authCotroller.doSignIn(
                                                            state.status,
                                                            UserModel(
                                                                email:
                                                                    emailController
                                                                        .text,
                                                                password:
                                                                    passwordController
                                                                        .text));

                                                    },
                                                    child: Text(
                                                      "SIGN IN",
                                                      textScaler: TextScaler
                                                          .linear(ScaleSize
                                                              .textScaleFactor(
                                                                  context)),
                                                      style: const TextStyle(
                                                          fontSize:
                                                              AppFontSize.xs,
                                                          fontFamily:
                                                              Roboto.bold),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        AnimatedOpacity(
                                          duration:
                                              const Duration(milliseconds: 400),
                                          opacity:
                                              state.status == PageStatus.signIn
                                                  ? 1
                                                  : 0,
                                          child: TextButton(
                                              onPressed: () {
                                                authCotroller.goBack();
                                                emailController.clear();
                                                passwordController.clear();
                                                isPasswordVisible = false;
                                                isFocusPassword.change(false);
                                                isFocusEmail.change(false);
                                              },
                                              child: Text(
                                                'GO BACK',
                                                textScaler: TextScaler.linear(
                                                    ScaleSize.textScaleFactor(
                                                        context)),
                                                style: TextStyle(
                                                    fontSize: AppFontSize.xxs,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .tertiaryContainer,
                                                    fontFamily: Roboto.medium),
                                              )),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return Container();
                            }
                          },
                        )))),
          )),
    );
  }

  userNotFound() {
    Navigator.of(context).push(PageRouteBuilder(
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, -0.1);
          const end = Offset.zero;
          var curve = Curves.ease;
          final tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          final offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        opaque: false,
        barrierDismissible: true,
        pageBuilder: (BuildContext context, _, __) {
          return Dialog(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              alignment: Alignment.center,
              shadowColor: AppColor.black,
              surfaceTintColor: AppColor.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 20.0, horizontal: 35),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'User not found',
                          style: TextStyle(
                              color: AppColor.blue,
                              fontFamily: Roboto.bold,
                              fontSize: 20),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'The email you entered is not linked with any account.Please check your email or sign up',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppColor.greyText,
                              fontSize: 14,
                              height: 1.7),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                        border:
                            Border(top: BorderSide(color: AppColor.greyline))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              child: const Text(
                                'Try Again',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.popAndPushNamed(context, 'register');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              child: const Text(
                                'Sign Up',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ));
        }));
  }

  resetMailsent(BuildContext context) {
    util.slideInDialog(
        context,
        Dialog(
          backgroundColor: Theme.of(context).colorScheme.onTertiary,
          shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          surfaceTintColor: AppColor.white,
          child: const Padding(
            padding: EdgeInsets.all(15.0),
            child: Text('Reset password email sent!.Please check your email'),
          ),
        ));
  }
}
