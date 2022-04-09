import 'package:dart_date/dart_date.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:niku/niku.dart' as n;

import '../../models/deliver_later_time.dart';
import '../../models/delivery_time.dart';
import '../../utils/colors.dart';

class ListOfDeliveryTimesTypes extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final timeValues = useState<List<String>>(List<String>.empty());
    final selectedTimeIndex = useState<int?>(null);
    useEffect(() {
      // Box<DeliveryTime> box = Hive.box<DeliveryTime>('deliveryTime');
      // DeliveryTime? deliveryTime = box.get('deliveryTime');
      // if (deliveryTime == null) {
      //   DeliveryTime newDeliveryTime = new DeliveryTime();
      //   newDeliveryTime.value = DeliveryTimeEnum.now;
      //   box.put('deliveryTime', newDeliveryTime);
      // }

      List<String> deliveryTimeOptions = [];
      var startTime = DateTime.now();

      startTime = startTime.add(Duration(minutes: 40));
      startTime = startTime.setMinute((startTime.minute / 10).ceil() * 10);
      var val = '';
      while (startTime.hour < 3 || startTime.hour > 10) {
        val = '${startTime.format('Hm').toString()}';
        startTime = startTime.add(Duration(minutes: 20));
        startTime = startTime.setMinute((startTime.minute / 10).ceil() * 10);

        val = val + ' - ${startTime.format('Hm').toString()}';
        deliveryTimeOptions.add(val);

        startTime = startTime.add(Duration(minutes: 40));
        startTime = startTime.setMinute((startTime.minute / 10).ceil() * 10);
      }
      timeValues.value = deliveryTimeOptions;
    }, []);
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          n.NikuText(
            tr('orderCreate.chooseDeliveryTime'),
            style: n.NikuTextStyle(fontSize: 24, color: Colors.black),
          ),
          SizedBox(height: 30,),
          n.NikuButton(Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FaIcon(
                FontAwesomeIcons.clock,
                color: Colors.black,
              ),
              SizedBox(
                width: 20,
              ),
              n.NikuText(
                tr('orderCreate.deliverNow'),
                style: n.NikuTextStyle(fontSize: 20, color: Colors.black),
              ),
              Spacer(),
              Icon(
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

              DeliveryTime newDeliveryTime =
              DeliveryTime();
              newDeliveryTime.value = DeliveryTimeEnum.now;
              Box<DeliveryTime> box =
              Hive.box<DeliveryTime>('deliveryTime');
              box.put('deliveryTime', newDeliveryTime);
              Navigator.of(context).pop();
            },
          SizedBox(height: 15,),
          n.NikuButton(Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FaIcon(
                FontAwesomeIcons.clock,
                color: Colors.black,
              ),
              SizedBox(
                width: 20,
              ),
              n.NikuText(
                tr('orderCreate.deliverLater'),
                style: n.NikuTextStyle(fontSize: 20, color: Colors.black),
              ),
              Spacer(),
              Icon(
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
                  builder: (context) => Padding(padding: EdgeInsets.all(15), child: Column(
                    mainAxisSize: MainAxisSize.min, children: [
                    n.NikuText(
                      tr('orderCreate.chooseTime'),
                      style: n.NikuTextStyle(fontSize: 24, color: Colors.black),
                    ),
                    SizedBox(height: 15,),
                    SizedBox(
                      height: 150,
                      child: CupertinoPicker(
                        useMagnifier: true,
                        magnification: 1.3,
                        backgroundColor: Colors.white,
                        itemExtent: 25, //height of each item
                        diameterRatio:1,
                        // looping: true,
                        children: timeValues.value.map((item)=> Center(
                          child: Text(item,
                            style: TextStyle(fontSize: 15),),
                        )).toList(),
                        onSelectedItemChanged: (index) {
                          selectedTimeIndex.value = index;
                        },
                      ),
                    ),
                    SizedBox(height: 15,),
                    Container(width: double.infinity, child: n.NikuButton.elevated(Text(
                      tr(
                        'choose',
                      ),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ))
                      ..bg = AppColors.mainColor
                      ..color = Colors.white
                      ..py = 15
                      ..rounded = 20
                      ..onPressed = () {
                      int? selectedIndex = selectedTimeIndex.value;
                      selectedIndex ??= 0;
                          Box<DeliverLaterTime> box =
                          Hive.box<DeliverLaterTime>(
                              'deliveryLaterTime');
                          DeliverLaterTime deliverLaterTime =
                          DeliverLaterTime();
                          deliverLaterTime.value =
                          timeValues.value[selectedIndex];
                          box.put('deliveryLaterTime',
                              deliverLaterTime);

                          DeliveryTime newDeliveryTime =
                          DeliveryTime();
                          newDeliveryTime.value = DeliveryTimeEnum.later;
                          Box<DeliveryTime> deliveryTimeBox =
                          Hive.box<DeliveryTime>('deliveryTime');
                          deliveryTimeBox.put('deliveryTime', newDeliveryTime);
                          Navigator.of(context)..pop()..pop();
                      },)
                  ],),));
            }
        ],
      ),
    );
  }
}
