import 'package:chit_chat/controller/auth_cubit/auth_cubit.dart';
import 'package:chit_chat/model/user_data.dart';
import 'package:chit_chat/res/colors.dart';
import 'package:chit_chat/res/common_instants.dart';
import 'package:chit_chat/res/custom_widget/animated_button.dart';
import 'package:chit_chat/res/custom_widget/text_field_animation.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    BlocProvider.of<AuthCubit>(context).onInit();
    authController = BlocProvider.of<AuthCubit>(context);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  late final AuthCubit authController;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: AnnotatedRegion(
        value: SystemUiOverlayStyle(
            statusBarColor: Theme.of(context).colorScheme.primary),
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
                          color: Theme.of(context).colorScheme.onTertiary,
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 2,
                                offset: const Offset(0, 0),
                                color: Theme.of(context)
                                    .colorScheme
                                    .tertiaryContainer
                                    .withValues(alpha: 0.2)),
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
                          util.showSnackbar(context, state.text, state.type);
                        } else if (state is AuthUserRegisterSuccess) {
                          Navigator.popUntil(
                            context,
                            (r) {
                              return r.settings.name == 'auth';
                            },
                          );
                          util.showSnackbar(context,
                              'User Registered Successfully', 'success');
                        }
                      },
                      buildWhen: (previous, current) =>
                          current is! AuthActionState,
                      builder: (context, state) {
                        if (state is AuthViewState) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hey there, curious one!',
                                style: style.text.boldLarge.copyWith(
                                  color: AppColor.white,
                                ),
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
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
                                      issignUpEmail: true,
                                      text: 'Email',
                                    ),
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
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: AnimatedButton(
                                  visible: true,
                                  isLogin: false,
                                  onClick: () {
                                    authController.dosignUP(
                                      UserData(
                                        userEmail: emailController.text,
                                        password: passwordController.text,
                                        userName: nameController.text,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              TextButton.icon(
                                icon: Icon(
                                  Icons.arrow_back,
                                  color: AppColor.white,
                                  size: style.icon.xs,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                label: Text(
                                  'Back',
                                  style: style.text.semiBold.copyWith(
                                    color: AppColor.white,
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else {
                          return const SizedBox();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
