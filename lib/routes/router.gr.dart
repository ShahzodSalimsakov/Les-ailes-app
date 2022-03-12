// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************
//
// ignore_for_file: type=lint

import 'package:auto_route/auto_route.dart' as _i6;
import 'package:flutter/material.dart' as _i7;

import '../home_page.dart' as _i1;
import '../pages/aboutUs.dart' as _i4;
import '../pages/notifications.dart' as _i5;
import '../pages/settings.dart' as _i3;
import '../pages/signIn.dart' as _i2;

class AppRouter extends _i6.RootStackRouter {
  AppRouter([_i7.GlobalKey<_i7.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i6.PageFactory> pagesMap = {
    HomePage.name: (routeData) {
      return _i6.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i1.HomePage());
    },
    SignInPage.name: (routeData) {
      return _i6.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i2.SignInPage());
    },
    SettingsPage.name: (routeData) {
      return _i6.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i3.SettingsPage());
    },
    AboutUsPage.name: (routeData) {
      return _i6.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i4.AboutUsPage());
    },
    NotificationsPage.name: (routeData) {
      return _i6.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i5.NotificationsPage());
    }
  };

  @override
  List<_i6.RouteConfig> get routes => [
        _i6.RouteConfig(HomePage.name, path: '/'),
        _i6.RouteConfig(SignInPage.name, path: 'signIn'),
        _i6.RouteConfig(SettingsPage.name, path: 'settings'),
        _i6.RouteConfig(AboutUsPage.name, path: 'signIn'),
        _i6.RouteConfig(NotificationsPage.name, path: 'notifications')
      ];
}

/// generated route for
/// [_i1.HomePage]
class HomePage extends _i6.PageRouteInfo<void> {
  const HomePage() : super(HomePage.name, path: '/');

  static const String name = 'HomePage';
}

/// generated route for
/// [_i2.SignInPage]
class SignInPage extends _i6.PageRouteInfo<void> {
  const SignInPage() : super(SignInPage.name, path: 'signIn');

  static const String name = 'SignInPage';
}

/// generated route for
/// [_i3.SettingsPage]
class SettingsPage extends _i6.PageRouteInfo<void> {
  const SettingsPage() : super(SettingsPage.name, path: 'settings');

  static const String name = 'SettingsPage';
}

/// generated route for
/// [_i4.AboutUsPage]
class AboutUsPage extends _i6.PageRouteInfo<void> {
  const AboutUsPage() : super(AboutUsPage.name, path: 'signIn');

  static const String name = 'AboutUsPage';
}

/// generated route for
/// [_i5.NotificationsPage]
class NotificationsPage extends _i6.PageRouteInfo<void> {
  const NotificationsPage()
      : super(NotificationsPage.name, path: 'notifications');

  static const String name = 'NotificationsPage';
}
