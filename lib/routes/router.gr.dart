// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************
//
// ignore_for_file: type=lint

import 'package:auto_route/auto_route.dart' as _i12;
import 'package:flutter/material.dart' as _i13;

import '../home_page.dart' as _i1;
import '../models/yandex_geo_data.dart' as _i14;
import '../pages/aboutUs.dart' as _i4;
import '../pages/changeLang.dart' as _i6;
import '../pages/delivery.dart' as _i10;
import '../pages/franchise.dart' as _i9;
import '../pages/notifications.dart' as _i5;
import '../pages/pickup.dart' as _i11;
import '../pages/privacy.dart' as _i7;
import '../pages/settings.dart' as _i3;
import '../pages/signIn.dart' as _i2;
import '../pages/terms.dart' as _i8;

class AppRouter extends _i12.RootStackRouter {
  AppRouter([_i13.GlobalKey<_i13.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i12.PageFactory> pagesMap = {
    HomePage.name: (routeData) {
      return _i12.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i1.HomePage());
    },
    SignInPage.name: (routeData) {
      final args = routeData.argsAs<SignInPageArgs>(
          orElse: () => const SignInPageArgs());
      return _i12.MaterialPageX<dynamic>(
          routeData: routeData, child: _i2.SignInPage(key: args.key));
    },
    SettingsPage.name: (routeData) {
      return _i12.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i3.SettingsPage());
    },
    AboutUsPage.name: (routeData) {
      return _i12.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i4.AboutUsPage());
    },
    NotificationsPage.name: (routeData) {
      return _i12.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i5.NotificationsPage());
    },
    ChangeLang.name: (routeData) {
      final args = routeData.argsAs<ChangeLangArgs>(
          orElse: () => const ChangeLangArgs());
      return _i12.MaterialPageX<dynamic>(
          routeData: routeData, child: _i6.ChangeLang(key: args.key));
    },
    PrivacyPolicy.name: (routeData) {
      return _i12.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i7.Privacy());
    },
    Termsofuse.name: (routeData) {
      return _i12.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i8.Terms());
    },
    Franchise.name: (routeData) {
      return _i12.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i9.Franchise());
    },
    Delivery.name: (routeData) {
      final args =
          routeData.argsAs<DeliveryArgs>(orElse: () => const DeliveryArgs());
      return _i12.MaterialPageX<dynamic>(
          routeData: routeData,
          child: _i10.DeliveryPage(key: args.key, geoData: args.geoData));
    },
    Pickup.name: (routeData) {
      return _i12.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i11.PickupPage());
    }
  };

  @override
  List<_i12.RouteConfig> get routes => [
        _i12.RouteConfig(HomePage.name, path: '/'),
        _i12.RouteConfig(SignInPage.name, path: '/signIn'),
        _i12.RouteConfig(SettingsPage.name, path: '/settings'),
        _i12.RouteConfig(AboutUsPage.name, path: '/about'),
        _i12.RouteConfig(NotificationsPage.name, path: '/notifications'),
        _i12.RouteConfig(ChangeLang.name, path: '/changeLang'),
        _i12.RouteConfig(PrivacyPolicy.name, path: '/privacy'),
        _i12.RouteConfig(Termsofuse.name, path: '/terms'),
        _i12.RouteConfig(Franchise.name, path: '/franchise'),
        _i12.RouteConfig(Delivery.name, path: '/delivery'),
        _i12.RouteConfig(Pickup.name, path: '/pickup')
      ];
}

/// generated route for
/// [_i1.HomePage]
class HomePage extends _i12.PageRouteInfo<void> {
  const HomePage() : super(HomePage.name, path: '/');

  static const String name = 'HomePage';
}

/// generated route for
/// [_i2.SignInPage]
class SignInPage extends _i12.PageRouteInfo<SignInPageArgs> {
  SignInPage({_i13.Key? key})
      : super(SignInPage.name, path: '/signIn', args: SignInPageArgs(key: key));

  static const String name = 'SignInPage';
}

class SignInPageArgs {
  const SignInPageArgs({this.key});

  final _i13.Key? key;

  @override
  String toString() {
    return 'SignInPageArgs{key: $key}';
  }
}

/// generated route for
/// [_i3.SettingsPage]
class SettingsPage extends _i12.PageRouteInfo<void> {
  const SettingsPage() : super(SettingsPage.name, path: '/settings');

  static const String name = 'SettingsPage';
}

/// generated route for
/// [_i4.AboutUsPage]
class AboutUsPage extends _i12.PageRouteInfo<void> {
  const AboutUsPage() : super(AboutUsPage.name, path: '/about');

  static const String name = 'AboutUsPage';
}

/// generated route for
/// [_i5.NotificationsPage]
class NotificationsPage extends _i12.PageRouteInfo<void> {
  const NotificationsPage()
      : super(NotificationsPage.name, path: '/notifications');

  static const String name = 'NotificationsPage';
}

/// generated route for
/// [_i6.ChangeLang]
class ChangeLang extends _i12.PageRouteInfo<ChangeLangArgs> {
  ChangeLang({_i13.Key? key})
      : super(ChangeLang.name,
            path: '/changeLang', args: ChangeLangArgs(key: key));

  static const String name = 'ChangeLang';
}

class ChangeLangArgs {
  const ChangeLangArgs({this.key});

  final _i13.Key? key;

  @override
  String toString() {
    return 'ChangeLangArgs{key: $key}';
  }
}

/// generated route for
/// [_i7.Privacy]
class PrivacyPolicy extends _i12.PageRouteInfo<void> {
  const PrivacyPolicy() : super(PrivacyPolicy.name, path: '/privacy');

  static const String name = 'PrivacyPolicy';
}

/// generated route for
/// [_i8.Terms]
class Termsofuse extends _i12.PageRouteInfo<void> {
  const Termsofuse() : super(Termsofuse.name, path: '/terms');

  static const String name = 'Termsofuse';
}

/// generated route for
/// [_i9.Franchise]
class Franchise extends _i12.PageRouteInfo<void> {
  const Franchise() : super(Franchise.name, path: '/franchise');

  static const String name = 'Franchise';
}

/// generated route for
/// [_i10.DeliveryPage]
class Delivery extends _i12.PageRouteInfo<DeliveryArgs> {
  Delivery({_i13.Key? key, _i14.YandexGeoData? geoData})
      : super(Delivery.name,
            path: '/delivery', args: DeliveryArgs(key: key, geoData: geoData));

  static const String name = 'Delivery';
}

class DeliveryArgs {
  const DeliveryArgs({this.key, this.geoData});

  final _i13.Key? key;

  final _i14.YandexGeoData? geoData;

  @override
  String toString() {
    return 'DeliveryArgs{key: $key, geoData: $geoData}';
  }
}

/// generated route for
/// [_i11.PickupPage]
class Pickup extends _i12.PageRouteInfo<void> {
  const Pickup() : super(Pickup.name, path: '/pickup');

  static const String name = 'Pickup';
}
