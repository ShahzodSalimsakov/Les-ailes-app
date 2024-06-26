import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:les_ailes/utils/colors.dart';
import 'package:les_ailes/widgets/cashback.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:niku/niku.dart' as n;
import 'package:http/http.dart' as http;

import '../models/basket.dart';
import '../models/basket_item_quantity.dart';
import '../models/user.dart';
import '../services/user_repository.dart';

class LeftMenuItemsWidget extends StatefulWidget {
  @override
  State<LeftMenuItemsWidget> createState() => _LeftMenuItemsWidgetState();
}

class _LeftMenuItemsWidgetState extends State<LeftMenuItemsWidget> {
  final userRepository = UserRepository();
  Future<void>? _launched;

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

  @override
  Future<void> _launchInBrowser(String url) async {
    if (!await launch(
      url,
      forceSafariVC: false,
      forceWebView: false,
      headers: <String, String>{'my_header_key': 'my_header_value'},
    )) {
      throw 'Could not launch $url';
    }
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  logout() async {
    Box<User> transaction = Hive.box<User>('user');
    User currentUser = transaction.get('user')!;
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${currentUser.userToken}'
    };
    var url = Uri.https('api.lesailes.uz', '/api/logout');
    var formData = {};
    var response = await http.post(url,
        headers: requestHeaders, body: jsonEncode(formData));
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
    }
    transaction.delete('user');
    Box<Basket> basketBox = Hive.box<Basket>('basket');
    basketBox.delete('basket');
    Box<BasketItemQuantity> basketItemQuantityBox =
        Hive.box<BasketItemQuantity>('basketItemQuantity');
    await basketItemQuantityBox.clear();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initPackageInfo();
  }

  @override
  Widget build(BuildContext context) {
    const String toLaunch = 'https://t.me/lesaileshelpbot';
    return ValueListenableBuilder<Box<User>>(
        valueListenable: Hive.box<User>('user').listenable(),
        builder: (context, box, _) {
          bool isUserAuthorized = UserRepository().isAuthorized();
          User? currentUser = box.get('user');
          if (isUserAuthorized) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 60,
                ),
                ListTile(
                  title: Text(
                    currentUser != null ? currentUser.name : '',
                    style: const TextStyle(fontSize: 26),
                  ),
                  subtitle: Text(
                    currentUser != null ? currentUser.phone : '',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                // const Cashback(),
                // const Spacer(flex: 1),
                ListView(
                  shrinkWrap: true,
                  children: [
                    ListTile(
                      leading: SvgPicture.asset("images/profile.svg",
                          width: 24, height: 24),
                      title: Text(
                        tr("leftMenu.profilePage"),
                        style:
                            const TextStyle(color: Colors.black, fontSize: 20),
                      ),
                      onTap: () {
                        Scaffold.of(context).openEndDrawer();
                        context.router.pushNamed("/profile");
                      },
                    ),
                    ListTile(
                      leading: SvgPicture.asset("images/my_orders.svg",
                          width: 24, height: 24),
                      title: Text(
                        tr('leftMenu.myOrders'),
                        style:
                            const TextStyle(color: Colors.black, fontSize: 20),
                      ),
                      onTap: () {
                        Scaffold.of(context).openEndDrawer();
                        context.router.pushNamed("/my_orders");
                      },
                    ),
                    ListTile(
                      leading: SvgPicture.asset("images/my_addresses.svg",
                          width: 24, height: 24),
                      title: Text(
                        tr('leftMenu.myAddresses'),
                        style:
                            const TextStyle(color: Colors.black, fontSize: 20),
                      ),
                      onTap: () {
                        Scaffold.of(context).openEndDrawer();
                        context.router.pushNamed("/my_addresses");
                      },
                    ),
                    ListTile(
                      leading: SvgPicture.asset("images/credit-card.svg",
                          width: 24, height: 24),
                      title: Text(
                        tr('leftMenu.myCards'),
                        style:
                            const TextStyle(color: Colors.black, fontSize: 20),
                      ),
                      onTap: () {
                        Scaffold.of(context).openEndDrawer();
                        context.router.pushNamed("/my_creditCardList");
                      },
                    ),
                    ListTile(
                      leading: SvgPicture.asset("images/settings.svg",
                          width: 24, height: 24),
                      title: Text(
                        tr('leftMenu.settings'),
                        style:
                            const TextStyle(color: Colors.black, fontSize: 20),
                      ),
                      onTap: () {
                        Scaffold.of(context).openEndDrawer();
                        context.router.pushNamed("/settings");
                      },
                    ),
                    ListTile(
                      leading: SvgPicture.asset("images/about.svg",
                          width: 24, height: 24),
                      title: Text(
                        tr("leftMenu.aboutUs"),
                        style:
                            const TextStyle(color: Colors.black, fontSize: 20),
                      ),
                      onTap: () {
                        Scaffold.of(context).openEndDrawer();
                        context.router.pushNamed("/about");
                      },
                    ),
                  ],
                ),
                SizedBox(
                    width: double.infinity,
                    child: n.NikuButton.elevated(Text(tr('signIn.logout')))
                      ..bg = AppColors.mainColor
                      ..color = Colors.white
                      ..mx = 20
                      ..rounded = 10
                      ..onPressed = () {
                        logout();
                      }),
                const Spacer(flex: 1),
                GestureDetector(
                  onTap: () => setState(() {
                    _launched = _launchInBrowser(toLaunch);
                  }),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(
                        bottom: 50, left: 20, right: 20, top: 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey.shade200,
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset('images/chat.svg',
                            width: 50, height: 50),
                        Padding(
                          padding: const EdgeInsets.only(
                              right: 0, left: 10, bottom: 0, top: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tr("leftMenu.writeUs"),
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 20),
                              ),
                              SizedBox(
                                width: 150,
                                child: Text(
                                  tr("leftMenu.writeUsDesc"),
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    _packageInfo.version,
                    style: const TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                )
              ],
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 1),
                ListView(
                  shrinkWrap: true,
                  children: [
                    ListTile(
                      leading: SvgPicture.asset("images/profile.svg",
                          width: 24, height: 24),
                      title: Text(
                        tr("leftMenu.signIn"),
                        style:
                            const TextStyle(color: Colors.black, fontSize: 20),
                      ),
                      onTap: () {
                        Scaffold.of(context).openEndDrawer();
                        context.router.pushNamed("/signIn");
                      },
                    ),
                    ListTile(
                      leading: SvgPicture.asset("images/settings.svg",
                          width: 24, height: 24),
                      title: Text(
                        tr('leftMenu.settings'),
                        style:
                            const TextStyle(color: Colors.black, fontSize: 20),
                      ),
                      onTap: () {
                        Scaffold.of(context).openEndDrawer();
                        context.router.pushNamed("/settings");
                      },
                    ),
                    ListTile(
                      leading: SvgPicture.asset("images/about.svg",
                          width: 24, height: 24),
                      title: Text(
                        tr("leftMenu.aboutUs"),
                        style:
                            const TextStyle(color: Colors.black, fontSize: 20),
                      ),
                      onTap: () {
                        Scaffold.of(context).openEndDrawer();
                        context.router.pushNamed("/about");
                      },
                    ),
                  ],
                ),
                const Spacer(flex: 1),
                GestureDetector(
                  onTap: () => setState(() {
                    _launched = _launchInBrowser(toLaunch);
                  }),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(
                        bottom: 50, left: 20, right: 20, top: 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey.shade200,
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset('images/chat.svg',
                            width: 50, height: 50),
                        Padding(
                          padding: const EdgeInsets.only(
                              right: 0, left: 10, bottom: 0, top: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tr("leftMenu.writeUs"),
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 20),
                              ),
                              SizedBox(
                                width: 150,
                                child: Text(
                                  tr("leftMenu.writeUsDesc"),
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    _packageInfo.version,
                    style: const TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                )
              ],
            );
          }
        });
  }
}
