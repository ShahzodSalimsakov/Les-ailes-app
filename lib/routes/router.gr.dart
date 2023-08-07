// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    MessageHandlerRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const MessageHandlerPage(),
      );
    },
    AboutUsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const AboutUsPage(),
      );
    },
    CashbackDetailRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const CashbackDetailPage(),
      );
    },
    ChangeLangRoute.name: (routeData) {
      final args = routeData.argsAs<ChangeLangRouteArgs>(
          orElse: () => const ChangeLangRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ChangeLangPage(key: args.key),
      );
    },
    CreditCardRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const CreditCardPage(),
      );
    },
    CreditCardListRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const CreditCardListPage(),
      );
    },
    DeliveryRoute.name: (routeData) {
      final args = routeData.argsAs<DeliveryRouteArgs>(
          orElse: () => const DeliveryRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: DeliveryPage(
          key: args.key,
          geoData: args.geoData,
        ),
      );
    },
    FranchiseRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const FranchisePage(),
      );
    },
    MyAddressesRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const MyAddressesPage(),
      );
    },
    MyOrdersRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const MyOrdersPage(),
      );
    },
    NotificationsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const NotificationsPage(),
      );
    },
    NotificationDetailRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<NotificationDetailRouteArgs>(
          orElse: () =>
              NotificationDetailRouteArgs(id: pathParams.getString('id')));
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: NotificationDetailPage(
          key: args.key,
          id: args.id,
          notification: args.notification,
        ),
      );
    },
    OrderDetailRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<OrderDetailRouteArgs>(
          orElse: () =>
              OrderDetailRouteArgs(orderId: pathParams.getString('orderId')));
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: OrderDetailPage(
          key: args.key,
          orderId: args.orderId,
        ),
      );
    },
    PickupRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: PickupPage(),
      );
    },
    PrivacyRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const PrivacyPage(),
      );
    },
    ProfileRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ProfilePage(),
      );
    },
    SettingsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SettingsPage(),
      );
    },
    SignInRoute.name: (routeData) {
      final args = routeData.argsAs<SignInRouteArgs>(
          orElse: () => const SignInRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: SignInPage(key: args.key),
      );
    },
    TermsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const TermsPage(),
      );
    },
  };
}

/// generated route for
/// [MessageHandlerPage]
class MessageHandlerRoute extends PageRouteInfo<void> {
  const MessageHandlerRoute({List<PageRouteInfo>? children})
      : super(
          MessageHandlerRoute.name,
          initialChildren: children,
        );

  static const String name = 'MessageHandlerRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [AboutUsPage]
class AboutUsRoute extends PageRouteInfo<void> {
  const AboutUsRoute({List<PageRouteInfo>? children})
      : super(
          AboutUsRoute.name,
          initialChildren: children,
        );

  static const String name = 'AboutUsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [CashbackDetailPage]
class CashbackDetailRoute extends PageRouteInfo<void> {
  const CashbackDetailRoute({List<PageRouteInfo>? children})
      : super(
          CashbackDetailRoute.name,
          initialChildren: children,
        );

  static const String name = 'CashbackDetailRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ChangeLangPage]
class ChangeLangRoute extends PageRouteInfo<ChangeLangRouteArgs> {
  ChangeLangRoute({
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          ChangeLangRoute.name,
          args: ChangeLangRouteArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'ChangeLangRoute';

  static const PageInfo<ChangeLangRouteArgs> page =
      PageInfo<ChangeLangRouteArgs>(name);
}

class ChangeLangRouteArgs {
  const ChangeLangRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'ChangeLangRouteArgs{key: $key}';
  }
}

/// generated route for
/// [CreditCardPage]
class CreditCardRoute extends PageRouteInfo<void> {
  const CreditCardRoute({List<PageRouteInfo>? children})
      : super(
          CreditCardRoute.name,
          initialChildren: children,
        );

  static const String name = 'CreditCardRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [CreditCardListPage]
class CreditCardListRoute extends PageRouteInfo<void> {
  const CreditCardListRoute({List<PageRouteInfo>? children})
      : super(
          CreditCardListRoute.name,
          initialChildren: children,
        );

  static const String name = 'CreditCardListRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [DeliveryPage]
class DeliveryRoute extends PageRouteInfo<DeliveryRouteArgs> {
  DeliveryRoute({
    Key? key,
    YandexGeoData? geoData,
    List<PageRouteInfo>? children,
  }) : super(
          DeliveryRoute.name,
          args: DeliveryRouteArgs(
            key: key,
            geoData: geoData,
          ),
          initialChildren: children,
        );

  static const String name = 'DeliveryRoute';

  static const PageInfo<DeliveryRouteArgs> page =
      PageInfo<DeliveryRouteArgs>(name);
}

class DeliveryRouteArgs {
  const DeliveryRouteArgs({
    this.key,
    this.geoData,
  });

