import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:niku/niku.dart' as n;
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../models/city.dart';
import '../models/delivery_location_data.dart';
import '../models/delivery_type.dart';
import '../models/my_address.dart';
import '../models/stock.dart';
import '../models/terminals.dart';
import '../models/user.dart';
import '../models/yandex_geo_data.dart';
import '../utils/debouncer.dart';

class AddressSearchModal extends HookWidget {
  final void Function(Point)? onSetLocation;

  final _debouncer = Debouncer(milliseconds: 500);
  final TextEditingController queryController = TextEditingController();

  AddressSearchModal({Key? key, required this.onSetLocation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    useMemoized(() => GlobalKey<FormBuilderState>());
    final currentCity = Hive.box<City>('currentCity').get('currentCity');
    final suggestedData =
        useState<List<YandexGeoData>>(List<YandexGeoData>.empty());
    final queryText = useState<String>('');
    final myAddresses = useState<List<MyAddress>>(List<MyAddress>.empty());

    Future<void> getMyAddresses() async {
      Box box = Hive.box<User>('user');
      User? currentUser = box.get('user');
      if (currentUser != null) {
        Map<String, String> requestHeaders = {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${currentUser.userToken}'
        };
        var url = Uri.https('api.lesailes.uz', '/api/address/my_addresses');
        var response = await http.get(url, headers: requestHeaders);
        if (response.statusCode == 200) {
          var json = jsonDecode(response.body);
          List<MyAddress> addressList = List<MyAddress>.from(
              json['data'].map((m) => MyAddress.fromJson(m)).toList());
          myAddresses.value = addressList;
        }
      }
    }

    Future<void> getSuggestions(String query) async {
      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json'
      };
      String prefix = '${currentCity!.name}, ';
      query = '${query}${prefix}';
      var url =
          Uri.https('api.lesailes.uz', 'api/geocode/query', {'query': query});
      queryText.value = query;
      var response = await http.get(url, headers: requestHeaders);
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        List<YandexGeoData> terminal = List<YandexGeoData>.from(
            json['data'].map((m) => YandexGeoData.fromJson(m)).toList());
        suggestedData.value = terminal;
      }
    }

