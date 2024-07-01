import 'package:chit_chat/controller/auth_cubit/auth_cubit.dart';
import 'package:chit_chat/controller/chat_cubit/chat_cubit.dart';
import 'package:chit_chat/controller/home_cubit/home_cubit.dart';
import 'package:chit_chat/controller/search_cubit/search_cubit.dart';
import 'package:chit_chat/firebase_options.dart';
import 'package:chit_chat/notification/push_notification.dart';
import 'package:chit_chat/page_transition_animation.dart';
import 'package:chit_chat/res/colors.dart';
import 'package:chit_chat/view/screen/animation_practice.dart';
import 'package:chit_chat/view/screen/auth_page.dart';
import 'package:chit_chat/view/screen/home_page.dart';
import 'package:chit_chat/view/screen/login_page.dart';
import 'package:chit_chat/view/screen/profile_page.dart';
import 'package:chit_chat/view/screen/register_page.dart';
import 'package:chit_chat/view/screen/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  FlutterLocalNotificationsPlugin().show(
      1,
      message.data['title'],
      message.data['body'],
      NotificationDetails(
          iOS: const DarwinNotificationDetails(),
          android: AndroidNotificationDetails(
              groupKey: message.data['title'],
              actions: [
                const AndroidNotificationAction(
                  '0',
                  'Dismiss',
                  showsUserInterface: true,
                )
              ],
              message.messageId!,
              message.notification!.body!)));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await PuchNotification().initialize();
  runApp(const MainApp());
}

final navigationKey = GlobalKey<NavigatorState>();

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
  // ignore: library_private_types_in_public_api
  static _MainAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MainAppState>();
}

class _MainAppState extends State<MainApp> {
  ThemeMode _themeMode = ThemeMode.light;
  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

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
        )
      ],
      child: MaterialApp(
        navigatorKey: navigationKey,
        debugShowCheckedModeBanner: false,
        darkTheme: MyAppTheme.darkTheme.copyWith(
            pageTransitionsTheme: PageTransitionsTheme(builders: {
          TargetPlatform.android: OpacityPageTransition(),
          TargetPlatform.iOS: OpacityPageTransition(),
          TargetPlatform.windows: OpacityPageTransition(),
        })),
        theme: MyAppTheme.lightTheme.copyWith(
            pageTransitionsTheme: PageTransitionsTheme(builders: {
          TargetPlatform.android: OpacityPageTransition(),
          TargetPlatform.iOS: OpacityPageTransition(),
          TargetPlatform.windows: OpacityPageTransition(),
        })),
        themeMode: _themeMode,
        initialRoute: 'auth',
        routes: {
          "login": (context) => const LoginPage(),
          "auth": (context) => const AuthPage(),
          "register": (context) => const RegisterPage(),
          "home": (context) => const HomePage(),
          "profile": (context) => const Profile(),
          "splash-screen": (context) => const SplashScreen(),
          "animation": (context) => const AnimationPractice(),
        },
      ),
    );
  }
}
