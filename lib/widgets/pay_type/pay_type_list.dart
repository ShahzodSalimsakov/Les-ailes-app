import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:niku/niku.dart' as n;

import '../../models/pay_type.dart';
import '../../models/payment_card_model.dart';
import '../../models/terminals.dart';
import 'online_payments.dart';
import 'order_card_list.dart';

class PayTypeListWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    Terminals? currentTerminal =
        Hive.box<Terminals>('currentTerminal').get('currentTerminal');
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
            children: currentTerminal == null
                ? [
                    Text(
                      tr('notSelectedDeliveryType'),
                      style: TextStyle(fontSize: 20),
                    )
                  ]
                : [
                    n.NikuButton(ListTile(
                      leading: const FaIcon(
                        FontAwesomeIcons.wallet,
                        color: Colors.black,
                      ),
                      title: n.NikuText(
                        tr('payType.cash'),
                        style:
                            n.NikuTextStyle(fontSize: 24, color: Colors.black),
                      ),
                      trailing: Container(
                        height: 24,
                        width: 24,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(width: 1, color: Colors.grey)),
                      ),
                    ))
                      ..onPressed = () {
                        PayType newPayType = PayType();
                        newPayType.value = 'offline';
                        Hive.box<PayType>('payType').put('payType', newPayType);
                        Box<PaymentCardModel> box =
                            Hive.box<PaymentCardModel>('paymentCardModel');
                        box.delete('paymentCardModel');
                        Navigator.of(context).pop();
                      },
                    (currentTerminal.myUzCardActive != false)
                        ? (n.NikuButton(ListTile(
                            leading: const Icon(
                              Icons.credit_card,
                              color: Colors.black,
                            ),
                            title: n.NikuText(
                              tr('payType.card'),
                              style: n.NikuTextStyle(
                                  fontSize: 24, color: Colors.black),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.black,
                            ),
                          ))
                          ..onPressed = () {
                            showBarModalBottomSheet(
                                expand: false,
                                context: context,
                                backgroundColor: Colors.white,
                                builder: (context) => const OrderCardList());
                          })
                        : Container(),
                    n.NikuButton(ListTile(
                      leading: Image.asset(
                        'images/pay_type_online.png',
                        width: 30,
                        height: 30,
                      ),
                      title: n.NikuText(
                        tr('payType.online'),
                        style:
                            n.NikuTextStyle(fontSize: 24, color: Colors.black),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.black,
                      ),
                    ))
                      ..onPressed = () {
                        showBarModalBottomSheet(
                            expand: false,
                            context: context,
                            backgroundColor: Colors.white,
                            builder: (context) => OnlinePayments());
                      },
                  ],
          )
        ]));
  }
}
