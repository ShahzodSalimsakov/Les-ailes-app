// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

/// generated route for
/// [AboutUsPage]
class AboutUsRoute extends PageRouteInfo<void> {
  const AboutUsRoute({List<PageRouteInfo>? children})
      : super(
          AboutUsRoute.name,
          initialChildren: children,
        );

  static const String name = 'AboutUsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AboutUsPage();
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ChangeLangRouteArgs>(
          orElse: () => const ChangeLangRouteArgs());
      return ChangeLangPage(key: args.key);
    },
  );
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
/// [CreditCardListPage]
class CreditCardListRoute extends PageRouteInfo<void> {
  const CreditCardListRoute({List<PageRouteInfo>? children})
      : super(
          CreditCardListRoute.name,
          initialChildren: children,
        );

  static const String name = 'CreditCardListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CreditCardListPage();
    },
  );
}

/// generated route for
/// [CreditCardOtpPage]
class CreditCardOtpRoute extends PageRouteInfo<CreditCardOtpRouteArgs> {
  CreditCardOtpRoute({
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          CreditCardOtpRoute.name,
          args: CreditCardOtpRouteArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'CreditCardOtpRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CreditCardOtpRouteArgs>(
          orElse: () => const CreditCardOtpRouteArgs());
      return CreditCardOtpPage(key: args.key);
    },
  );
}

class CreditCardOtpRouteArgs {
  const CreditCardOtpRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'CreditCardOtpRouteArgs{key: $key}';
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CreditCardPage();
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DeliveryRouteArgs>(
          orElse: () => const DeliveryRouteArgs());
      return DeliveryPage(
        key: args.key,
        geoData: args.geoData,
      );
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const FranchisePage();
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MessageHandlerPage();
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MyAddressesPage();
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MyOrdersPage();
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<NotificationDetailRouteArgs>(
          orElse: () =>
              NotificationDetailRouteArgs(id: pathParams.getString('id')));
      return NotificationDetailPage(
        key: args.key,
        id: args.id,
        notification: args.notification,
      );
    },
  );
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
/// [NotificationsPage]
class NotificationsRoute extends PageRouteInfo<void> {
  const NotificationsRoute({List<PageRouteInfo>? children})
      : super(
          NotificationsRoute.name,
          initialChildren: children,
        );

  static const String name = 'NotificationsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const NotificationsPage();
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<OrderDetailRouteArgs>(
          orElse: () =>
              OrderDetailRouteArgs(orderId: pathParams.getString('orderId')));
      return OrderDetailPage(
        key: args.key,
        orderId: args.orderId,
      );
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return PickupPage();
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PrivacyPage();
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfilePage();
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsPage();
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args =
          data.argsAs<SignInRouteArgs>(orElse: () => const SignInRouteArgs());
      return SignInPage(key: args.key);
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TermsPage();
    },
  );
}