    Widget renderItems(BuildContext context) {
      if (queryText.value.isEmpty) {
        if (myAddresses.value.isEmpty) {
          return const Center(
            child: Text('Введите текст запроса'),
          );
        } else {
          return ListView.separated(
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () async {
                    MyAddress address = myAddresses.value[index];
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => DeliveryModal(
                    //           geoData: suggestedData.value[index],
                    //         )));
                    if (address.lat != null) {
                      onSetLocation!(Point(
                        latitude: double.parse(address.lat!),
                        longitude: double.parse(address.lon!),
                      ));
                      // Navigator.of(context).pop();
                      DeliveryLocationData deliveryData = DeliveryLocationData(
                          house: address.house ?? '',
                          flat: address.flat ?? '',
                          entrance: address.entrance ?? '',
                          doorCode: address.doorCode ?? '',
                          label: address.label ?? '',
                          lat: double.parse(address.lat!),
                          lon: double.parse(address.lon!),
                          address: address.address ?? '');
                      // geoData.addressItems?.forEach((item) async {
                      //   if (item.kind == 'province' || item.kind == 'area') {
                      //     Map<String, String> requestHeaders = {
                      //       'Content-type': 'application/json',
                      //       'Accept': 'application/json'
                      //     };
                      //     var url =
                      //     Uri.https('api.lesailes.uz', '/api/cities/public');
                      //     var response =
                      //     await http.get(url, headers: requestHeaders);
                      //     if (response.statusCode == 200) {
                      //       var json = jsonDecode(response.body);
                      //       List<City> cityList = List<City>.from(
                      //           json['data'].map((m) => City.fromJson(m)).toList());
                      //       for (var element in cityList) {
                      //         if (element.name == item.name) {
                      //           Hive.box<City>('currentCity')
                      //               .put('currentCity', element);
                      //         }
                      //       }
                      //     }
                      //   }
                      // });
                      final Box<DeliveryLocationData> deliveryLocationBox =
                          Hive.box<DeliveryLocationData>(
                              'deliveryLocationData');
                      deliveryLocationBox.put(
                          'deliveryLocationData', deliveryData);
                      Map<String, String> requestHeaders = {
                        'Content-type': 'application/json',
                        'Accept': 'application/json'
                      };

                      var url = Uri.https(
                          'api.lesailes.uz',
                          'api/terminals/find_nearest',
                          {'lat': address.lat, 'lon': address.lon});
                      var response =
                          await http.get(url, headers: requestHeaders);
                      if (response.statusCode == 200) {
                        var json = jsonDecode(response.body);
                        List<Terminals> terminal = List<Terminals>.from(
                            json['data']['items']
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

                        Navigator.of(context)
                          ..pop()
                          ..pop();
                      } else {
                        print(response.body);
                      }
                      // DeliveryLocationData deliveryData = DeliveryLocationData(
                      //     house: address.house ?? '',
                      //     flat: address.flat ?? '',
                      //     entrance: address.entrance ?? '',
                      //     doorCode: address.doorCode ?? '',
                      //     lat: double.parse(address.lat!),
                      //     lon: double.parse(address.lon!),
                      //     address: address.address ?? '');
                      // final Box<DeliveryLocationData> deliveryLocationBox =
                      // Hive.box<DeliveryLocationData>(
                      //     'deliveryLocationData');
                      // deliveryLocationBox.put(
                      //     'deliveryLocationData', deliveryData);
                      // Box<DeliveryType> box =
                      // Hive.box<DeliveryType>('deliveryType');
                      // DeliveryType newDeliveryType = DeliveryType();
                      // newDeliveryType.value = DeliveryTypeEnum.deliver;
                      // box.put('deliveryType', newDeliveryType);
                      //
                      // Map<String, String> requestHeaders = {
                      //   'Content-type': 'application/json',
                      //   'Accept': 'application/json'
                      // };
                      //
                      // var url = Uri.https(
                      //     'api.lesailes.uz', 'api/terminals/find_nearest', {
                      //   'lat': address.lat!.toString(),
                      //   'lon': address.lon!.toString()
                      // });
                      // var response =
                      // await http.get(url, headers: requestHeaders);
                      // if (response.statusCode == 200) {
                      //   var json = jsonDecode(response.body);
                      //   List<Terminals> terminal = List<Terminals>.from(
                      //       json['data']['items']
                      //           .map((m) => Terminals.fromJson(m))
                      //           .toList());
                      //   Box<Terminals> transaction =
                      //   Hive.box<Terminals>('currentTerminal');
                      //   if (terminal.isNotEmpty) {
                      //     transaction.put('currentTerminal', terminal[0]);
                      //
                      //     var stockUrl = Uri.https(
                      //         'api.lesailes.uz',
                      //         'api/terminals/get_stock',
                      //         {'terminal_id': terminal[0].id.toString()});
                      //     var stockResponse =
                      //     await http.get(stockUrl, headers: requestHeaders);
                      //     if (stockResponse.statusCode == 200) {
                      //       var json = jsonDecode(stockResponse.body);
                      //       Stock newStockData = Stock(
                      //           prodIds: List<int>.from(json[
                      //           'data']) /* json['data'].map((id) => id as int).toList()*/);
                      //       Box<Stock> box = Hive.box<Stock>('stock');
                      //       box.put('stock', newStockData);
                      //     }
                      //   }
                      //
                      //   Navigator.of(context).pop();
                      // }
                    }
                  },
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.bookmark_border_outlined),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            myAddresses.value[index].label != null
                                ? Text(
                                    myAddresses.value[index].label
                                            ?.toUpperCase() ??
                                        '',
                                    style: const TextStyle())
                                : const SizedBox(height: 3),
                            Text(myAddresses.value[index].address ?? '',
                                style: TextStyle(
                                    color:
                                        myAddresses.value[index].label != null
                                            ? Colors.grey
                                            : Colors.black)),
                            Text(myAddresses.value[index].house ?? '',
                                style: TextStyle(
                                    color:
                                        myAddresses.value[index].house != null
                                            ? Colors.grey
                                            : Colors.black)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return const Divider();
              },
              itemCount: myAddresses.value.length);
        }
      } else if (suggestedData.value.isEmpty) {
        return const Center(
          child: Text('Ничего не найдено'),
        );
      } else {
        return ListView.separated(
            itemBuilder: (context, index) {
              return ListTile(
                onTap: () {
                  onSetLocation!(Point(
                    latitude: double.parse(
                        suggestedData.value[index].coordinates.lat),
                    longitude: double.parse(
                        suggestedData.value[index].coordinates.long),
                  ));
                  Navigator.of(context).pop();

                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => DeliveryModal(
                  //           geoData: suggestedData.value[index],
                  //         )));
                },
                title: Text(suggestedData.value[index].title),
                subtitle: Text(suggestedData.value[index].description),
              );
            },
            separatorBuilder: (context, index) {
              return const Divider();
            },
            itemCount: suggestedData.value.length);
      }
    }

    useEffect(() {
      getMyAddresses();
    }, []);

    return SafeArea(
        child: Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      padding: const EdgeInsets.only(top: 20, left: 15, right: 15),
      child: Column(
        children: [
          Container(
            height: 65,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 5,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ]),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(
                  width: 10,
                ),
                Flexible(
                  child: TextField(
                    style: const TextStyle(
                      fontSize: 17,
                    ),
                    controller: queryController,
                    onChanged: (String val) {
                      _debouncer.run(() => getSuggestions(val));
                    },
                    decoration: InputDecoration(
                      hintText: 'Введите адрес',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      prefixIcon: Center(
                        widthFactor: 1,
                        child: Text(
                          '${currentCity!.name}, ',
                          style: const TextStyle(fontSize: 17),
                        ),
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(),
                InkWell(
                  onTap: () {
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => DeliveryModal()));
                  },
                  child: n.NikuButton(n.NikuText(tr('cancel'),
                      style: n.NikuTextStyle(color: Colors.black)))
                    ..onPressed = () {
                      Navigator.of(context).pop();
                    },
                )
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(child: renderItems(context))
        ],
      ),
    ));
  }
}
