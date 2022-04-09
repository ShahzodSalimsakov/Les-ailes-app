// import 'package:dart_date/dart_date.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
// import 'package:hive/hive.dart';
//
// import '../../models/deliver_later_time.dart';
//
// class TimerPicker extends HookWidget {
//   @override
//   Widget build(BuildContext context) {
//     final timeValues = useState<List<String>>(List<String>.empty());
//     final selectedTimeIndex = useState<int?>(null);
//     useEffect(() {
//       // Box<DeliveryTime> box = Hive.box<DeliveryTime>('deliveryTime');
//       // DeliveryTime? deliveryTime = box.get('deliveryTime');
//       // if (deliveryTime == null) {
//       //   DeliveryTime newDeliveryTime = new DeliveryTime();
//       //   newDeliveryTime.value = DeliveryTimeEnum.now;
//       //   box.put('deliveryTime', newDeliveryTime);
//       // }
//
//       List<String> deliveryTimeOptions = [];
//       var startTime = DateTime.now();
//
//       startTime = startTime.add(Duration(minutes: 40));
//       startTime = startTime.setMinute((startTime.minute / 10).ceil() * 10);
//       var val = '';
//       while (startTime.hour < 3 || startTime.hour > 10) {
//         val = '${startTime.format('Hm').toString()}';
//         startTime = startTime.add(Duration(minutes: 20));
//         startTime = startTime.setMinute((startTime.minute / 10).ceil() * 10);
//
//         val = val + ' - ${startTime.format('Hm').toString()}';
//         deliveryTimeOptions.add(val);
//
//         startTime = startTime.add(Duration(minutes: 40));
//         startTime = startTime.setMinute((startTime.minute / 10).ceil() * 10);
//       }
//       timeValues.value = deliveryTimeOptions;
//     }, []);
//
//     return Padding(padding: EdgeInsets.all(15), child: Column(
//       mainAxisSize: MainAxisSize.min, children: [
//       n.NikuText(
//         tr('orderCreate.chooseTime'),
//         style: n.NikuTextStyle(fontSize: 24, color: Colors.black),
//       ),
//       SizedBox(height: 15,),
//       CupertinoPicker(
//         // magnification: 1.5,
//         backgroundColor: Colors.white,
//         itemExtent: 25, //height of each item
//         diameterRatio:1,
//         // looping: true,
//         children: timeValues.value.map((item)=> Center(
//           child: Text(item,
//             style: TextStyle(fontSize: 15),),
//         )).toList(),
//         onSelectedItemChanged: (index) {
//           selectedTimeIndex.value = index;
//         },
//       ),
//       SizedBox(height: 15,),
//       Container(width: double.infinity, child: n.NikuButton.elevated(Text(
//         tr(
//           'choose',
//         ),
//         style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
//       ))
//         ..bg = selectedTimeIndex.value == null ? Colors.grey.shade100 : AppColors.mainColor
//         ..color = Colors.white
//         ..py = 15
//         ..rounded = 20
//         ..onPressed = () {
//           if (selectedTimeIndex.value != null) {
//             Box<DeliverLaterTime> box =
//             Hive.box<DeliverLaterTime>(
//                 'deliveryLaterTime');
//             DeliverLaterTime? deliveryTime =
//             box.get('deliveryLaterTime');
//             DeliverLaterTime deliverLaterTime =
//             DeliverLaterTime();
//             deliverLaterTime.value =
//             timeValues.value[selectedTimeIndex.value!];
//             box.put('deliveryLaterTime',
//                 deliverLaterTime);
//             Navigator.of(context)..pop()..pop();
//           }
//         },)
//     ],),);
//   }
// }