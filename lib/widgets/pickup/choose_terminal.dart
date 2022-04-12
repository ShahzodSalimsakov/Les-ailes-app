import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:niku/niku.dart' as n;

import '../../models/delivery_type.dart';
import '../../models/pickup_type.dart';
import '../../models/stock.dart';
import '../../models/temp_terminals.dart';
import '../../models/terminals.dart';
import '../../utils/colors.dart';

class ChooseSelecteTerminal extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<TempTerminals>>(
        valueListenable:
        Hive.box<TempTerminals>('tempTerminal').listenable(),
    builder: (context, box, _) {
    TempTerminals? selectedTerminal = box.get('tempTerminal');
    return Container(
        width: double.infinity,
        height: 60,
        margin: const EdgeInsets.only(top: 20),
        child: n.NikuButton(n.NikuText(
          tr('pickup.buttonSelectThisBranch'),
          style:
          n.NikuTextStyle(color: Colors.white, fontSize: 20),
        ))
          ..bg = selectedTerminal == null
              ? Colors.grey.shade200
              : AppColors.mainColor
          ..rounded = 20
          ..onPressed = () async {
            if (selectedTerminal == null) {
              return;
            }

            // Box<Terminals> transaction =
            //     Hive.box<Terminals>('currentTerminal');
            // transaction.put('currentTerminal', selectedTerminal);

            Map<String, String> requestHeaders = {
              'Content-type': 'application/json',
              'Accept': 'application/json'
            };

            var stockUrl = Uri.https(
                'api.lesailes.uz',
                'api/terminals/get_stock',
                {'terminal_id': selectedTerminal.id.toString()});
            var stockResponse =
            await http.get(stockUrl, headers: requestHeaders);
            if (stockResponse.statusCode == 200) {
              var json = jsonDecode(stockResponse.body);
              Stock newStockData = Stock(
                  prodIds: List<int>.from(json[
                  'data']) /* json['data'].map((id) => id as int).toList()*/);
              Box<Stock> box = Hive.box<Stock>('stock');
              box.put('stock', newStockData);

              Box<DeliveryType> deliveryBox =
              Hive.box<DeliveryType>('deliveryType');
              DeliveryType newDeliveryType = DeliveryType();
              newDeliveryType.value = DeliveryTypeEnum.pickup;
              deliveryBox.put('deliveryType', newDeliveryType);

              Box<Terminals> terminalBox =
              Hive.box<Terminals>('currentTerminal');
              Terminals currentTerminal = Terminals.fromJson(selectedTerminal.toJson());
              terminalBox.put('currentTerminal', currentTerminal);

              // Box<DeliveryLocationData> deliveryLocationBox = Hive.box<DeliveryLocationData>('deliveryLocationData');
              // deliveryLocationBox.delete('deliveryLocationData');
              // DeliveryLocationData? deliveryLocationData =
              // deliveryLocationBox.get('deliveryLocationData');

              Box<PickupType> transaction =
              Hive.box<PickupType>('pickupType');
              transaction.delete('pickupType');
              Navigator.of(context).pop();
            }
          });
    });
  }
}