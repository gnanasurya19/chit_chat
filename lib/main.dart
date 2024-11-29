import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:chit_chat/controller/update_cubit/update_cubit.dart';
import 'package:chit_chat/view/screen/profile_edit_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chit_chat/controller/auth_cubit/auth_cubit.dart';
import 'package:chit_chat/controller/chat_cubit/chat_cubit.dart';
import 'package:chit_chat/controller/home_cubit/home_cubit.dart';
import 'package:chit_chat/controller/media_cubit/media_cubit.dart';
import 'package:chit_chat/controller/profile_cubit/profile_cubit.dart';
import 'package:chit_chat/controller/search_cubit/search_cubit.dart';
import 'package:chit_chat/firebase_options.dart';
import 'package:chit_chat/notification/notification_service.dart';
import 'package:chit_chat/res/colors.dart';
import 'package:chit_chat/res/common_instants.dart';
import 'package:chit_chat/res/style.dart';
import 'package:chit_chat/view/screen/auth_page.dart';
import 'package:chit_chat/view/screen/email_verification_page.dart';
import 'package:chit_chat/view/screen/home_page.dart';
import 'package:chit_chat/view/screen/login_page.dart';
import 'package:chit_chat/view/screen/profile_page.dart';
import 'package:chit_chat/view/screen/register_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().initialize();
  FirebaseMessaging.onBackgroundMessage(onBackgroundMsg);

  runApp(const MainApp());
}

final navigationKey = GlobalKey<NavigatorState>();

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  static AppStyle _style = AppStyle();
  static AppStyle get style => _style;

  @override
  Widget build(BuildContext context) {
    _style = AppStyle(screenSize: MediaQuery.sizeOf(context));
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit()),
        BlocProvider(create: (context) => ProfileCubit()),
        BlocProvider(create: (context) => HomeCubit()),
        BlocProvider(create: (context) => ChatCubit()),
        BlocProvider(create: (context) => MediaCubit()),
        BlocProvider(create: (context) => SearchCubit()),
        BlocProvider(create: (context) => UpdateCubit()),
      ],
      child: const ThemeChanger(),
    );
  }
}

class ThemeChanger extends StatefulWidget {
  const ThemeChanger({super.key});

  @override
  State<ThemeChanger> createState() => _ThemeChangerState();
}

class _ThemeChangerState extends State<ThemeChanger> {
  late Future<bool> isDarkThemeFuture;

  @override
  void initState() {
    super.initState();
    isDarkThemeFuture = fetchIsDarkTheme().then(
      (value) {
        return value;
      },
    );
  }

  Future<bool> fetchIsDarkTheme() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    String theme = sp.getString('thememode') ?? 'light';
    return theme == 'dark';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isDarkThemeFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final isDarkTheme = snapshot.data ?? false;
          return ThemeProvider(
            initTheme:
                isDarkTheme ? MyAppTheme.darkTheme : MyAppTheme.lightTheme,
            builder: (context, myTheme) {
              return MaterialApp(
                title: 'ChitChat',
                navigatorKey: navigationKey,
                theme: myTheme,
                debugShowCheckedModeBanner: false,
                initialRoute: 'auth',
                routes: {
                  "login": (context) => const LoginPage(),
                  "auth": (context) => const AuthPage(),
                  "register": (context) => const RegisterPage(),
                  "home": (context) => const HomePage(),
                  "email": (context) => const EmailVerificationPage(),
                  "profile": (context) => const ProfilePage(),
                  "profile-edit": (context) => const ProfileEditPage(),
                },
              );
            },
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
