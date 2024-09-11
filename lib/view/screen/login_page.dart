import 'package:chit_chat_1/controller/auth_cubit/auth_cubit.dart';
import 'package:chit_chat_1/model/user_data.dart';
import 'package:chit_chat_1/res/colors.dart';
import 'package:chit_chat_1/res/common_instants.dart';
import 'package:chit_chat_1/res/custom_widget/animated_button.dart';
import 'package:chit_chat_1/res/custom_widget/loading_widget.dart';
import 'package:chit_chat_1/res/custom_widget/text_field_animation.dart';
import 'package:chit_chat_1/view/screen/register_page.dart';
import 'package:chit_chat_1/view/widget/animated_widget.dart';
import 'package:chit_chat_1/view/widget/forgot_password_dialog.dart';
import 'package:chit_chat_1/view/widget/logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
// import 'package:rive/rive.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //textfields
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController forgotPasswordController = TextEditingController();
  final FocusNode emailfocus = FocusNode();
  final FocusNode passwordfocus = FocusNode();
  bool isPasswordVisible = false;
  double buttonPosition = 0;
  late final AuthCubit authCotroller;

  @override
  void initState() {
    super.initState();
    // BlocProvider.of<AuthCubit>(context).onInit();
    authCotroller = BlocProvider.of<AuthCubit>(context);
  }

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
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        authCotroller.goBack();
      },
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
                  listenWhen: (previous, current) => current is AuthActionState,
                  listener: (context, state) {
                    _listener(state, context);
                  },
                  buildWhen: (previous, current) => current is! AuthActionState,
                  builder: (context, state) {
                    if (state is AuthViewState) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.9,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Logo(),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //Rive animation
                                Text(
                                  'Connect with your loved ones',
                                  style: style.text.regularSmall.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                                ),
                                Text(
                                  'Let\'s Talk',
                                  style: style.text.loginTitle.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      height: 1),
                                ),
                                const Gap(10),
                                AnimateHeight(
                                  isOpen: state.status == PageStatus.notSignedIn
                                      ? false
                                      : true,
                                  height:
                                      MediaQuery.of(context).size.height * 0.25,
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
                                            controller: passwordController,
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
                                      visible:
                                          state.status == PageStatus.notSignedIn
                                              ? true
                                              : false,
                                      onClick: () {
                                        emailController.clear();
                                        passwordController.clear();
                                        if (state.status ==
                                            PageStatus.notSignedIn) {
                                          Navigator.push(
                                              context,
                                              util.pageTransition(
                                                  const RegisterPage()));
                                        }
                                      },
                                      onInit: (value) {
                                        setState(() {
                                          buttonPosition = value + 20;
                                        });
                                      },
                                    ),
                                    ForgotPWBtn(
                                      ontap: () {
                                        forgotPassword();
                                      },
                                      state: state,
                                    ),
                                    SignInBtn(
                                      state: state,
                                      buttonPosition: buttonPosition,
                                      authCotroller: authCotroller,
                                      emailController: emailController,
                                      passwordController: passwordController,
                                    ),
                                  ],
                                ),
                                GoBackBtn(
                                  state: state,
                                  onTap: () {
                                    authCotroller.goBack();
                                  },
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
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _listener(AuthState state, BuildContext context) {
    if (state is AuthToast) {
      util.showSnackbar(context, state.text, state.type);
    } else if (state is AuthAlert) {
      util.doAlert(context, state.text, state.type);
    } else if (state is AuthUserNotFound) {
      userNotFound();
    } else if (state is AuthPasswordResetMailSent) {
      Navigator.pop(context);
      resetMailsent(context);
    } else if (state is AuthUserLoginSuccess) {
      Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
    } else if (state is AuthLoading) {
      showDialog(
        context: context,
        builder: (context) => const LoadingScreen(),
      );
    } else if (state is AuthCancelLoading) {
      Navigator.pop(context);
    } else if (state is AuthVerifyUserEmail) {
      emailController.clear();
      passwordController.clear();
      Navigator.pushNamedAndRemoveUntil(context, 'email', (route) => false);
    }
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
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 35),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'User not found',
                          style: style.text.boldLarge.copyWith(
                            color: AppColor.blue,
                          ),
                        ),
                        const Gap(10),
                        Text(
                          'The email you entered is not linked with any account.Please check your email or sign up',
                          textAlign: TextAlign.center,
                          style: style.text.regular
                              .copyWith(color: AppColor.greyText, height: 1.7),
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
                              child: Text(
                                'Sign Up',
                                textAlign: TextAlign.center,
                                style: style.text.regular,
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

class GoBackBtn extends StatelessWidget {
  const GoBackBtn({
    super.key,
    required this.state,
    required this.onTap,
  });
  final AuthViewState state;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: state.status == PageStatus.signIn ? 1 : 0,
      child: TextButton(
        onPressed: onTap,
        child: Text('GO BACK',
            style: style.text.regularSmall.copyWith(
              color: Theme.of(context).colorScheme.tertiaryContainer,
            )),
      ),
    );
  }
}

class SignInBtn extends StatelessWidget {
  const SignInBtn({
    super.key,
    required this.buttonPosition,
    required this.authCotroller,
    required this.emailController,
    required this.passwordController,
    required this.state,
  });

  final double buttonPosition;
  final AuthCubit authCotroller;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final AuthViewState state;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      left: state.status == PageStatus.signIn ? 0 : buttonPosition,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            overlayColor: AppColor.black.withOpacity(0.05),
            foregroundColor: AppColor.black,
            side: const BorderSide(color: AppColor.greyText),
            padding: const EdgeInsets.all(15),
            elevation: 0,
            backgroundColor: AppColor.white),
        onPressed: () {
          FocusManager.instance.primaryFocus?.unfocus();
          authCotroller.doSignIn(
            state.status,
            UserData(
              userEmail: emailController.text,
              password: passwordController.text,
            ),
          );
        },
        child: Text(
          "SIGN IN",
          style: style.text.bold,
        ),
      ),
    );
  }
}

class ForgotPWBtn extends StatelessWidget {
  final Function() ontap;
  final AuthViewState state;
  const ForgotPWBtn({
    super.key,
    required this.ontap,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 600),
        opacity: state.status == PageStatus.signIn ? 1 : 0,
        child: TextButton(
          style: ButtonStyle(
              surfaceTintColor: const WidgetStatePropertyAll(AppColor.blue),
              foregroundColor: WidgetStatePropertyAll(
                Theme.of(context).colorScheme.tertiaryContainer,
              )),
          onPressed: state.status == PageStatus.signIn ? ontap : null,
          child: Text(
            'Forgot password?',
            style: style.text.semiBold,
          ),
        ),
      ),
    );
  }
}
