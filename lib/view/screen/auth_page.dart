import 'package:chit_chat/view/screen/home_page.dart';
import 'package:chit_chat/view/screen/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (firebaseAuth.currentUser == null) {
      loadWidget = const LoginPage();
    } else {
      loadWidget = const HomePage();
    }
    return loadWidget;
  }
}
