import 'package:auto_route/annotations.dart';
import 'package:les_ailes/home_page.dart';
import 'package:les_ailes/pages/aboutUs.dart';
import 'package:les_ailes/pages/changeLang.dart';
import 'package:les_ailes/pages/notifications.dart';
import 'package:les_ailes/pages/settings.dart';
import 'package:les_ailes/pages/signIn.dart';

@MaterialAutoRouter(replaceInRouteName: 'Page,Route', routes: [
  AutoRoute(
    path: '/',
    name: 'HomePage',
    page: HomePage,
  ),
  AutoRoute(path: '/signIn', name: 'SignInPage', page: SignInPage),
  AutoRoute(
    path: '/settings',
    name: 'SettingsPage',
    page: SettingsPage,
  ),
  AutoRoute(path: '/about', name: 'AboutUsPage', page: AboutUsPage),
  AutoRoute(
      path: '/notifications',
      name: 'NotificationsPage',
      page: NotificationsPage),
  AutoRoute(path: '/changeLang', name: 'changeLang', page: ChangeLang)
])
class $AppRouter {}
