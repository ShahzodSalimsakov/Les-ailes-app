// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************
//
// ignore_for_file: type=lint

import 'package:auto_route/auto_route.dart' as _i5;
import 'package:flutter/material.dart' as _i19;

import '../message_handler.dart' as _i1;
import '../models/yandex_geo_data.dart' as _i20;
import '../pages/aboutUs.dart' as _i4;
import '../pages/cashback_detail.dart' as _i14;
import '../pages/changeLang.dart' as _i6;
import '../pages/delivery.dart' as _i10;
import '../pages/franchise.dart' as _i9;
import '../pages/my_addresses.dart' as _i13;
import '../pages/my_orders.dart' as _i17;
import '../pages/notifications.dart' as _i15;
import '../pages/notifications_detail.dart' as _i16;
import '../pages/order_detail.dart' as _i18;
import '../pages/pickup.dart' as _i11;
import '../pages/privacy.dart' as _i7;
import '../pages/profile.dart' as _i12;
import '../pages/settings.dart' as _i3;
import '../pages/signIn.dart' as _i2;
import '../pages/terms.dart' as _i8;

class AppRouter extends _i5.RootStackRouter {
  AppRouter([_i19.GlobalKey<_i19.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i5.PageFactory> pagesMap = {
    Home.name: (routeData) {
      return _i5.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i1.MessageHandler());
    },
    SignInPage.name: (routeData) {
      final args = routeData.argsAs<SignInPageArgs>(
          orElse: () => const SignInPageArgs());
      return _i5.MaterialPageX<dynamic>(
          routeData: routeData, child: _i2.SignInPage(key: args.key));
    },
    SettingsPage.name: (routeData) {
      return _i5.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i3.SettingsPage());
    },
    AboutUsPage.name: (routeData) {
      return _i5.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i4.AboutUsPage());
    },
    NotificationsPage.name: (routeData) {
      return _i5.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i5.EmptyRouterPage());
    },
    ChangeLang.name: (routeData) {
      final args = routeData.argsAs<ChangeLangArgs>(
          orElse: () => const ChangeLangArgs());
      return _i5.MaterialPageX<dynamic>(
          routeData: routeData, child: _i6.ChangeLang(key: args.key));
    },
    PrivacyPolicy.name: (routeData) {
      return _i5.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i7.Privacy());
    },
    Termsofuse.name: (routeData) {
      return _i5.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i8.Terms());
    },
    Franchise.name: (routeData) {
      return _i5.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i9.Franchise());
    },
    Delivery.name: (routeData) {
      final args =
          routeData.argsAs<DeliveryArgs>(orElse: () => const DeliveryArgs());
      return _i5.MaterialPageX<dynamic>(
          routeData: routeData,
          child: _i10.DeliveryPage(key: args.key, geoData: args.geoData));
    },
    Pickup.name: (routeData) {
      return _i5.MaterialPageX<dynamic>(
          routeData: routeData, child: _i11.PickupPage());
    },
    Profile.name: (routeData) {
      return _i5.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i12.ProfilePage());
    },
    Myorders.name: (routeData) {
      return _i5.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i5.EmptyRouterPage());
    },
    MyAddresses.name: (routeData) {
      return _i5.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i13.MyAddresses());
    },
    CashbackDetail.name: (routeData) {
      return _i5.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i14.CashbackDetail());
    },
    NotificationsRoute.name: (routeData) {
      return _i5.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i15.NotificationsPage());
    },
    NotificationDetailRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<NotificationDetailRouteArgs>(
          orElse: () =>
              NotificationDetailRouteArgs(id: pathParams.getString('id')));
      return _i5.MaterialPageX<dynamic>(
          routeData: routeData,
          child: _i16.NotificationDetailPage(
              key: args.key, id: args.id, notification: args.notification));
    },
    MyOrders.name: (routeData) {
      return _i5.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i17.MyOrders());
    },
    OrderDetail.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<OrderDetailArgs>(
          orElse: () =>
              OrderDetailArgs(orderId: pathParams.getString('orderId')));
      return _i5.MaterialPageX<dynamic>(
          routeData: routeData,
          child: _i18.OrderDetail(key: args.key, orderId: args.orderId));
    }
  };

  @override
  List<_i5.RouteConfig> get routes => [
        _i5.RouteConfig(Home.name, path: '/'),
        _i5.RouteConfig(SignInPage.name, path: 'signIn'),
        _i5.RouteConfig(SettingsPage.name, path: 'settings'),
        _i5.RouteConfig(AboutUsPage.name, path: 'about'),
        _i5.RouteConfig(NotificationsPage.name,
            path: 'notifications',
            children: [
              _i5.RouteConfig(NotificationsRoute.name,
                  path: '', parent: NotificationsPage.name),
              _i5.RouteConfig(NotificationDetailRoute.name,
                  path: ':id', parent: NotificationsPage.name)
            ]),
        _i5.RouteConfig(ChangeLang.name, path: 'changeLang'),
        _i5.RouteConfig(PrivacyPolicy.name, path: 'privacy'),
        _i5.RouteConfig(Termsofuse.name, path: 'terms'),
        _i5.RouteConfig(Franchise.name, path: 'franchise'),
        _i5.RouteConfig(Delivery.name, path: 'delivery'),
        _i5.RouteConfig(Pickup.name, path: 'pickup'),
        _i5.RouteConfig(Profile.name, path: 'profile'),
        _i5.RouteConfig(Myorders.name, path: 'my_orders', children: [
          _i5.RouteConfig(MyOrders.name, path: '', parent: Myorders.name),
          _i5.RouteConfig(OrderDetail.name,
              path: ':orderId', parent: Myorders.name)
        ]),
        _i5.RouteConfig(MyAddresses.name, path: 'my_addresses'),
        _i5.RouteConfig(CashbackDetail.name, path: 'cashback_detail')
      ];
}

