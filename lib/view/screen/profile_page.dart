import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: const Text('Signout'),
          onPressed: () {
            Navigator.popAndPushNamed(context, 'login');
          },
        ),
      ),
    );
  }
}
