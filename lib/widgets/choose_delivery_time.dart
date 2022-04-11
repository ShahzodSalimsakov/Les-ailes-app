import 'package:dart_date/dart_date.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:les_ailes/widgets/deliver_time/list_of_times.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:niku/niku.dart' as n;

import '../models/deliver_later_time.dart';
import '../models/delivery_time.dart';

class ChooseDeliveryTime extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<DeliveryTime>>(
        valueListenable: Hive.box<DeliveryTime>('deliveryTime').listenable(),
    builder: (context, box, _) {
      DeliveryTime? deliveryTime = box.
      get('deliveryTime');
      Box<DeliverLaterTime> deliveryTimeBox =
      Hive.box<DeliverLaterTime>(
          'deliveryLaterTime');
      DeliverLaterTime? deliveryTimeSelected =
      deliveryTimeBox.get('deliveryLaterTime');
      if (deliveryTime == null) {
        return n.NikuButton(Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const FaIcon(FontAwesomeIcons.clock, color: Colors.black,),
            const SizedBox(width: 20,),
            n.NikuText(tr('orderCreate.chooseDeliveryTime'), style: n.NikuTextStyle(fontSize: 20, color: Colors.black),),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.black, size: 30,)
          ],
        ))..p = 20..bg = Colors.grey.shade100..rounded = 20..onPressed = () {
          showBarModalBottomSheet(
              expand: false,
              context: context,
              backgroundColor: Colors.transparent,
              builder: (context) => ListOfDeliveryTimesTypes());
        };
      } else {
        return n.NikuButton(Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const FaIcon(FontAwesomeIcons.clock, color: Colors.black,),
            const SizedBox(width: 20,),
            n.NikuText(deliveryTime.value == DeliveryTimeEnum.now ? tr('orderCreate.deliverNow') : deliveryTimeSelected!.value.toString(), style: n.NikuTextStyle(fontSize: 20, color: Colors.black),),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.black, size: 30,)
          ],
        ))..p = 20..bg = Colors.grey.shade100..rounded = 20..onPressed = () {
          showBarModalBottomSheet(
              expand: false,
              context: context,
              backgroundColor: Colors.transparent,
              builder: (context) => ListOfDeliveryTimesTypes());
        };
      }
    }
    );
  }
}