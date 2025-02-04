import 'package:auto_route/auto_route.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:les_ailes/routes/router.dart';
import './home_page.dart';

GetIt getIt = GetIt.instance;

@RoutePage()
class MessageHandlerPage extends StatefulWidget {
  const MessageHandlerPage({Key? key}) : super(key: key);

  @override
  State<MessageHandlerPage> createState() => MessageHandlerPageState();
}

class MessageHandlerPageState extends State<MessageHandlerPage> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  void checkNotificationRouter(RemoteMessage message) {
    try {
      // Validate message source
      if (!_isValidMessageSource(message)) {
        print('Warning: Message received from untrusted source');
        return;
      }

      String? route = message.data['route'];
      if (route != null) {
        // Validate route format
        if (!_isValidRouteFormat(route)) {
          print('Warning: Invalid route format: $route');
          return;
        }

        final List<String> allowedRoutes = [
          '/home',
          '/delivery',
          '/pickup',
          '/profile'
        ];

        if (allowedRoutes.contains(route)) {
          // Additional validation before navigation
          if (_isNavigationSafe(route)) {
            getIt<AppRouter>().pushNamed(route);
          } else {
            print('Warning: Navigation blocked due to security check');
          }
        } else {
          print('Warning: Invalid route received: $route');
        }
      }
    } catch (e) {
      print('Error in checkNotificationRouter: $e');
    }
  }

  bool _isValidMessageSource(RemoteMessage message) {
    // Validate message source (can be expanded based on your requirements)
    return message.from?.contains('firebase') ?? false;
  }

  bool _isValidRouteFormat(String route) {
    // Basic route format validation
    return route.startsWith('/') &&
        !route.contains('..') &&
        !route.contains('//');
  }

  bool _isNavigationSafe(String route) {
    // Add additional security checks if needed
    return true;
  }

  @override
  void initState() {
    super.initState();

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null && message.notification != null) {
        print("getInitialMessage");
        checkNotificationRouter(message);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage");
      // checkNotificationRouter(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (message != null && message.notification != null) {
        print("onMessageOpenedApp");
        checkNotificationRouter(message);
      }
    });

    // FirebaseMessaging.on
    // messaging.configure(
    //   onMessage: (Map<String, dynamic> message) async {
    //
    //   },
    //   onResume: (Map<String, dynamic> message) async {
    //     print("onMessage: ${message['data']['screen']}");
    //     String screen = message['data']['screen'];
    //     if (screen == "secondScreen") {
    //       Navigator.of(context).pushNamed("secondScreen");
    //     } else if (screen == "thirdScreen") {
    //       Navigator.of(context).pushNamed("thirdScreen");
    //     } else {
    //       //do nothing
    //     }
    //   },
    //   onLaunch: (Map<String, dynamic> message) async {
    //     print("onMessage: ${message['data']['screen']}");
    //     String screen = message['data']['screen'];
    //     if (screen == "secondScreen") {
    //       Navigator.of(context).pushNamed("secondScreen");
    //     } else if (screen == "thirdScreen") {
    //       Navigator.of(context).pushNamed("thirdScreen");
    //     } else {
    //       //do nothing
    //     }
    //   },
    // );
  }

  @override
  Widget build(BuildContext context) {
    return const HomePage();
  }
}
