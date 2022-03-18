// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************
//
// ignore_for_file: type=lint

import 'package:auto_route/auto_route.dart' as _i7;
import 'package:flutter/material.dart' as _i8;

import '../home_page.dart' as _i1;
import '../pages/aboutUs.dart' as _i4;
import '../pages/changeLang.dart' as _i6;
import '../pages/notifications.dart' as _i5;
import '../pages/settings.dart' as _i3;
import '../pages/signIn.dart' as _i2;

class AppRouter extends _i7.RootStackRouter {
  AppRouter([_i8.GlobalKey<_i8.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i7.PageFactory> pagesMap = {
    HomePage.name: (routeData) {
      return _i7.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i1.HomePage());
    },
    SignInPage.name: (routeData) {
      final args = routeData.argsAs<SignInPageArgs>(
          orElse: () => const SignInPageArgs());
      return _i7.MaterialPageX<dynamic>(
          routeData: routeData, child: _i2.SignInPage(key: args.key));
    },
    SettingsPage.name: (routeData) {
      return _i7.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i3.SettingsPage());
    },
    AboutUsPage.name: (routeData) {
      return _i7.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i4.AboutUsPage());
    },
    NotificationsPage.name: (routeData) {
      return _i7.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i5.NotificationsPage());
    },
    ChangeLang.name: (routeData) {
      final args = routeData.argsAs<ChangeLangArgs>(
          orElse: () => const ChangeLangArgs());
      return _i7.MaterialPageX<dynamic>(
          routeData: routeData, child: _i6.ChangeLang(key: args.key));
    }
  };

  @override
  List<_i7.RouteConfig> get routes => [
        _i7.RouteConfig(HomePage.name, path: '/'),
        _i7.RouteConfig(SignInPage.name, path: '/signIn'),
        _i7.RouteConfig(SettingsPage.name, path: '/settings'),
        _i7.RouteConfig(AboutUsPage.name, path: '/about'),
        _i7.RouteConfig(NotificationsPage.name, path: '/notifications'),
        _i7.RouteConfig(ChangeLang.name, path: '/changeLang')
      ];
}

/// generated route for
/// [_i1.HomePage]
class HomePage extends _i7.PageRouteInfo<void> {
  const HomePage() : super(HomePage.name, path: '/');

  static const String name = 'HomePage';
}

/// generated route for
/// [_i2.SignInPage]
class SignInPage extends _i7.PageRouteInfo<SignInPageArgs> {
  SignInPage({_i8.Key? key})
      : super(SignInPage.name, path: '/signIn', args: SignInPageArgs(key: key));

  static const String name = 'SignInPage';
}

class SignInPageArgs {
  const SignInPageArgs({this.key});

  final _i8.Key? key;

  @override
  String toString() {
    return 'SignInPageArgs{key: $key}';
  }
}

/// generated route for
/// [_i3.SettingsPage]
class SettingsPage extends _i7.PageRouteInfo<void> {
  const SettingsPage() : super(SettingsPage.name, path: '/settings');

  static const String name = 'SettingsPage';
}

/// generated route for
/// [_i4.AboutUsPage]
class AboutUsPage extends _i7.PageRouteInfo<void> {
  const AboutUsPage() : super(AboutUsPage.name, path: '/about');

  static const String name = 'AboutUsPage';
}

/// generated route for
/// [_i5.NotificationsPage]
class NotificationsPage extends _i7.PageRouteInfo<void> {
  const NotificationsPage()
      : super(NotificationsPage.name, path: '/notifications');

  static const String name = 'NotificationsPage';
}

/// generated route for
/// [_i6.ChangeLang]
class ChangeLang extends _i7.PageRouteInfo<ChangeLangArgs> {
  ChangeLang({_i8.Key? key})
      : super(ChangeLang.name,
            path: '/changeLang', args: ChangeLangArgs(key: key));

  static const String name = 'ChangeLang';
}

class ChangeLangArgs {
  const ChangeLangArgs({this.key});

  final _i8.Key? key;

  @override
  String toString() {
    return 'ChangeLangArgs{key: $key}';
  }
}
