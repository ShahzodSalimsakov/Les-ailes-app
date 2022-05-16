import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:les_ailes/models/delivery_type.dart';
import 'package:les_ailes/models/stock.dart';
import 'package:les_ailes/models/terminals.dart';
import 'package:les_ailes/models/yandex_geo_data.dart';
import 'package:les_ailes/utils/colors.dart';
import 'package:les_ailes/widgets/ChooseCity.dart';
import 'package:les_ailes/widgets/header.dart';
import 'package:les_ailes/widgets/leftMenu.dart';
import 'package:les_ailes/widgets/productList.dart';
import 'package:les_ailes/widgets/productListStateful.dart';
import 'package:les_ailes/widgets/productTabListStateful.dart';
import 'package:les_ailes/widgets/slider.dart';
import 'package:les_ailes/widgets/ui/fixed_basket.dart';
import 'package:les_ailes/widgets/way_to_receive_an_order.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'models/delivery_location_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ScrollController _parentScrollController = ScrollController();

  // Future<void> setLocation(LocationData location,
  //     DeliveryLocationData deliveryData, String house) async {
  //   final Box<DeliveryLocationData> deliveryLocationBox =
  //       Hive.box<DeliveryLocationData>('deliveryLocationData');
  //   deliveryLocationBox.put('deliveryLocationData', deliveryData);
  //
  //   Box<DeliveryType> box = Hive.box<DeliveryType>('deliveryType');
  //   DeliveryType? currentDeliver = box.get('deliveryType');
  //   if (currentDeliver == null) {
  //     DeliveryType deliveryType = DeliveryType();
  //     deliveryType.value = DeliveryTypeEnum.deliver;
  //     Box<DeliveryType> box = Hive.box<DeliveryType>('deliveryType');
  //     box.put('deliveryType', deliveryType);
  //   } else if (currentDeliver.value != DeliveryTypeEnum.pickup) {
  //     DeliveryType deliveryType = DeliveryType();
  //     deliveryType.value = DeliveryTypeEnum.pickup;
  //     Box<DeliveryType> box = Hive.box<DeliveryType>('deliveryType');
  //     box.put('deliveryType', deliveryType);
  //   }
  //
  //   Map<String, String> requestHeaders = {
  //     'Content-type': 'application/json',
  //     'Accept': 'application/json'
  //   };
  //
  //   var url = Uri.https('api.lesailes.uz', 'api/terminals/find_nearest', {
  //     'lat': location.latitude.toString(),
  //     'lon': location.longitude.toString()
  //   });
  //   var response = await http.get(url, headers: requestHeaders);
  //   if (response.statusCode == 200) {
  //     var json = jsonDecode(response.body);
  //     List<Terminals> terminal = List<Terminals>.from(
  //         json['data']['items'].map((m) => Terminals.fromJson(m)).toList());
  //     Box<Terminals> transaction = Hive.box<Terminals>('currentTerminal');
  //     if (terminal.isNotEmpty) {
  //       transaction.put('currentTerminal', terminal[0]);
  //
  //       var stockUrl = Uri.https('api.lesailes.uz', 'api/terminals/get_stock',
  //           {'terminal_id': terminal[0].id.toString()});
  //       var stockResponse = await http.get(stockUrl, headers: requestHeaders);
  //       if (stockResponse.statusCode == 200) {
  //         var json = jsonDecode(stockResponse.body);
  //         Stock newStockData = Stock(
  //             prodIds: List<int>.from(json[
  //                 'data']) /* json['data'].map((id) => id as int).toList()*/);
  //         Box<Stock> box = Hive.box<Stock>('stock');
  //         box.put('stock', newStockData);
  //       }
  //     }
  //   }
  // }

  @override
  void initState() {
    // () async {
    //   Location location = Location();
    //
    //   bool _serviceEnabled;
    //   PermissionStatus _permissionGranted;
    //   LocationData _locationData;
    //
    //   _serviceEnabled = await location.serviceEnabled();
    //   if (!_serviceEnabled) {
    //     _serviceEnabled = await location.requestService();
    //     if (!_serviceEnabled) {
    //       return;
    //     }
    //   }
    //
    //   _permissionGranted = await location.hasPermission();
    //   if (_permissionGranted == PermissionStatus.denied) {
    //     _permissionGranted = await location.requestPermission();
    //     if (_permissionGranted != PermissionStatus.granted) {
    //       return;
    //     }
    //   }
    //
    //   // location.enableBackgroundMode(enable: true);
    //   location.changeSettings(
    //       distanceFilter: 100,
    //       interval: 60000,
    //       accuracy: LocationAccuracy.balanced);
    //   _locationData = await location.getLocation();
    //   Map<String, String> requestHeaders = {
    //     'Content-type': 'application/json',
    //     'Accept': 'application/json'
    //   };
    //   var url = Uri.https('api.lesailes.uz', 'api/geocode', {
    //     'lat': _locationData.latitude.toString(),
    //     'lon': _locationData.longitude.toString()
    //   });
    //   var response = await http.get(url, headers: requestHeaders);
    //   if (response.statusCode == 200) {
    //     var json = jsonDecode(response.body);
    //     var geoData = YandexGeoData.fromJson(json['data']);
    //     var house = '';
    //     geoData.addressItems?.forEach((element) {
    //       if (element.kind == 'house') {
    //         house = element.name;
    //       }
    //     });
    //     DeliveryLocationData deliveryData = DeliveryLocationData(
    //         house: house ?? '',
    //         flat: '',
    //         entrance: '',
    //         doorCode: '',
    //         lat: _locationData.latitude,
    //         lon: _locationData.longitude,
    //         address: geoData.formatted ?? '');
    //
    //     setLocation(_locationData, deliveryData, house);
    //   }
    //   location.onLocationChanged.listen((LocationData currentLocation) async {
    //     DeliveryLocationData? deliveryLocationData =
    //         Hive.box<DeliveryLocationData>('deliveryLocationData')
    //             .get('deliveryLocationData');
    //     if ("${currentLocation.latitude.toString()}${currentLocation.longitude.toString()}" !=
    //         "${deliveryLocationData?.lat?.toString()}${deliveryLocationData?.lon?.toString()}") {
    //       Map<String, String> requestHeaders = {
    //         'Content-type': 'application/json',
    //         'Accept': 'application/json'
    //       };
    //       var url = Uri.https('api.lesailes.uz', 'api/geocode', {
    //         'lat': _locationData.latitude.toString(),
    //         'lon': _locationData.longitude.toString()
    //       });
    //       var response = await http.get(url, headers: requestHeaders);
    //       if (response.statusCode == 200) {
    //         var json = jsonDecode(response.body);
    //         var geoData = YandexGeoData.fromJson(json['data']);
    //         var house = '';
    //         geoData.addressItems?.forEach((element) {
    //           if (element.kind == 'house') {
    //             house = element.name;
    //           }
    //         });
    //         DeliveryLocationData deliveryData = DeliveryLocationData(
    //             house: house ?? '',
    //             flat: '',
    //             entrance: '',
    //             doorCode: '',
    //             lat: _locationData.latitude,
    //             lon: _locationData.longitude,
    //             address: geoData.formatted ?? '');
    //
    //         // showAlertOnChangeLocation(currentLocation, deliveryData, house,
    //         //     "${currentLocation.latitude.toString()},${currentLocation.longitude.toString()} ${deliveryLocationData?.lat?.toString()},${deliveryLocationData?.lon?.toString()}");
    //         setLocation(currentLocation, deliveryData, house);
    //       }
    //     }
    //   });
    // }();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   toolbarHeight: 80,
      //   title: const Header(),
      //   automaticallyImplyLeading: false,
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   systemOverlayStyle: const SystemUiOverlayStyle(
      //       statusBarColor: AppColors.mainColor, // Status bar
      //       statusBarBrightness: Brightness.light),
      // ),

      drawer: const LeftMenu(),
      body: /*SingleChildScrollView(
        controller: _parentScrollController,
        scrollDirection: Axis.vertical,
        child: Expanded(
          child: Container(
              height: MediaQuery.of(context).size.height * 1.5,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
              margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Column(children: [
                const Header(),
                const ChooseCity(),
                const WayToReceiveAnOrder(),
                SliderCarousel(),
                ProductTabListStateful(
                    parentScrollController: _parentScrollController)
              ])),
        ),
      ),*/
          Stack(children: [
           SingleChildScrollView(
              controller: _parentScrollController,
              scrollDirection: Axis.vertical,
              child: Container(
                  // height: double.maxFinite,
                  // width: double.maxFinite,
                  height: MediaQuery.of(context).size.height * 1.55,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
                  margin:
                  EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  child: Column(children: [
                    const Header(),
                    const ChooseCity(),
                    const WayToReceiveAnOrder(),
                    SliderCarousel(),
                    ProductTabListStateful(
                        parentScrollController: _parentScrollController)
                  ]))),
        const Positioned(
          child:  Align(
        alignment: Alignment.bottomCenter,
    child:  FixedBasket(),
    )
        ),
      ]),
      // bottomNavigationBar: const FixedBasket(),
    );
  }
}
