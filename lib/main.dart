import 'dart:async';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:chit_chat/controller/update_cubit/update_cubit.dart';
import 'package:chit_chat/model/message_model.dart';
import 'package:chit_chat/res/download_upload_callback.dart';
import 'package:chit_chat/res/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chit_chat/controller/auth_cubit/auth_cubit.dart';
import 'package:chit_chat/controller/chat_cubit/chat_cubit.dart';
import 'package:chit_chat/controller/home_cubit/home_cubit.dart';
import 'package:chit_chat/controller/media_cubit/media_cubit.dart';
import 'package:chit_chat/controller/profile_cubit/profile_cubit.dart';
import 'package:chit_chat/controller/search_cubit/search_cubit.dart';
import 'package:chit_chat/firebase_options.dart';
import 'package:chit_chat/res/colors.dart';
import 'package:chit_chat/res/common_instants.dart';
import 'package:chit_chat/res/style.dart';
import 'package:workmanager/workmanager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(onBackgroundMsg);

  // Hive
  Hive.registerAdapter(MessageModelAdapter());
  Hive.init((await getDownloadsDirectory())?.path);
  hivebox = await Hive.openBox('pendingMessages');

  // background audio support
  // await JustAudioBackground.init(
  //   androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
  //   androidNotificationChannelName: 'Audio playback',
  //   androidNotificationOngoing: true,
  // );

  // background download support
  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);

  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );

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
      child: MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeChanger(
      builder: (context, myTheme) {
        return MaterialApp(
          title: 'ChitChat',
          navigatorKey: navigationKey,
          themeMode: ThemeMode.system,
          theme: myTheme,
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoute.initialRoute,
          routes: AppRoute.routes,
        );
      },
    );
  }
}

class ThemeChanger extends StatefulWidget {
  final Widget Function(BuildContext context, ThemeData myTheme) builder;
  const ThemeChanger({super.key, required this.builder});

  @override
  State<ThemeChanger> createState() => _ThemeChangerState();
}

class _ThemeChangerState extends State<ThemeChanger> {
  late Future<AppTheme> isDarkThemeFuture;
  ThemeData systemTheme = MyAppTheme.lightTheme;

  @override
  void initState() {
    super.initState();
    isDarkThemeFuture = fetchIsDarkTheme();
    checkSystemtheme();
  }

  Future<AppTheme> fetchIsDarkTheme() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    String theme = sp.getString('thememode') ?? 'light';
    switch (theme) {
      case 'dark':
        return AppTheme.dark;
      case 'light':
        return AppTheme.light;
      default:
        return AppTheme.system;
    }
  }

  checkSystemtheme() {
    var brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    if (brightness == Brightness.dark) {
      setState(() {
        systemTheme = MyAppTheme.darkTheme;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppTheme>(
      future: isDarkThemeFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final isDarkTheme = snapshot.data;
          return ThemeProvider(
            initTheme: isDarkTheme == AppTheme.dark
                ? MyAppTheme.darkTheme
                : isDarkTheme == AppTheme.light
                    ? MyAppTheme.lightTheme
                    : systemTheme,
            builder: (context, theme) {
              return widget.builder(context, theme);
            },
          );
        } else {
          return SizedBox();
        }
      },
    );
  }
}
