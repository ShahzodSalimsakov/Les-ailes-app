import 'package:auto_route/annotations.dart';
import 'package:les_ailes/home_page.dart';
import 'package:les_ailes/pages/aboutUs.dart';
import 'package:les_ailes/pages/changeLang.dart';
import 'package:les_ailes/pages/franchise.dart';
import 'package:les_ailes/pages/notifications.dart';
import 'package:les_ailes/pages/privacy.dart';
import 'package:les_ailes/pages/settings.dart';
import 'package:les_ailes/pages/signIn.dart';
import 'package:les_ailes/pages/terms.dart';

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
  AutoRoute(path: '/changeLang', name: 'changeLang', page: ChangeLang),
  AutoRoute(path: '/privacy', name: 'PrivacyPolicy', page: Privacy),
  AutoRoute(path: '/terms', name: 'Termsofuse', page: Terms),
  AutoRoute(path: '/franchise', name: 'Franchise', page: Franchise)
])
class $AppRouter {}