/// generated route for
/// [_i1.MessageHandler]
class Home extends _i5.PageRouteInfo<void> {
  const Home() : super(Home.name, path: '/');

  static const String name = 'Home';
}

/// generated route for
/// [_i2.SignInPage]
class SignInPage extends _i5.PageRouteInfo<SignInPageArgs> {
  SignInPage({_i19.Key? key})
      : super(SignInPage.name, path: 'signIn', args: SignInPageArgs(key: key));

  static const String name = 'SignInPage';
}

class SignInPageArgs {
  const SignInPageArgs({this.key});

  final _i19.Key? key;

  @override
  String toString() {
    return 'SignInPageArgs{key: $key}';
  }
}

/// generated route for
/// [_i3.SettingsPage]
class SettingsPage extends _i5.PageRouteInfo<void> {
  const SettingsPage() : super(SettingsPage.name, path: 'settings');

  static const String name = 'SettingsPage';
}

/// generated route for
/// [_i4.AboutUsPage]
class AboutUsPage extends _i5.PageRouteInfo<void> {
  const AboutUsPage() : super(AboutUsPage.name, path: 'about');

  static const String name = 'AboutUsPage';
}

/// generated route for
/// [_i5.EmptyRouterPage]
class NotificationsPage extends _i5.PageRouteInfo<void> {
  const NotificationsPage({List<_i5.PageRouteInfo>? children})
      : super(NotificationsPage.name,
            path: 'notifications', initialChildren: children);

  static const String name = 'NotificationsPage';
}

/// generated route for
/// [_i6.ChangeLang]
class ChangeLang extends _i5.PageRouteInfo<ChangeLangArgs> {
  ChangeLang({_i19.Key? key})
      : super(ChangeLang.name,
            path: 'changeLang', args: ChangeLangArgs(key: key));

  static const String name = 'ChangeLang';
}

class ChangeLangArgs {
  const ChangeLangArgs({this.key});

  final _i19.Key? key;

  @override
  String toString() {
    return 'ChangeLangArgs{key: $key}';
  }
}

/// generated route for
/// [_i7.Privacy]
class PrivacyPolicy extends _i5.PageRouteInfo<void> {
  const PrivacyPolicy() : super(PrivacyPolicy.name, path: 'privacy');

  static const String name = 'PrivacyPolicy';
}

/// generated route for
/// [_i8.Terms]
class Termsofuse extends _i5.PageRouteInfo<void> {
  const Termsofuse() : super(Termsofuse.name, path: 'terms');

