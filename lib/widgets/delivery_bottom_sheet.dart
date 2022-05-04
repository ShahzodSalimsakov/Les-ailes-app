import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive/hive.dart';
import 'package:les_ailes/utils/colors.dart';
import 'package:les_ailes/widgets/address_search_modal.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:http/http.dart' as http;
import 'package:niku/niku.dart' as n;

import '../models/delivery_location_data.dart';
import '../models/delivery_type.dart';
import '../models/stock.dart';
import '../models/terminals.dart';
import '../models/yandex_geo_data.dart';
import 'delivery_fields_modal.dart';

class DeliveryBottomSheet extends HookWidget {
  late Point? currentPoint;
  late void Function(Point)? onSetLocation;

  DeliveryBottomSheet({Key? key, this.currentPoint, this.onSetLocation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final geoData = useState<YandexGeoData?>(null);
    var currentTerminal = useState<Terminals?>(null);
    final Box<DeliveryLocationData> deliveryLocationBox =
        Hive.box<DeliveryLocationData>('deliveryLocationData');
    DeliveryLocationData? deliveryLocationData =
        deliveryLocationBox.get('deliveryLocationData');

    var notFoundText = useState<String>('nearest_terminal_not_found');

    Future<void> getPointData() async {
      if (currentPoint != null) {
        Map<String, String> requestHeaders = {
          'Content-type': 'application/json',
          'Accept': 'application/json'
        };
        var url = Uri.https('api.lesailes.uz', 'api/geocode', {
          'lat': currentPoint!.latitude.toString(),
          'lon': currentPoint!.longitude.toString()
        });
        var response = await http.get(url, headers: requestHeaders);
        if (response.statusCode == 200) {
          var json = jsonDecode(response.body);
          geoData.value = YandexGeoData.fromJson(json['data']);

          var url = Uri.https('api.lesailes.uz', 'api/terminals/find_nearest', {
            'lat': currentPoint!.latitude.toString(),
            'lon': currentPoint!.longitude.toString()
          });
          response = await http.get(url, headers: requestHeaders);
          if (response.statusCode == 200) {
            var json = jsonDecode(response.body);
            List<Terminals> terminal = List<Terminals>.from(json['data']
                    ['items']
                .map((m) => Terminals.fromJson(m))
                .toList());
            notFoundText.value = json['data']['errorMessage'];
            if (terminal.isNotEmpty) {
              currentTerminal.value = terminal[0];
            } else {
              currentTerminal.value = null;
            }
          } else {
            currentTerminal.value = null;
            notFoundText.value = 'nearest_terminal_not_found';
          }
        }
      }
    }

    useEffect(() {
      getPointData();
      return null;
    }, [currentPoint]);

    return Container(
        // height: 200,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            n.NikuButton(Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: n.NikuText(
                      currentTerminal.value == null
                          ? tr(notFoundText.value)
                          : geoData.value?.title,
                      style: n.NikuTextStyle(color: Colors.grey, fontSize: 18),
                    )),
                const Icon(Icons.keyboard_arrow_down, color: Colors.grey)
              ],
            ))
              ..p = 20
              ..bg = Colors.grey.shade100
              ..rounded = 15
              ..onPressed = () {
                showBarModalBottomSheet(
                    expand: false,
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (context) =>
                        AddressSearchModal(onSetLocation: onSetLocation));
              },
            Container(
              width: double.infinity,
              height: 60,
              margin: const EdgeInsets.only(top: 20),
              child: n.NikuButton(n.NikuText(
                tr('deliveryBottomSheet.continue'),
                style: n.NikuTextStyle(color: Colors.white, fontSize: 20),
              ))
                ..bg = currentTerminal.value == null
                    ? Colors.grey.shade200
                    : AppColors.mainColor
                ..rounded = 20..onPressed = () {
                  if (currentTerminal.value == null) {
                    return;
                  }

                  showBarModalBottomSheet(
                      expand: false,
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) => DeliverFieldsModal(geoData: geoData.value!));
                },
            )
          ],
        ));
  }
}
