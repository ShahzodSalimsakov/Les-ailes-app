import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:les_ailes/pages/aboutUs.dart';
import 'package:les_ailes/pages/delivery.dart';
import 'package:les_ailes/pages/notifications.dart';
import 'package:les_ailes/pages/pickup.dart';
import 'package:les_ailes/pages/settings.dart';
import 'package:les_ailes/pages/signIn.dart';
import '../message_handler.dart';
import '../models/yandex_geo_data.dart';
import '../pages/cashback_detail.dart';
import '../pages/changeLang.dart';
import '../pages/creditCard.dart';
import '../pages/creditCardList.dart';
import '../pages/creditCardOtp.dart';
import '../pages/franchise.dart';
import '../pages/my_addresses.dart';
import '../pages/my_orders.dart';
import '../pages/notifications_detail.dart';
import '../pages/order_detail.dart';
import '../pages/privacy.dart';
import '../pages/profile.dart';
import '../pages/terms.dart';
part 'router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(path: '/', page: MessageHandlerRoute.page),
        AutoRoute(path: '/signIn', page: SignInRoute.page),
        AutoRoute(
          path: '/settings',
          page: SettingsRoute.page,
        ),
        AutoRoute(path: '/about', page: AboutUsRoute.page),
        AutoRoute(
            path: '/notifications',
            children: [
              AutoRoute(
                path: '',
                page: NotificationsRoute.page,
              ),
              AutoRoute(
                path: ':id',
                page: NotificationDetailRoute.page,
              )
            ],
            page: NotificationsRoute.page),
        AutoRoute(path: '/changeLang', page: ChangeLangRoute.page),
        AutoRoute(path: '/privacy', page: PrivacyRoute.page),
        AutoRoute(path: '/terms', page: TermsRoute.page),
        AutoRoute(path: '/franchise', page: FranchiseRoute.page),
        AutoRoute(path: '/delivery', page: DeliveryRoute.page),
        AutoRoute(path: '/pickup', page: PickupRoute.page),
        AutoRoute(path: '/profile', page: ProfileRoute.page),
        AutoRoute(
          path: '/my_orders',
          page: MyOrdersRoute.page,
          children: [
            AutoRoute(path: 'my_orders/:orderId', page: OrderDetailRoute.page)
          ],
        ),
        AutoRoute(path: '/my_addresses', page: MyAddressesRoute.page),
        AutoRoute(path: '/cashback_detail', page: CashbackDetailRoute.page),
        AutoRoute(path: '/my_creditCard', page: CreditCardRoute.page),
        AutoRoute(path: '/my_creditCardList', page: CreditCardListRoute.page),
        AutoRoute(path: '/my_creditCardOtp', page: CreditCardOtpRoute.page),
      ];
}
