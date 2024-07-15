import 'package:chit_chat/controller/auth_cubit/auth_cubit.dart';
import 'package:chit_chat/model/user_model.dart';
import 'package:chit_chat/res/custom_widget/animated_button.dart';
import 'package:chit_chat/res/custom_widget/text_field_animation.dart';
import 'package:chit_chat/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:chit_chat/res/colors.dart';
import 'package:chit_chat/res/fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isVisible = false;

  Util util = Util();

  @override
  void initState() {
    super.initState();
    BlocProvider.of<AuthCubit>(context).onInit();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = BlocProvider.of<AuthCubit>(context);
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: AnnotatedRegion(
          value: const SystemUiOverlayStyle(statusBarColor: AppColor.blue),
          child: SafeArea(
              child: SingleChildScrollView(
                  child: Container(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.9,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      Theme.of(context).colorScheme.onTertiary,
                                  boxShadow: [
                                    BoxShadow(
                                        blurRadius: 2,
                                        offset: const Offset(0, 0),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiaryContainer
                                            .withOpacity(0.2)),
                                  ]),
                              height: MediaQuery.of(context).size.height * 0.1,
                              padding: const EdgeInsets.all(10.0),
                              child: Lottie.asset(
                                'assets/lottie/message_lottie.json',
                                fit: BoxFit.contain,
                                repeat: false,
                              ),
                            ),
                            BlocConsumer<AuthCubit, AuthState>(
                              listenWhen: (previous, current) =>
                                  current is AuthActionState,
                              listener: (context, state) {
                                if (state is AuthToast) {
                                  util.showSnackbar(
                                      context, state.text, state.type);
                                } else if (state is AuthUserRegisterSuccess) {
                                  Navigator.pop(context);
                                  util.showSnackbar(
                                      context,
                                      'User Registered Successfully',
                                      'success');
                                  // util.doAlert(context,
                                  //     'Registered Successfully', 'network');
                                }
                              },
                              buildWhen: (previous, current) =>
                                  current is! AuthActionState,
                              builder: (context, state) {
                                if (state is AuthViewState) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Hey there, curious one!',
                                        textScaler: TextScaler.linear(
                                            ScaleSize.textScaleFactor(context)),
                                        style: const TextStyle(
                                            color: AppColor.white,
                                            fontSize: AppFontSize.lg,
                                            fontFamily: Roboto.bold),
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.5,
                                        child: Column(
                                          children: [
                                            TextFieldAnimation(
                                              color: AppColor.white,
                                              controller: nameController,
                                              text: 'Name',
                                            ),
                                            TextFieldAnimation(
                                              color: AppColor.white,
                                              controller: emailController,
                                              text: 'Email',
                                            ),
                                            // Container(
                                            //   padding:
                                            //       const EdgeInsets.symmetric(
                                            //           vertical: 10),
                                            //   alignment: Alignment.centerRight,
                                            //   child: InkWell(
                                            //     onTap: () {
                                            //       authController;
                                            //     },
                                            //     child: Text(
                                            //       (state.userModel.isVerified ??
                                            //               false)
                                            //           ? 'Verified'
                                            //           : 'Verify Email',
                                            //       style: const TextStyle(
                                            //           fontFamily: Roboto.medium,
                                            //           decoration: TextDecoration
                                            //               .underline,
                                            //           decorationColor:
                                            //               AppColor.white,
                                            //           fontSize: AppFontSize.xs,
                                            //           color: AppColor.white),
                                            //     ),
                                            //   ),
                                            // ),
                                            TextFieldAnimation(
                                              isPassWordVisible: isVisible,
                                              isPassword: true,
                                              onSufClick: () {
                                                setState(() {
                                                  isVisible = !isVisible;
                                                });
                                              },
                                              color: AppColor.white,
                                              controller: passwordController,
                                              text: 'password',
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        height: 60,
                                        alignment: Alignment.centerLeft,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.6,
                                        child: AnimatedButton(
                                          visible: true,
                                          isLogin: false,
                                          onClick: () {
                                            authController.dosignUP(UserModel(
                                              email: emailController.text,
                                              password: passwordController.text,
                                              name: nameController.text,
                                            ));
                                          },
                                        ),
                                      ),
                                      TextButton.icon(
                                          icon: const Icon(
                                            Icons.arrow_back,
                                            color: AppColor.white,
                                            size: 16,
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          label: Text(
                                            'Back',
                                            textScaler: TextScaler.linear(
                                                ScaleSize.textScaleFactor(
                                                    context)),
                                            style: const TextStyle(
                                                fontSize: AppFontSize.xs,
                                                color: AppColor.white,
                                                fontFamily: Roboto.medium),
                                          )),
                                    ],
                                  );
                                } else {
                                  return const SizedBox();
                                }
                              },
                            ),
                          ],
                        ),
                      )))),
        ));
  }
}
