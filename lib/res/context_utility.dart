import 'package:chit_chat/model/user_data.dart';
import 'package:chit_chat/view/screen/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:uni_links2/uni_links.dart';

class ContextUtility {
  static final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'ContextUtilityNavigatorKey');
  static GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  static bool get hasNavigator => navigatorKey.currentState != null;
  static NavigatorState? get navigator => navigatorKey.currentState;

  static bool get hasContext => navigator?.overlay?.context != null;
  static BuildContext? get context => navigator?.overlay?.context;
}

class UniLinksService {
  static String _chatRoom = '';
  static String get chatRoom => _chatRoom;
  static bool get haschatRoom => _chatRoom.isNotEmpty;

  static void reset() => _chatRoom = '';

  static Future<void> init({checkActualVersion = false}) async {
    // This is used for cases when: APP is not running and the user clicks on a link.
    try {
      final Uri? uri = await getInitialUri();
      _uniLinkHandler(uri: uri);
    } on PlatformException {
      if (kDebugMode) {
        print("(PlatformException) Failed to receive initial uri.");
      }
    } on FormatException catch (error) {
      if (kDebugMode) {
        print(
            "(FormatException) Malformed Initial URI received. Error: $error");
      }
    }

    // This is used for cases when: APP is already running and the user clicks on a link.
    uriLinkStream.listen((Uri? uri) async {
      _uniLinkHandler(uri: uri);
    }, onError: (error) {
      if (kDebugMode) print('UniLinks onUriLink error: $error');
    });
  }

  static Future<void> _uniLinkHandler({required Uri? uri}) async {
    if (uri == null || uri.queryParameters.isEmpty) return;
    Map<String, String> params = uri.queryParameters;

    String receivedPromoId = params['chatroom-id'] ?? '';
    if (receivedPromoId.isEmpty) return;
    _chatRoom = receivedPromoId;

    if (_chatRoom != '') {
      ContextUtility.navigator?.push(
        MaterialPageRoute(
          builder: (_) => ChatPage(
            userData: UserData(),
          ),
        ),
      );
    }
  }
}
