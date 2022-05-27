import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:les_ailes/models/basket_item_quantity.dart';
import 'package:les_ailes/models/pickup_type.dart';
import 'package:les_ailes/models/temp_terminals.dart';
import 'package:les_ailes/routes/router.gr.dart';
import 'package:les_ailes/utils/colors.dart';
import 'package:les_ailes/widgets/header.dart';
import 'package:les_ailes/widgets/leftMenu.dart';
import 'package:niku/niku.dart' as n;

import 'models/additional_phone_number.dart';
import 'models/basket.dart';
import 'models/city.dart';
import 'models/deliver_later_time.dart';
import 'models/delivery_location_data.dart';
import 'models/delivery_notes.dart';
import 'models/delivery_time.dart';
import 'models/delivery_type.dart';
import 'models/pay_cash.dart';
import 'models/pay_type.dart';
import 'models/registered_review.dart';
import 'models/stock.dart';
import 'models/terminals.dart';
import 'models/user.dart';

import './firebase_options.dart';

// void main() {
//   runApp(const MyApp());
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await EasyLocalization.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(CityAdapter());
  Hive.registerAdapter(BasketAdapter());
  Hive.registerAdapter(TerminalsAdapter());
  Hive.registerAdapter(TempTerminalsAdapter());
  Hive.registerAdapter(PickupTypeAdapter());
  Hive.registerAdapter(PickupTypeEnumAdapter());
  Hive.registerAdapter(DeliveryLocationDataAdapter());
  Hive.registerAdapter(DeliveryTypeAdapter());
  Hive.registerAdapter(DeliveryTypeEnumAdapter());
  Hive.registerAdapter(DeliveryTimeAdapter());
  Hive.registerAdapter(DeliveryTimeEnumAdapter());
  Hive.registerAdapter(DeliverLaterTimeAdapter());
  Hive.registerAdapter(PayTypeAdapter());
  Hive.registerAdapter(DeliveryNotesAdapter());
  Hive.registerAdapter(PayCashAdapter());
  Hive.registerAdapter(StockAdapter());
  Hive.registerAdapter(AdditionalPhoneNumberAdapter());
  Hive.registerAdapter(RegisteredReviewAdapter());
  Hive.registerAdapter(BasketItemQuantityAdapter());
  // Hive.registerAdapter(HomeIsScrolledAdapter());
  // Hive.registerAdapter(HomeScrollPositionAdapter());

  await Hive.openBox<User>('user');
  await Hive.openBox<City>('currentCity');
  await Hive.openBox<Basket>('basket');
  await Hive.openBox<Terminals>('currentTerminal');
  await Hive.openBox<TempTerminals>('tempTerminal');
  await Hive.openBox<PickupType>('pickupType');
  // await Hive.openBox<PickupTypeEnum>('picku');
  await Hive.openBox<DeliveryLocationData>('deliveryLocationData');
  await Hive.openBox<DeliveryType>('deliveryType');
  await Hive.openBox<DeliveryTime>('deliveryTime');
  await Hive.openBox<DeliverLaterTime>('deliveryLaterTime');
  await Hive.openBox<PayType>('payType');
  await Hive.openBox<DeliveryNotes>('deliveryNotes');
  await Hive.openBox<PayCash>('payCash');
  await Hive.openBox<Stock>('stock');
  await Hive.openBox<AdditionalPhoneNumber>('additionalPhoneNumber');
  await Hive.openBox<RegisteredReview>('registeredReview');
  await Hive.openBox<BasketItemQuantity>('basketItemQuantity');
  // await Hive.openBox<HomeIsScrolled>('homeIsScrolled');
  // await Hive.openBox<HomeScrollPosition>('homeScrollPosition');

  runApp(
    EasyLocalization(
      child: MyApp(),
      supportedLocales: const [Locale('en'), Locale('ru'), Locale('uz')],
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
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: AppColors.mainColor, // Color for Android
        statusBarBrightness:
            Brightness.light // Dark == white status bar -- for IOS.
        ));
    return MaterialApp.router(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      title: 'Les Ailes',
      theme: ThemeData(fontFamily: 'ProximaSoft'),
      routerDelegate: _appRouter.delegate(),
      routeInformationParser: _appRouter.defaultRouteParser(),
    );
  }
}