  final Key? key;

  final YandexGeoData? geoData;

  @override
  String toString() {
    return 'DeliveryRouteArgs{key: $key, geoData: $geoData}';
  }
}

/// generated route for
/// [FranchisePage]
class FranchiseRoute extends PageRouteInfo<void> {
  const FranchiseRoute({List<PageRouteInfo>? children})
      : super(
          FranchiseRoute.name,
          initialChildren: children,
        );

  static const String name = 'FranchiseRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [MyAddressesPage]
class MyAddressesRoute extends PageRouteInfo<void> {
  const MyAddressesRoute({List<PageRouteInfo>? children})
      : super(
          MyAddressesRoute.name,
          initialChildren: children,
        );

  static const String name = 'MyAddressesRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [MyOrdersPage]
class MyOrdersRoute extends PageRouteInfo<void> {
  const MyOrdersRoute({List<PageRouteInfo>? children})
      : super(
          MyOrdersRoute.name,
          initialChildren: children,
        );

  static const String name = 'MyOrdersRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [NotificationsPage]
class NotificationsRoute extends PageRouteInfo<void> {
  const NotificationsRoute({List<PageRouteInfo>? children})
      : super(
          NotificationsRoute.name,
          initialChildren: children,
        );

  static const String name = 'NotificationsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [NotificationDetailPage]
class NotificationDetailRoute
    extends PageRouteInfo<NotificationDetailRouteArgs> {
  NotificationDetailRoute({
    Key? key,
    required String id,
    Map<String, dynamic>? notification,
    List<PageRouteInfo>? children,
  }) : super(
          NotificationDetailRoute.name,
          args: NotificationDetailRouteArgs(
            key: key,
            id: id,
            notification: notification,
          ),
          rawPathParams: {'id': id},
          initialChildren: children,
        );

  static const String name = 'NotificationDetailRoute';

  static const PageInfo<NotificationDetailRouteArgs> page =
      PageInfo<NotificationDetailRouteArgs>(name);
}

class NotificationDetailRouteArgs {
  const NotificationDetailRouteArgs({
    this.key,
    required this.id,
    this.notification,
  });

  final Key? key;

  final String id;

  final Map<String, dynamic>? notification;

  @override
  String toString() {
    return 'NotificationDetailRouteArgs{key: $key, id: $id, notification: $notification}';
  }
}

/// generated route for
/// [OrderDetailPage]
class OrderDetailRoute extends PageRouteInfo<OrderDetailRouteArgs> {
  OrderDetailRoute({
    Key? key,
    required String orderId,
    List<PageRouteInfo>? children,
  }) : super(
          OrderDetailRoute.name,
          args: OrderDetailRouteArgs(
            key: key,
            orderId: orderId,
          ),
          rawPathParams: {'orderId': orderId},
          initialChildren: children,
        );

  static const String name = 'OrderDetailRoute';

  static const PageInfo<OrderDetailRouteArgs> page =
      PageInfo<OrderDetailRouteArgs>(name);
}

class OrderDetailRouteArgs {
  const OrderDetailRouteArgs({
    this.key,
    required this.orderId,
  });

  final Key? key;

  final String orderId;

  @override
  String toString() {
    return 'OrderDetailRouteArgs{key: $key, orderId: $orderId}';
  }
}

/// generated route for
/// [PickupPage]
class PickupRoute extends PageRouteInfo<void> {
  const PickupRoute({List<PageRouteInfo>? children})
      : super(
          PickupRoute.name,
          initialChildren: children,
        );

  static const String name = 'PickupRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [PrivacyPage]
class PrivacyRoute extends PageRouteInfo<void> {
  const PrivacyRoute({List<PageRouteInfo>? children})
      : super(
          PrivacyRoute.name,
          initialChildren: children,
        );

  static const String name = 'PrivacyRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ProfilePage]
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
      : super(
          ProfileRoute.name,
          initialChildren: children,
        );

  static const String name = 'ProfileRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SettingsPage]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
      : super(
          SettingsRoute.name,
          initialChildren: children,
        );

  static const String name = 'SettingsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SignInPage]
class SignInRoute extends PageRouteInfo<SignInRouteArgs> {
  SignInRoute({
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          SignInRoute.name,
          args: SignInRouteArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'SignInRoute';

  static const PageInfo<SignInRouteArgs> page = PageInfo<SignInRouteArgs>(name);
}

class SignInRouteArgs {
  const SignInRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'SignInRouteArgs{key: $key}';
  }
}

/// generated route for
/// [TermsPage]
class TermsRoute extends PageRouteInfo<void> {
  const TermsRoute({List<PageRouteInfo>? children})
      : super(
          TermsRoute.name,
          initialChildren: children,
        );

  static const String name = 'TermsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}
