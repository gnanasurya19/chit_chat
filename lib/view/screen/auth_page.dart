import 'package:chit_chat/controller/update_cubit/update_cubit.dart';
import 'package:chit_chat/notification/notification_service.dart';
import 'package:chit_chat/view/screen/email_verification_page.dart';
import 'package:chit_chat/view/screen/home_page.dart';
import 'package:chit_chat/view/screen/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  late Widget loadWidget;
  @override
  void initState() {
    NotificationService().initialize();
    BlocProvider.of<UpdateCubit>(context).checkforUpdate('auto');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: Future.value(firebaseAuth.currentUser),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: SizedBox.expand(),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          final user = snapshot.data;
          if (user == null) {
            return const LoginPage();
          } else if (!user.emailVerified) {
            return const EmailVerificationPage();
          } else {
            return const HomePage();
          }
        } else {
          return const Scaffold(
            body: Center(child: Text('Unexpected state')),
          );
        }
      },
    );
  }
}
