import 'package:animations/animations.dart';
import 'package:chit_chat/controller/home_cubit/home_cubit.dart';
import 'package:chit_chat/model/user_data.dart';
import 'package:chit_chat/model/user_model.dart';
import 'package:chit_chat/view/screen/chat_page.dart';
import 'package:chit_chat/view/screen/home_page.dart';
import 'package:chit_chat/view/widget/user_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AnimationPractice extends StatelessWidget {
  const AnimationPractice({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: OpenContainer(
            transitionType: ContainerTransitionType.fade,
            transitionDuration: const Duration(milliseconds: 400),
            openBuilder: (context, action) => ChatPage(
                  userData: UserData(),
                ),
            closedBuilder: (context, action) => UserCard(
                user: UserData(
                  userName: 'Surya',
                  profileURL: null,
                ),
                onTap: (value) {})),
      ),
    );
  }
}
