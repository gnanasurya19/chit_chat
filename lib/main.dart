import 'package:chit_chat/controller/auth_cubit/auth_cubit.dart';
import 'package:chit_chat/controller/home_cubit/home_cubit.dart';
import 'package:chit_chat/controller/chat_cubit/chat_cubit.dart';
import 'package:chit_chat/controller/media_cubit/media_cubit.dart';
import 'package:chit_chat/controller/search_cubit/search_cubit.dart';
import 'package:chit_chat/controller/theme_cubit/theme_cubit.dart';
import 'package:chit_chat/firebase_options.dart';
import 'package:chit_chat/notification/push_notification.dart';
import 'package:chit_chat/res/colors.dart';
import 'package:chit_chat/view/screen/auth_page.dart';
import 'package:chit_chat/view/screen/email_verification_page.dart';
import 'package:chit_chat/view/screen/home_page.dart';
import 'package:chit_chat/view/screen/login_page.dart';
import 'package:chit_chat/view/screen/profile_page.dart';
import 'package:chit_chat/view/screen/register_page.dart';
import 'package:chit_chat/view/screen/view_media.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await PuchNotification().initialize();
  runApp(const MainApp());
  FirebaseMessaging.onBackgroundMessage(onBackgroundMsg);
}

final navigationKey = GlobalKey<NavigatorState>();

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthCubit(),
        ),
        BlocProvider(
          create: (context) => HomeCubit(),
        ),
        BlocProvider(
          create: (context) => ChatCubit(),
        ),
        BlocProvider(
          create: (context) => SearchCubit(),
        ),
        BlocProvider(
          create: (context) => ThemeCubit(),
        ),
        BlocProvider(
          create: (context) => MediaCubit(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          if (state is ThemeInitial) {
            return MaterialApp(
              navigatorKey: navigationKey,
              debugShowCheckedModeBanner: false,
              darkTheme: MyAppTheme.darkTheme,
              theme: MyAppTheme.lightTheme,
              themeMode: state.themeMode,
              initialRoute: 'auth',
              routes: {
                "login": (context) => const LoginPage(),
                "auth": (context) => const AuthPage(),
                "register": (context) => const RegisterPage(),
                "home": (context) => const HomePage(),
                "profile": (context) => const Profile(),
                "view-image": (context) => const ViewMediaPage(),
                "email": (context) => const EmailVerificationPage(),
              },
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}
