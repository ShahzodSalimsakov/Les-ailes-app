import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:niku/niku.dart' as n;

import '../models/city.dart';
import '../models/delivery_location_data.dart';
import '../models/delivery_type.dart';
import '../models/stock.dart';
import '../models/terminals.dart';
import '../models/user.dart';
import '../models/yandex_geo_data.dart';
import '../utils/colors.dart';

class DeliverFieldsModal extends HookWidget {
  final YandexGeoData geoData;

  const DeliverFieldsModal({Key? key, required this.geoData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final Box<DeliveryLocationData> deliveryLocationBox =
        Hive.box<DeliveryLocationData>('deliveryLocationData');
    DeliveryLocationData? deliveryLocationData =
        deliveryLocationBox.get('deliveryLocationData');
    String? houseDefaultValue = '';
    for (var element in geoData.addressItems!) {
      if (element.kind == 'house') {
        houseDefaultValue = element.name;
      }
    }

    final houseText = useState<String>(houseDefaultValue ?? '');
    final flatText = useState<String>('');
    final entranceText = useState<String>('');
    final doorCodeText = useState<String>('');
    final addressLabel = useState<String>('');
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                n.NikuText(
                  tr('deliveryBottomSheet.specifyAddress'),
                  style: n.NikuTextStyle(fontSize: 20),
                )
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            n.NikuButton(Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: n.NikuText(
                      geoData.formatted,
                      style: n.NikuTextStyle(color: Colors.black, fontSize: 18),
                    )),
                const Icon(Icons.edit_location_outlined, color: Colors.grey)
              ],
            ))
              ..p = 20
              ..bg = Colors.grey.shade100
              ..rounded = 15
              ..onPressed = () {
                Navigator.of(context).pop();
              },
            const SizedBox(
              height: 20,
            ),
            Form(
              child: FormBuilder(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 15,
                    childAspectRatio: 2.8,
                    shrinkWrap: true,
                    children: [
                      FormBuilderTextField(
                        name: 'house',
                        // autofocus: true,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            hintText: tr("house"),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide.none),
                            filled: true,
                            fillColor: Colors.grey.shade100),
                        initialValue: houseText.value,
                      ),
                      FormBuilderTextField(
                        name: 'flat',
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: tr("flat"),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide.none),
                            filled: true,
                            fillColor: Colors.grey.shade100),
                        initialValue: flatText.value,
                      ),
                      FormBuilderTextField(
                        name: 'entrance',
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: tr("entrance"),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide.none),
                            filled: true,
                            fillColor: Colors.grey.shade100),
                        initialValue: entranceText.value,
                      ),
                      FormBuilderTextField(
                        name: 'doorCode',
                        // keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: tr("intercom"),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide.none),
                            filled: true,
                            fillColor: Colors.grey.shade100),
                        initialValue: doorCodeText.value,
                      ),
                      FormBuilderTextField(
                        name: 'addressLabel',
                        // keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: tr("addressName"),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide.none),
                            filled: true,
                            fillColor: Colors.grey.shade100),
                        initialValue: addressLabel.value,
                      ),
                    ]),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              width: double.infinity,
              height: 60,
              child: n.NikuButton(n.NikuText(
                tr('deliveryBottomSheet.continue'),
                style: n.NikuTextStyle(color: Colors.white, fontSize: 20),
              ))
                ..bg = AppColors.mainColor
                ..rounded = 20
                ..onPressed = () async {
                  _formKey.currentState!.save();
                  var formValue = _formKey.currentState!.value;
                  DeliveryLocationData deliveryData = DeliveryLocationData(
                      house: formValue['house'] ?? '',
                      flat: formValue['flat'] ?? '',
                      entrance: formValue['entrance'] ?? '',
                      doorCode: formValue['doorCode'] ?? '',
                      label: formValue['label'] ?? '',
                      lat: double.parse(geoData.coordinates.lat),
                      lon: double.parse(geoData.coordinates.long),
                      address: geoData.formatted ?? '');
                  geoData.addressItems?.forEach((item) async {
                    if (item.kind == 'province' || item.kind == 'area') {
                      Map<String, String> requestHeaders = {
                        'Content-type': 'application/json',
                        'Accept': 'application/json'
                      };
                      var url =
                          Uri.https('api.lesailes.uz', '/api/cities/public');
                      var response =
                          await http.get(url, headers: requestHeaders);
                      if (response.statusCode == 200) {
                        var json = jsonDecode(response.body);
                        List<City> cityList = List<City>.from(
                            json['data'].map((m) => City.fromJson(m)).toList());
                        for (var element in cityList) {
                          if (element.name == item.name) {
                            Hive.box<City>('currentCity')
                                .put('currentCity', element);
                          }
                        }
                      }
                    }
                  });
                  deliveryLocationBox.put('deliveryLocationData', deliveryData);
                  Map<String, String> requestHeaders = {
                    'Content-type': 'application/json',
                    'Accept': 'application/json'
                  };

                  var url = Uri.https(
                      'api.lesailes.uz', 'api/terminals/find_nearest', {
                    'lat': geoData.coordinates.lat,
                    'lon': geoData.coordinates.long
                  });
                  var response = await http.get(url, headers: requestHeaders);
                  if (response.statusCode == 200) {
                    var json = jsonDecode(response.body);
                    List<Terminals> terminal = List<Terminals>.from(json['data']
                            ['items']
                        .map((m) => Terminals.fromJson(m))
                        .toList());
                    Box<Terminals> transaction =
                        Hive.box<Terminals>('currentTerminal');
                    transaction.put('currentTerminal', terminal[0]);

                    var stockUrl = Uri.https(
                        'api.lesailes.uz',
                        'api/terminals/get_stock',
                        {'terminal_id': terminal[0].id.toString()});
                    var stockResponse =
                        await http.get(stockUrl, headers: requestHeaders);
                    if (stockResponse.statusCode == 200) {
                      var json = jsonDecode(stockResponse.body);
                      Stock newStockData = Stock(
                          prodIds: List<int>.from(json[
                              'data']) /* json['data'].map((id) => id as int).toList()*/);
                      Box<Stock> box = Hive.box<Stock>('stock');
                      box.put('stock', newStockData);
                    }

                    Box<DeliveryType> box =
                        Hive.box<DeliveryType>('deliveryType');
                    DeliveryType newDeliveryType = DeliveryType();
                    newDeliveryType.value = DeliveryTypeEnum.deliver;
                    box.put('deliveryType', newDeliveryType);

                    Box userBox = Hive.box<User>('user');
                    User currentUser = userBox.get('user');
                    if (currentUser != null) {
                      Map<String, String> requestHeaders = {
                        'Content-type': 'application/json',
                        'Accept': 'application/json',
                        'Authorization': 'Bearer ${currentUser.userToken}'
                      };
                      var url = Uri.https('api.lesailes.uz', '/api/address/new');
                      var formData = {
                        'lat': geoData.coordinates.lat,
                        'lon': geoData.coordinates.long,
                        "label": formValue['addressLabel'] ?? '',
                        "addressId": '',
                        "house": formValue['house'] ?? '',
                        "flat": formValue['flat'] ?? '',
                        "entrance": formValue['entrance'] ?? '',
                        "door_code": formValue['doorCode'] ?? '',
                        "address": geoData.formatted ?? '',
                        "comments": "",
                        "floor": ''
                      };
                      var response = await http.post(url,
                          headers: requestHeaders, body: jsonEncode(formData));
                      if (response.statusCode == 200) {
                        var json = jsonDecode(response.body);
                        print(json);
                      } else {
                        print(response.body);
                      }
                    }

                    Navigator.of(context)
                      ..pop()
                      ..pop();
                  }
                },
            ),
          ],
        ),
      ),
    );
  }
}
