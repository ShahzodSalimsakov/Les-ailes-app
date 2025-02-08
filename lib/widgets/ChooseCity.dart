import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:les_ailes/models/city.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:les_ailes/models/delivery_location_data.dart';
import 'package:les_ailes/models/pay_type.dart';
import 'package:les_ailes/models/stock.dart';
import 'package:les_ailes/models/terminals.dart';
import 'package:les_ailes/utils/colors.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../models/delivery_type.dart';

class ChooseCity extends HookWidget {
  const ChooseCity({super.key});

  Widget cityModal(BuildContext context, List<City> cities) {
    City? currentCity = Hive.box<City>('currentCity').get('currentCity');
    return Material(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text(
                  tr("chooseCity"),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () => Navigator.of(context).pop(),
              ),
              const Divider(
                color: Colors.grey,
                height: 1,
              ),
              ListView.separated(
                  separatorBuilder: (context, index) {
                    return const Divider();
                  },
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: cities.length,
                  itemBuilder: (context, index) {
                    var locale = context.locale.toString();
                    var cityName = '';
                    switch (locale) {
                      case "uz":
                        cityName = cities[index].nameUz!;
                        break;
                      case "ru":
                        cityName = cities[index].name;
                        break;
                      case "en":
                        cityName = cities[index].nameEn!;
                        break;
                      default:
                        cityName = cities[index].name;
                        break;
                    }
                    return ListTile(
                      title: Text(
                        cityName,
                        style: const TextStyle(color: Colors.black),
                      ),
                      trailing: currentCity != null &&
                              currentCity.id == cities[index].id
                          ? const Icon(
                              Icons.check,
                              color: AppColors.mainColor,
                            )
                          : null,
                      selected: currentCity != null &&
                          currentCity.id == cities[index].id,
                      onTap: () {
                        Box<City> transaction = Hive.box<City>('currentCity');
                        transaction.put('currentCity', cities[index]);
                        final Box<DeliveryLocationData> deliveryLocationBox =
                            Hive.box<DeliveryLocationData>(
                                'deliveryLocationData');
                        deliveryLocationBox.delete('deliveryLocationData');
                        Box<DeliveryType> box =
                            Hive.box<DeliveryType>('deliveryType');
                        box.delete('deliveryType');
                        Box<Terminals> terminalsBox =
                            Hive.box<Terminals>('currentTerminal');
                        terminalsBox.delete('currentTerminal');
                        Box<PayType> payTypeBox = Hive.box<PayType>('payType');
                        payTypeBox.delete('payType');
                        Box<Stock> stockBox = Hive.box<Stock>('stock');
                        stockBox.delete('stock');
                        Navigator.of(context).pop();
                      },
                    );
                  }),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final cities = useState<List<City>>(List<City>.empty());

    Future<void> loadCities() async {
      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json'
      };
      var url = Uri.https('api.lesailes.uz', '/api/cities/public');
      var response = await http.get(url, headers: requestHeaders);
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        List<City> cityList =
            List<City>.from(json['data'].map((m) => City.fromJson(m)).toList());
        cities.value = cityList;
        City? currentCity = Hive.box<City>('currentCity').get('currentCity');
        if (currentCity == null) {
          Hive.box<City>('currentCity').put('currentCity', cityList[0]);
        }
      }
    }

    useEffect(() {
      loadCities();
    }, []);

    return ValueListenableBuilder<Box<City>>(
        valueListenable: Hive.box<City>('currentCity').listenable(),
        builder: (context, box, _) {
          City? currentCity = box.get('currentCity');
          var locale = context.locale.toString();
          var cityName = '';
          switch (locale) {
            case "uz":
              cityName = currentCity?.nameUz ?? '';
              break;
            case "ru":
              cityName = currentCity?.name ?? '';
              break;
            case "en":
              cityName = currentCity?.nameEn ?? '';
              break;
            default:
              cityName = currentCity?.name ?? '';
              break;
          }
          return GestureDetector(
              // contentPadding: const EdgeInsets.only(left: 2, top: 0, bottom: 0),
              child: Container(
                padding: const EdgeInsets.only(bottom: 10),
                width: double.infinity,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      currentCity != null ? cityName : tr('yourCity'),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const Icon(Icons.keyboard_arrow_down),
                  ],
                ),
              ),
              onTap: () => showMaterialModalBottomSheet(
                    expand: false,
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (context) => cityModal(context, cities.value),
                  ));
        });
  }
}
