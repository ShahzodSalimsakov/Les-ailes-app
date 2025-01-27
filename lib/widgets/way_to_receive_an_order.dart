import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:les_ailes/utils/colors.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:niku/niku.dart' as n;
import '../models/delivery_location_data.dart';
import '../models/delivery_type.dart';
import '../models/pay_type.dart';
import '../models/payment_card_model.dart';
import '../models/terminals.dart';

class WayToReceiveAnOrder extends StatelessWidget {
  const WayToReceiveAnOrder({super.key});

  openBottomSheet(BuildContext context) {
    showBarModalBottomSheet(
        expand: false,
        context: context,
        backgroundColor: Colors.white,
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
                  shrinkWrap: true,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        context.router.pushNamed('/delivery');
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
                        PayType newPayType = PayType();
                        newPayType.value = 'offline';
                        Hive.box<PayType>('payType').put('payType', newPayType);
                        Box<PaymentCardModel> box =
                            Hive.box<PaymentCardModel>('paymentCardModel');
                        box.delete('paymentCardModel');
                        Navigator.of(context).pop();
                        context.router.pushNamed('/pickup');
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
                  ],
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<DeliveryType>>(
        valueListenable: Hive.box<DeliveryType>('deliveryType').listenable(),
        builder: (context, box, _) {
          Box<DeliveryLocationData> deliveryLocationBox =
              Hive.box<DeliveryLocationData>('deliveryLocationData');
          DeliveryLocationData? deliveryLocationData =
              deliveryLocationBox.get('deliveryLocationData');
          DeliveryType? deliveryType = box.get('deliveryType');
          String deliveryText = tr("main.deliveryOrPickup");
          Box<Terminals> terminalBox = Hive.box<Terminals>('currentTerminal');
          Terminals? currentTerminal = terminalBox.get('currentTerminal');

          if (deliveryLocationData != null &&
              deliveryType?.value == DeliveryTypeEnum.deliver) {
            deliveryText = deliveryLocationData.address ?? '';
            if (deliveryText.isNotEmpty) {
              List<String> addressParts = [];

              if (deliveryLocationData.house != null &&
                  deliveryLocationData.house!.isNotEmpty) {
                addressParts
                    .add('${tr("house")}: ${deliveryLocationData.house}');
              }

              if (deliveryLocationData.flat != null &&
                  deliveryLocationData.flat!.isNotEmpty) {
                addressParts.add('${tr("flat")}: ${deliveryLocationData.flat}');
              }

              if (deliveryLocationData.entrance != null &&
                  deliveryLocationData.entrance!.isNotEmpty) {
                addressParts
                    .add('${tr("entrance")}: ${deliveryLocationData.entrance}');
              }

              if (addressParts.isNotEmpty) {
                deliveryText = '$deliveryText, ${addressParts.join(", ")}';
              }
            } else {
              deliveryText = tr("delivery.selectAddress");
            }
          }

          if (deliveryType != null) {
            return n.NikuButton(Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        deliveryType.value == DeliveryTypeEnum.deliver
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
                        Text(
                          tr(deliveryType.value.toString()),
                          style: const TextStyle(color: Colors.grey),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    deliveryType.value == DeliveryTypeEnum.deliver
                        ? SizedBox(
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: n.NikuText(
                              deliveryText,
                              style: n.NikuTextStyle(color: Colors.grey),
                            ))
                        : n.NikuText(
                            currentTerminal?.name ??
                                tr("main.selectPickupPoint"),
                            style: n.NikuTextStyle(
                                color: Colors.black, fontSize: 20),
                          )
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
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    context.router.pushNamed('/delivery');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      color: AppColors.grey,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 4,
                          // offset: Offset(1, 1), // Shadow position
                        ),
                      ],
                    ),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset('images/car.png', height: 40, width: 40),
                          Text(
                            tr("deliveryOrPickup.delivery"),
                            style: const TextStyle(fontSize: 15),
                          )
                        ]),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    context.router.pushNamed('/pickup');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      color: AppColors.grey,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 4,
                          // offset: Offset(2, 4), // Shadow position
                        ),
                      ],
                    ),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset('images/bag.png', height: 40, width: 40),
                          Text(
                            tr("deliveryOrPickup.takeAway"),
                            style: const TextStyle(fontSize: 15),
                          )
                        ]),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
