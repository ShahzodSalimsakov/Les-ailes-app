import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:les_ailes/utils/colors.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:niku/niku.dart' as n;

import '../models/delivery_location_data.dart';
import '../models/delivery_type.dart';
import '../models/terminals.dart';

class WayToReceiveAnOrder extends StatelessWidget {
  const WayToReceiveAnOrder({Key? key}) : super(key: key);

  openBottomSheet(BuildContext context) {
    showBarModalBottomSheet(
        expand: false,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 32, horizontal: 37),
                  child: Text(tr("deliveryOrPickup.chooseType"),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w500)),
                ),
                GridView.count(
                  padding: const EdgeInsets.only(
                    top: 0,
                    bottom: 70,
                    left: 16,
                    right: 16,
                  ),
                  crossAxisCount: 2,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  childAspectRatio: (164 / 164),
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        context.router.pushNamed('delivery');
                      },
                      child: Container(
                        width: 164,
                        height: 164,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26),
                          color: AppColors.grey,
                        ),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset('images/car.png',
                                  height: 92, width: 92),
                              const SizedBox(height: 36),
                              Text(
                                tr("deliveryOrPickup.delivery"),
                                style: const TextStyle(fontSize: 20),
                              )
                            ]),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        context.router.pushNamed('pickup');
                      },
                      child: Container(
                        width: 164,
                        height: 164,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26),
                          color: AppColors.grey,
                        ),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset('images/bag.png',
                                  height: 92, width: 92),
                              const SizedBox(height: 36),
                              Text(
                                tr("deliveryOrPickup.takeAway"),
                                style: const TextStyle(fontSize: 20),
                              )
                            ]),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 164,
                        height: 164,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26),
                          color: AppColors.grey,
                        ),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset('images/inrestourant.png',
                                  height: 92, width: 92),
                              const SizedBox(height: 36),
                              Text(
                                tr("deliveryOrPickup.AtTheRestaurant"),
                                style: const TextStyle(fontSize: 20),
                              )
                            ]),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 164,
                        height: 164,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26),
                          color: AppColors.grey,
                        ),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset('images/parking.png',
                                  height: 92, width: 92),
                              const SizedBox(height: 36),
                              Text(
                                tr("deliveryOrPickup.toTheParkingLot"),
                                style: const TextStyle(fontSize: 20),
                              )
                            ]),
                      ),
                    )
                  ],
                  shrinkWrap: true,
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<DeliveryLocationData>>(
        valueListenable:
            Hive.box<DeliveryLocationData>('deliveryLocationData').listenable(),
        builder: (context, box, _) {
          DeliveryLocationData? deliveryLocationData =
              box.get('deliveryLocationData');
          Box<DeliveryType> deliveryTypeBox =
              Hive.box<DeliveryType>('deliveryType');
          DeliveryType? deliveryType = deliveryTypeBox.get('deliveryType');
          String deliveryText = tr("main.deliveryOrPickup");
          Box<Terminals> terminalBox = Hive.box<Terminals>('currentTerminal');
          Terminals? currentTerminal = terminalBox.get('currentTerminal');
          if (deliveryLocationData != null) {
            if (deliveryType!.value == DeliveryTypeEnum.deliver) {
              deliveryText = deliveryLocationData?.address ?? '';
              String house = deliveryLocationData.house != null
                  ? ', дом: ${deliveryLocationData.house}'
                  : '';
              String flat = deliveryLocationData.flat != null
                  ? ', кв.: ${deliveryLocationData.flat}'
                  : '';
              String entrance = deliveryLocationData.entrance != null
                  ? ', подъезд: ${deliveryLocationData.entrance}'
                  : '';
              deliveryText = '${deliveryText}${house}${flat}${entrance}';
            }
          }

          if (deliveryLocationData != null) {
            return n.NikuButton(Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        deliveryType!.value == DeliveryTypeEnum.deliver
                            ? Image.asset(
                                'images/delivery_car.png',
                                width: 30,
                                height: 15,
                              )
                            : Image.asset(
                                'images/delivery_pickup.png',
                                width: 30,
                                height: 15,
                              ),
                        const SizedBox(width: 10),
                        Text(tr(deliveryType.value.toString()), style: const TextStyle(color: Colors.grey),)
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    deliveryType!.value == DeliveryTypeEnum.deliver
                        ? SizedBox(
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: n.NikuText(deliveryText, style: n.NikuTextStyle(color: Colors.grey),))
                        : n.NikuText(currentTerminal!.name)
                  ],
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.black,
                  size: 30,
                )
              ],
            ))
              ..bg = Colors.grey.shade100
              ..rounded = 20
              ..p = 20
            ..onPressed = () {
              openBottomSheet(context);
            };
          }
          return GestureDetector(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 220,
                      child: Text(
                        deliveryText,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Image.asset("images/rocket.png")
                  ]),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.green),
              height: 75,
              width: double.infinity,
            ),
            onTap: () {
              openBottomSheet(context);
            },
          );
        });
  }
}
