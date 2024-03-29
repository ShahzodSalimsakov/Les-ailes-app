import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../models/delivery_location_data.dart';
import '../basket.dart';

class BasketListen extends StatelessWidget {
  const BasketListen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<DeliveryLocationData>>(
        valueListenable:
            Hive.box<DeliveryLocationData>('deliveryLocationData').listenable(),
        builder: (context, box, _) {
          print('deliveryType Listen');
          return const BasketWidget();
        });
  }
}
