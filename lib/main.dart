import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:les_ailes/routes/router.gr.dart';
import 'package:les_ailes/widgets/header.dart';
import 'package:les_ailes/widgets/leftMenu.dart';
import 'package:niku/niku.dart' as n;

import 'models/user.dart';

// void main() {
//   runApp(const MyApp());
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());

  await Hive.openBox<User>('user');

  runApp(
    EasyLocalization(
      child: MyApp(),
      supportedLocales: const [
        Locale('en'),
        Locale('ru'),
        Locale('uz')
      ],
      path: 'resources/langs',
      fallbackLocale: const Locale('ru'),
      startLocale: const Locale('ru'),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      title: 'Les Ailes',
      routerDelegate: _appRouter.delegate(),
      routeInformationParser: _appRouter.defaultRouteParser(),
    );
  }
}
