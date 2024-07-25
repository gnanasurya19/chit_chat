import 'package:chit_chat/utils/util.dart';
import 'package:firebase_auth/firebase_auth.dart';

Util util = Util();

FirebaseAuth firebaseAuth = FirebaseAuth.instance;
String get currentUserId => firebaseAuth.currentUser!.uid;
