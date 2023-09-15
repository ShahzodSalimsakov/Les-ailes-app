import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive/hive.dart';
import 'package:les_ailes/utils/colors.dart';
import 'package:niku/niku.dart' as n;

import '../../models/pay_type.dart';
import '../../models/payment_card_model.dart';
import '../../models/terminals.dart';

class OnlinePayments extends HookWidget {
  @override
  Widget build(BuildContext context) {
    Terminals? currentTerminal =
        Hive.box<Terminals>('currentTerminal').get('currentTerminal');
    PayType? payType = Hive.box<PayType>('payType').get('payType');

    List<String> payments = [];

    if (currentTerminal != null) {
      Map<String, dynamic> terminalJson = currentTerminal.toJson();
      for (var key in terminalJson.keys) {
        if (key == 'my_uzcard_active') {
          continue;
        }
        if (key.indexOf('_active') > 1 && terminalJson[key] == true) {
          payments.add(key.replaceAll('_active', ''));
        }
      }
      return Padding(
          padding: const EdgeInsets.all(15),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            n.NikuText(
              tr('payType.online'),
              style: n.NikuTextStyle(fontSize: 24, color: Colors.black),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
                children: payments
                    .map((payment) => GestureDetector(
                          onTap: () {
                            PayType newPayType = PayType();
                            newPayType.value = payment;
                            Hive.box<PayType>('payType')
                                .put('payType', newPayType);
                            Box<PaymentCardModel> box =
                                Hive.box<PaymentCardModel>('paymentCardModel');
                            box.delete('paymentCardModel');
                            Navigator.of(context)
                              ..pop()
                              ..pop();
                          },
                          child: Container(
                            height: 78,
                            width: 78,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border:
                                    payType != null && payType.value == payment
                                        ? Border.all(color: AppColors.mainColor)
                                        : Border.all(width: 0)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Image.asset(
                              'images/$payment.png',
                              height: 78,
                              width: 78,
                            ),
                          ),
                        ))
                    .toList())
          ]));
    } else {
      return Padding(
          padding: const EdgeInsets.all(15),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            n.NikuText(
              tr('payType.online'),
              style: n.NikuTextStyle(fontSize: 24, color: Colors.black),
            ),
            const SizedBox(
              height: 20,
            ),
            n.NikuText(
              tr('payType.chooseDeliveryAddress'),
              style: n.NikuTextStyle(fontSize: 20, color: Colors.black),
            )
          ]));
    }
  }
}
