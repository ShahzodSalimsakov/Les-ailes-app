import 'package:auto_route/annotations.dart';
import 'package:les_ailes/pages/notifications.dart';

@MaterialAutoRouter(
    replaceInRouteName: 'Page,Route',
    routes: [AutoRoute(path: '/pages/notifications', page: Notifications)])
class $AppRouter {}
