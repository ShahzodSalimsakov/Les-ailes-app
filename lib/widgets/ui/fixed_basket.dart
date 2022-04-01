import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:niku/niku.dart' as n;

import '../../models/basket.dart';
import '../../utils/colors.dart';

class FixedBasket extends StatelessWidget {
  const FixedBasket({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Basket>>(
        valueListenable: Hive.box<Basket>('basket').listenable(),
        builder: (context, box, _) {
          Basket? basket = box.get('basket');
          int totalPrice = 0;
          if (basket != null) {
            totalPrice = basket.totalPrice ?? 0;
          }

          final formatCurrency = NumberFormat.currency(
              locale: 'ru_RU', symbol: 'сум', decimalDigits: 0);

          String formattedTotalPrice =
              formatCurrency.format(double.tryParse(totalPrice.toString()));
          if (totalPrice > 0) {
            return SizedBox(
                height: 100,
                width: double.infinity,
                child: n.NikuButton.elevated(Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(tr('basket.navigationBottomLabel')),
                    Text(formattedTotalPrice)
                  ],
                ))
                  ..bg = AppColors.mainColor
                  ..color = Colors.white
                  ..mx = 20
                  ..my = 20
                  ..rounded = 25);
          }
          return const SizedBox(height: 0);
        });
  }
}
