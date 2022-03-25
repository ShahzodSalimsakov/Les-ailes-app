import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:les_ailes/routes/router.gr.dart';
import 'package:les_ailes/widgets/header.dart';
import 'package:les_ailes/widgets/leftMenu.dart';
import 'package:niku/niku.dart' as n;

import 'models/city.dart';
import 'models/delivery_location_data.dart';
import 'models/delivery_type.dart';
import 'models/stock.dart';
import 'models/terminals.dart';
import 'models/user.dart';

// void main() {
//   runApp(const MyApp());
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(CityAdapter());
  // Hive.registerAdapter(BasketAdapter());
  Hive.registerAdapter(TerminalsAdapter());
  Hive.registerAdapter(DeliveryLocationDataAdapter());
  Hive.registerAdapter(DeliveryTypeAdapter());
  Hive.registerAdapter(DeliveryTypeEnumAdapter());
  // Hive.registerAdapter(DeliveryTimeAdapter());
  // Hive.registerAdapter(DeliveryTimeEnumAdapter());
  // Hive.registerAdapter(DeliverLaterTimeAdapter());
  // Hive.registerAdapter(PayTypeAdapter());
  // Hive.registerAdapter(DeliveryNotesAdapter());
  // Hive.registerAdapter(PayCashAdapter());
  Hive.registerAdapter(StockAdapter());
  // Hive.registerAdapter(AdditionalPhoneNumberAdapter());
  // Hive.registerAdapter(HomeIsScrolledAdapter());
  // Hive.registerAdapter(HomeScrollPositionAdapter());

  await Hive.openBox<User>('user');  await Hive.openBox<City>('currentCity');
  // await Hive.openBox<Basket>('basket');
  await Hive.openBox<Terminals>('currentTerminal');
  await Hive.openBox<DeliveryLocationData>('deliveryLocationData');
  await Hive.openBox<DeliveryType>('deliveryType');
  // await Hive.openBox<DeliveryTime>('deliveryTime');
  // await Hive.openBox<DeliverLaterTime>('deliveryLaterTime');
  // await Hive.openBox<PayType>('payType');
  // await Hive.openBox<DeliveryNotes>('deliveryNotes');
  // await Hive.openBox<PayCash>('payCash');
  await Hive.openBox<Stock>('stock');
  // await Hive.openBox<AdditionalPhoneNumber>('additionalPhoneNumber');
  // await Hive.openBox<HomeIsScrolled>('homeIsScrolled');
  // await Hive.openBox<HomeScrollPosition>('homeScrollPosition');

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
