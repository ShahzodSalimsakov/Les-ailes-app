import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hashids2/hashids2.dart';
import 'package:les_ailes/models/order.dart';
import 'package:les_ailes/utils/colors.dart';
import 'package:niku/niku.dart' as n;

class OrderSuccess extends HookWidget {
  final Order order;

  const OrderSuccess({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
            body: Container(
      color: Colors.white,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CustomScrollView(slivers: <Widget>[
            SliverAppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              pinned: true,
              snap: false,
              floating: false,
              expandedHeight: 100.0,
              foregroundColor: Colors.black,
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
                statusBarBrightness: Brightness.light,
              ),
              actions: [
                GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Padding(
                      padding: EdgeInsets.only(right: 28),
                      child: Center(child: Icon(Icons.close)),
                    ))
              ],
            ),
            SliverList(
                delegate: SliverChildBuilderDelegate(
                    (BuildContext sliverContext, int index) {
              return Center(
                  child: Column(
                children: [
                  Image.asset(
                    'images/order_success_icon.png',
                    width: 150,
                    height: 150,
                  ),
                  n.NikuText(
                    tr('orderSuccess.thanks'),
                    style: n.NikuTextStyle(fontSize: 24, color: Colors.black),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  n.NikuText(
                    tr('orderSuccess.yourOrderLabel'),
                    style: n.NikuTextStyle(fontSize: 24, color: Colors.black),
                  ),
                  n.NikuText(
                    '№${order.id}',
                    style:
                        n.NikuTextStyle(fontSize: 50, color: AppColors.green),
                  ),
                  n.NikuText(
                    DateFormat('d MMM, Hm')
                        .format(DateTime.parse(order.createdAt!)),
                    style: n.NikuTextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(
                    height: 60,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: n.NikuButton(n.NikuText(
                      tr('orderSuccess.statusLabel'),
                      style: n.NikuTextStyle(color: Colors.white, fontSize: 20),
                    ))
                      ..bg = AppColors.plum
                      ..rounded = 20
                      ..py = 20
                      ..mx = 34
                      ..onPressed = () {
                        Navigator.of(context).pop();
                        final hashids = HashIds(
                          salt: 'order',
                          minHashLength: 15,
                          alphabet: 'abcdefghijklmnopqrstuvwxyz1234567890',
                        );
                        context.router.pushNamed(
                            '/my_orders/${hashids.encode(order.id)}');
                      },
                  )
                ],
              ));
            }, childCount: 1))
          ])),
    )));
  }
}