  static const String name = 'Termsofuse';
}

/// generated route for
/// [_i9.Franchise]
class Franchise extends _i5.PageRouteInfo<void> {
  const Franchise() : super(Franchise.name, path: 'franchise');

  static const String name = 'Franchise';
}

/// generated route for
/// [_i10.DeliveryPage]
class Delivery extends _i5.PageRouteInfo<DeliveryArgs> {
  Delivery({_i19.Key? key, _i20.YandexGeoData? geoData})
      : super(Delivery.name,
            path: 'delivery', args: DeliveryArgs(key: key, geoData: geoData));

  static const String name = 'Delivery';
}

class DeliveryArgs {
  const DeliveryArgs({this.key, this.geoData});

  final _i19.Key? key;

  final _i20.YandexGeoData? geoData;

  @override
  String toString() {
    return 'DeliveryArgs{key: $key, geoData: $geoData}';
  }
}

/// generated route for
/// [_i11.PickupPage]
class Pickup extends _i5.PageRouteInfo<void> {
  const Pickup() : super(Pickup.name, path: 'pickup');

  static const String name = 'Pickup';
}

/// generated route for
/// [_i12.ProfilePage]
class Profile extends _i5.PageRouteInfo<void> {
  const Profile() : super(Profile.name, path: 'profile');

  static const String name = 'Profile';
}

/// generated route for
/// [_i5.EmptyRouterPage]
class Myorders extends _i5.PageRouteInfo<void> {
  const Myorders({List<_i5.PageRouteInfo>? children})
      : super(Myorders.name, path: 'my_orders', initialChildren: children);

  static const String name = 'Myorders';
}

/// generated route for
/// [_i13.MyAddresses]
class MyAddresses extends _i5.PageRouteInfo<void> {
  const MyAddresses() : super(MyAddresses.name, path: 'my_addresses');

  static const String name = 'MyAddresses';
}

/// generated route for
/// [_i14.CashbackDetail]
class CashbackDetail extends _i5.PageRouteInfo<void> {
  const CashbackDetail() : super(CashbackDetail.name, path: 'cashback_detail');

  static const String name = 'CashbackDetail';
}

/// generated route for
/// [_i15.NotificationsPage]
class NotificationsRoute extends _i5.PageRouteInfo<void> {
  const NotificationsRoute() : super(NotificationsRoute.name, path: '');

  static const String name = 'NotificationsRoute';
}

/// generated route for
/// [_i16.NotificationDetailPage]
class NotificationDetailRoute
    extends _i5.PageRouteInfo<NotificationDetailRouteArgs> {
  NotificationDetailRoute(
      {_i19.Key? key, required String id, Map<String, dynamic>? notification})
      : super(NotificationDetailRoute.name,
            path: ':id',
            args: NotificationDetailRouteArgs(
                key: key, id: id, notification: notification),
            rawPathParams: {'id': id});

  static const String name = 'NotificationDetailRoute';
}

class NotificationDetailRouteArgs {
  const NotificationDetailRouteArgs(
      {this.key, required this.id, this.notification});

  final _i19.Key? key;

  final String id;

  final Map<String, dynamic>? notification;

  @override
  String toString() {
    return 'NotificationDetailRouteArgs{key: $key, id: $id, notification: $notification}';
  }
}

/// generated route for
/// [_i17.MyOrders]
class MyOrders extends _i5.PageRouteInfo<void> {
  const MyOrders() : super(MyOrders.name, path: '');

  static const String name = 'MyOrders';
}

/// generated route for
/// [_i18.OrderDetail]
class OrderDetail extends _i5.PageRouteInfo<OrderDetailArgs> {
  OrderDetail({_i19.Key? key, required String orderId})
      : super(OrderDetail.name,
            path: ':orderId',
            args: OrderDetailArgs(key: key, orderId: orderId),
            rawPathParams: {'orderId': orderId});

  static const String name = 'OrderDetail';
}

class OrderDetailArgs {
  const OrderDetailArgs({this.key, required this.orderId});

  final _i19.Key? key;

  final String orderId;

  @override
  String toString() {
    return 'OrderDetailArgs{key: $key, orderId: $orderId}';
  }
}
