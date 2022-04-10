import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:niku/niku.dart' as n;

import '../../models/pay_type.dart';
import 'online_payments.dart';

class PayTypeListWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(15),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          n.NikuText(
            tr('orderCreate.payType'),
            style: n.NikuTextStyle(fontSize: 24, color: Colors.black),
          ),
          const SizedBox(
            height: 30,
          ),
          ListView(
            shrinkWrap: true,
            children: [
              n.NikuButton(ListTile(
                leading: const FaIcon(FontAwesomeIcons.wallet, color: Colors.black,),
                title: n.NikuText(
                  tr('payType.cash'),
                  style: n.NikuTextStyle(fontSize: 24, color: Colors.black),
                ),
                trailing: Container(
                  height: 24,
                  width: 24,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(width: 1, color: Colors.grey)),
                ),
              ))
                ..onPressed = () {
                  PayType newPayType = PayType();
                  newPayType.value = 'offline';
                  Hive.box<PayType>('payType').put('payType', newPayType);
                  Navigator.of(context).pop();
                },
              n.NikuButton(ListTile(
                leading: Image.asset('images/pay_type_uzcard.png', width: 30, height: 30,),
                title: n.NikuText(
                  tr('payType.uzcard'),
                  style: n.NikuTextStyle(fontSize: 24, color: Colors.black),
                ),
                trailing: Container(
                  height: 24,
                  width: 24,
                  decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(width: 1, color: Colors.grey)),
                ),
              ))
                ..onPressed = () {
                  PayType newPayType = PayType();
                  newPayType.value = 'uzcard';
                  Hive.box<PayType>('payType').put('payType', newPayType);
                  Navigator.of(context).pop();
                },
              n.NikuButton(ListTile(
                leading: Image.asset('images/pay_type_online.png', width: 30, height: 30,),
                title: n.NikuText(
                  tr('payType.online'),
                  style: n.NikuTextStyle(fontSize: 24, color: Colors.black),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black,),
              ))
                ..onPressed = () {
                  showBarModalBottomSheet(
                  expand: false,
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (context) => OnlinePayments());

                },
              n.NikuButton(ListTile(
                leading: Image.asset('images/pay_type_les_coin.png', width: 30, height: 30,),
                title: n.NikuText(
                  tr('payType.cashback'),
                  style: n.NikuTextStyle(fontSize: 24, color: Colors.black),
                ),
                trailing: Container(
                  height: 24,
                  width: 24,
                  decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(width: 1, color: Colors.grey)),
                ),
              ))
                ..onPressed = () {
                  PayType newPayType = PayType();
                  newPayType.value = 'cashback';
                  Hive.box<PayType>('payType').put('payType', newPayType);
                  Navigator.of(context).pop();;
                },
            ],
          )
        ]));
  }
}
