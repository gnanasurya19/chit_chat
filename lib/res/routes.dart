import 'package:chit_chat/view/practice/practice_page.dart';
import 'package:chit_chat/view/screen/auth_page.dart';
import 'package:chit_chat/view/screen/email_verification_page.dart';
import 'package:chit_chat/view/screen/home_page.dart';
import 'package:chit_chat/view/screen/login_page.dart';
import 'package:chit_chat/view/screen/profile_edit_page.dart';
import 'package:chit_chat/view/screen/profile_page.dart';
import 'package:chit_chat/view/screen/register_page.dart';
import 'package:chit_chat/view/screen/share_page.dart';

class AppRoute {
  static const initialRoute = 'auth';

  static final routes = {
    "login": (context) => const LoginPage(),
    "auth": (context) => const AuthPage(),
    "register": (context) => const RegisterPage(),
    "home": (context) => const HomePage(),
    "email": (context) => const EmailVerificationPage(),
    "profile": (context) => const ProfilePage(),
    "profile-edit": (context) => const ProfileEditPage(),
    "share": (context) => SharePage(),
    'practice': (context) => PracticePage(),
  };
}
