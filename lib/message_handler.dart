import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:les_ailes/routes/router.gr.dart';
import './home_page.dart';

GetIt getIt = GetIt.instance;
class MessageHandler extends StatefulWidget {
  const MessageHandler({Key? key}) : super(key: key);

  @override
  State<MessageHandler> createState() => MessageHandlerState();
}

class MessageHandlerState extends State<MessageHandler> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  void checkNotificationRouter(RemoteMessage message) {
    print("onMessage: ${message.data['screen']}");
    String? route = message.data['route'];
    if (route != null) {
      getIt<AppRouter>().pushNamed(route);
    }
    // if (screen == "secondScreen") {
    //   Navigator.of(context).pushNamed("secondScreen");
    // } else if (screen == "thirdScreen") {
    //   Navigator.of(context).pushNamed("thirdScreen");
    // } else {
    //   //do nothing
    // }
  }

  @override
  void initState() {
    super.initState();

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null && message.notification != null) {
        checkNotificationRouter(message);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      checkNotificationRouter(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (message != null && message.notification != null) {
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