import 'package:auto_route/auto_route.dart';
import 'package:les_ailes/pages/aboutUs.dart';
import 'package:les_ailes/pages/cashback_detail.dart';
import 'package:les_ailes/pages/changeLang.dart';
import 'package:les_ailes/pages/delivery.dart';
import 'package:les_ailes/pages/franchise.dart';
import 'package:les_ailes/pages/my_addresses.dart';
import 'package:les_ailes/pages/my_orders.dart';
import 'package:les_ailes/pages/notifications.dart';
import 'package:les_ailes/pages/order_detail.dart';
import 'package:les_ailes/pages/pickup.dart';
import 'package:les_ailes/pages/privacy.dart';
import 'package:les_ailes/pages/settings.dart';
import 'package:les_ailes/pages/signIn.dart';
import 'package:les_ailes/pages/terms.dart';

import '../message_handler.dart';
import '../pages/notifications_detail.dart';
import '../pages/profile.dart';

@MaterialAutoRouter(replaceInRouteName: 'Page,Route', routes: [
  AutoRoute(path: '/', name: 'Home', page: MessageHandler),
  AutoRoute(path: 'signIn', name: 'SignInPage', page: SignInPage),
  AutoRoute(
    path: 'settings',
    name: 'SettingsPage',
    page: SettingsPage,
  ),
  AutoRoute(path: 'about', name: 'AboutUsPage', page: AboutUsPage),
  AutoRoute(
      path: 'notifications',
      name: 'NotificationsPage',
      page: EmptyRouterPage,
      children: [
        AutoRoute(
          path: '',
          page: NotificationsPage,
        ),
        AutoRoute(
          path: ':id',
          page: NotificationDetailPage,
        )
      ]),
  AutoRoute(path: 'changeLang', name: 'changeLang', page: ChangeLang),
  AutoRoute(path: 'privacy', name: 'PrivacyPolicy', page: Privacy),
  AutoRoute(path: 'terms', name: 'Termsofuse', page: Terms),
  AutoRoute(path: 'franchise', name: 'Franchise', page: Franchise),
  AutoRoute(path: 'delivery', name: 'Delivery', page: DeliveryPage),
  AutoRoute(path: 'pickup', name: 'Pickup', page: PickupPage),
  AutoRoute(path: 'profile', name: 'Profile', page: ProfilePage),
  AutoRoute(
      path: 'my_orders',
      name: 'Myorders',
      page: EmptyRouterPage,
      children: [
        AutoRoute(path: '', page: MyOrders),
        AutoRoute(path: ':orderId', page: OrderDetail)
      ]),
  AutoRoute(path: 'my_addresses', name: 'MyAddresses', page: MyAddresses),
  AutoRoute(
      path: 'cashback_detail', name: 'CashbackDetail', page: CashbackDetail)
])
class $AppRouter {}
