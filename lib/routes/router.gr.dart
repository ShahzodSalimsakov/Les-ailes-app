// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************
//
// ignore_for_file: type=lint

import 'package:auto_route/auto_route.dart' as _i10;
import 'package:flutter/material.dart' as _i11;

import '../home_page.dart' as _i1;
import '../pages/aboutUs.dart' as _i4;
import '../pages/changeLang.dart' as _i6;
import '../pages/franchise.dart' as _i9;
import '../pages/notifications.dart' as _i5;
import '../pages/privacy.dart' as _i7;
import '../pages/settings.dart' as _i3;
import '../pages/signIn.dart' as _i2;
import '../pages/terms.dart' as _i8;

class AppRouter extends _i10.RootStackRouter {
  AppRouter([_i11.GlobalKey<_i11.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i10.PageFactory> pagesMap = {
    HomePage.name: (routeData) {
      return _i10.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i1.HomePage());
    },
    SignInPage.name: (routeData) {
      final args = routeData.argsAs<SignInPageArgs>(
          orElse: () => const SignInPageArgs());
      return _i10.MaterialPageX<dynamic>(
          routeData: routeData, child: _i2.SignInPage(key: args.key));
    },
    SettingsPage.name: (routeData) {
      return _i10.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i3.SettingsPage());
    },
    AboutUsPage.name: (routeData) {
      return _i10.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i4.AboutUsPage());
    },
    NotificationsPage.name: (routeData) {
      return _i10.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i5.NotificationsPage());
    },
    ChangeLang.name: (routeData) {
      final args = routeData.argsAs<ChangeLangArgs>(
          orElse: () => const ChangeLangArgs());
      return _i10.MaterialPageX<dynamic>(
          routeData: routeData, child: _i6.ChangeLang(key: args.key));
    },
    PrivacyPolicy.name: (routeData) {
      return _i10.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i7.Privacy());
    },
    Termsofuse.name: (routeData) {
      return _i10.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i8.Terms());
    },
    Franchise.name: (routeData) {
      return _i10.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i9.Franchise());
    }
  };

  @override
  List<_i10.RouteConfig> get routes => [
        _i10.RouteConfig(HomePage.name, path: '/'),
        _i10.RouteConfig(SignInPage.name, path: '/signIn'),
        _i10.RouteConfig(SettingsPage.name, path: '/settings'),
        _i10.RouteConfig(AboutUsPage.name, path: '/about'),
        _i10.RouteConfig(NotificationsPage.name, path: '/notifications'),
        _i10.RouteConfig(ChangeLang.name, path: '/changeLang'),
        _i10.RouteConfig(PrivacyPolicy.name, path: '/privacy'),
        _i10.RouteConfig(Termsofuse.name, path: '/terms'),
        _i10.RouteConfig(Franchise.name, path: '/franchise')
      ];
}

/// generated route for
/// [_i1.HomePage]
class HomePage extends _i10.PageRouteInfo<void> {
  const HomePage() : super(HomePage.name, path: '/');

  static const String name = 'HomePage';
}

/// generated route for
/// [_i2.SignInPage]
class SignInPage extends _i10.PageRouteInfo<SignInPageArgs> {
  SignInPage({_i11.Key? key})
      : super(SignInPage.name, path: '/signIn', args: SignInPageArgs(key: key));

  static const String name = 'SignInPage';
}

class SignInPageArgs {
  const SignInPageArgs({this.key});

  final _i11.Key? key;

  @override
  String toString() {
    return 'SignInPageArgs{key: $key}';
  }
}

/// generated route for
/// [_i3.SettingsPage]
class SettingsPage extends _i10.PageRouteInfo<void> {
  const SettingsPage() : super(SettingsPage.name, path: '/settings');

  static const String name = 'SettingsPage';
}

/// generated route for
/// [_i4.AboutUsPage]
class AboutUsPage extends _i10.PageRouteInfo<void> {
  const AboutUsPage() : super(AboutUsPage.name, path: '/about');

  static const String name = 'AboutUsPage';
}

/// generated route for
/// [_i5.NotificationsPage]
class NotificationsPage extends _i10.PageRouteInfo<void> {
  const NotificationsPage()
      : super(NotificationsPage.name, path: '/notifications');

  static const String name = 'NotificationsPage';
}

/// generated route for
/// [_i6.ChangeLang]
class ChangeLang extends _i10.PageRouteInfo<ChangeLangArgs> {
  ChangeLang({_i11.Key? key})
      : super(ChangeLang.name,
            path: '/changeLang', args: ChangeLangArgs(key: key));

  static const String name = 'ChangeLang';
}

class ChangeLangArgs {
  const ChangeLangArgs({this.key});

  final _i11.Key? key;

  @override
  String toString() {
    return 'ChangeLangArgs{key: $key}';
  }
}

/// generated route for
/// [_i7.Privacy]
class PrivacyPolicy extends _i10.PageRouteInfo<void> {
  const PrivacyPolicy() : super(PrivacyPolicy.name, path: '/privacy');

  static const String name = 'PrivacyPolicy';
}

/// generated route for
/// [_i8.Terms]
class Termsofuse extends _i10.PageRouteInfo<void> {
  const Termsofuse() : super(Termsofuse.name, path: '/terms');

  static const String name = 'Termsofuse';
}

/// generated route for
/// [_i9.Franchise]
class Franchise extends _i10.PageRouteInfo<void> {
  const Franchise() : super(Franchise.name, path: '/franchise');

  static const String name = 'Franchise';
}
