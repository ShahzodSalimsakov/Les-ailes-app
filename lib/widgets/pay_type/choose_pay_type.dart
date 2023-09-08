import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:les_ailes/models/pay_type.dart';
import 'package:les_ailes/widgets/pay_type/pay_type_list.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:niku/niku.dart' as n;

import '../../models/payment_card_model.dart';

class ChoosePayType extends HookWidget {
  Widget renderPayType(PayType payType, BuildContext context) {
    switch (payType.value) {
      case 'offline':
        return n.NikuButton(Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const FaIcon(
              FontAwesomeIcons.wallet,
              color: Colors.black,
            ),
            const SizedBox(
              width: 20,
            ),
            n.NikuText(
              tr('payType.cash'),
              style: n.NikuTextStyle(fontSize: 20, color: Colors.black),
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right,
              color: Colors.black,
              size: 30,
            )
          ],
        ))
          ..p = 20
          ..bg = Colors.grey.shade100
          ..rounded = 20
          ..onPressed = () {
            showBarModalBottomSheet(
                expand: false,
                context: context,
                backgroundColor: Colors.white,
                builder: (context) => PayTypeListWidget());
          };
      case 'cashback':
        return n.NikuButton(Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'images/pay_type_les_coin.png',
              width: 30,
              height: 30,
            ),
            const SizedBox(
              width: 20,
            ),
            n.NikuText(
              tr('payType.cashback'),
              style: n.NikuTextStyle(fontSize: 20, color: Colors.black),
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right,
              color: Colors.black,
              size: 30,
            )
          ],
        ))
          ..p = 20
          ..bg = Colors.grey.shade100
          ..rounded = 20
          ..onPressed = () {
            showBarModalBottomSheet(
                expand: false,
                context: context,
                backgroundColor: Colors.white,
                builder: (context) => PayTypeListWidget());
          };
      case 'uzcard':
        return n.NikuButton(Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'images/pay_type_uzcard.png',
              width: 30,
              height: 30,
            ),
            const SizedBox(
              width: 20,
            ),
            n.NikuText(
              tr('payType.uzcard'),
              style: n.NikuTextStyle(fontSize: 20, color: Colors.black),
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right,
              color: Colors.black,
              size: 30,
            )
          ],
        ))
          ..p = 20
          ..bg = Colors.grey.shade100
          ..rounded = 20
          ..onPressed = () {
            showBarModalBottomSheet(
                expand: false,
                context: context,
                backgroundColor: Colors.white,
                builder: (context) => PayTypeListWidget());
          };

      case 'card':
        Box<PaymentCardModel> box =
            Hive.box<PaymentCardModel>('paymentCardModel');
        PaymentCardModel? paymentCardModel = box.get('paymentCardModel');
        return n.NikuButton(Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(
              Icons.credit_card,
              color: Colors.black,
            ),
            const SizedBox(
              width: 20,
            ),
            n.NikuText(
              paymentCardModel != null
                  ? paymentCardModel.number
                  : tr('payType.uzcard'),
              style: n.NikuTextStyle(fontSize: 20, color: Colors.black),
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right,
              color: Colors.black,
              size: 30,
            )
          ],
        ))
          ..p = 20
          ..bg = Colors.grey.shade100
          ..rounded = 20
          ..onPressed = () {
            showBarModalBottomSheet(
                expand: false,
                context: context,
                backgroundColor: Colors.white,
                builder: (context) => PayTypeListWidget());
          };
      default:
        return n.NikuButton(Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'images/${payType.value}.png',
              width: 30,
              height: 30,
            ),
            const SizedBox(
              width: 20,
            ),
            n.NikuText(
              payType.value.toUpperCase(),
              style: n.NikuTextStyle(fontSize: 20, color: Colors.black),
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right,
              color: Colors.black,
              size: 30,
            )
          ],
        ))
          ..p = 20
          ..bg = Colors.grey.shade100
          ..rounded = 20
          ..onPressed = () {
            showBarModalBottomSheet(
                expand: false,
                context: context,
                backgroundColor: Colors.white,
                builder: (context) => PayTypeListWidget());
          };
    }
  }

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      Box<PayType> box = Hive.box<PayType>('payType');
      PayType? paymentType = box.get('payType');
      if (paymentType == null) {
        PayType newPayType = PayType();
        newPayType.value = 'offline';
        Hive.box<PayType>('payType').put('payType', newPayType);
      }
      return null;
    }, []);
    return ValueListenableBuilder<Box<PayType>>(
        valueListenable: Hive.box<PayType>('payType').listenable(),
        builder: (context, box, _) {
          PayType? payType = box.get('payType');
          print(payType);
          if (payType == null) {
            return n.NikuButton(Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const FaIcon(
                  FontAwesomeIcons.creditCard,
                  color: Colors.black,
                ),
                const SizedBox(
                  width: 20,
                ),
                n.NikuText(
                  tr('orderCreate.payType'),
                  style: n.NikuTextStyle(fontSize: 20, color: Colors.black),
                ),
                const Spacer(),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.black,
                  size: 30,
                )
              ],
            ))
              ..p = 20
              ..bg = Colors.grey.shade100
              ..rounded = 20
              ..onPressed = () {
                showBarModalBottomSheet(
                    expand: false,
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (context) => PayTypeListWidget());
              };
          } else {
            return renderPayType(payType, context);
          }
        });
  }
}
