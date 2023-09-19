import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:les_ailes/models/delivery_type.dart';
import 'package:les_ailes/models/stock.dart';
import 'package:les_ailes/models/terminals.dart';
import 'package:les_ailes/models/yandex_geo_data.dart';
import 'package:les_ailes/utils/colors.dart';
import 'package:les_ailes/widgets/leftMenu.dart';
import 'package:les_ailes/widgets/productTabListStateful.dart';
import 'package:les_ailes/widgets/ui/fixed_basket.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
// import 'package:native_updater/native_updater.dart';
import 'models/delivery_location_data.dart';

import 'models/productSection.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  List<ProductSection> products = List<ProductSection>.empty();
  bool isProductsLoading = true;

  Future<void> getProducts() async {
    setState(() {
      isProductsLoading = true;
    });
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json'
    };
    var url = Uri.https(
        'api.lesailes.uz', '/api/products/public', {'perSection': '1'});
    var response = await http.get(url, headers: requestHeaders);
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      List<ProductSection> productSections = List<ProductSection>.from(
          json['data'].map((m) => ProductSection.fromJson(m)).toList());
      // _tabController.dispose();
      // _tabController = TabController(
      //     length: productSections.length, vsync: this, initialIndex: 0);
      setState(() {
        products = productSections;
        isProductsLoading = false;
        // scrollCont.addListener(changeTabs);
      });
      // Future.delayed(const Duration(milliseconds: 200), (){
      //   _tabController.dispose();
      //   _tabController = TabController(
      //       length: productSections.length, vsync: this, initialIndex: 0);
      // });
    }
  }

  Future<void> setLocation(LocationData location,
      DeliveryLocationData deliveryData, String house) async {
    final Box<DeliveryLocationData> deliveryLocationBox =
        Hive.box<DeliveryLocationData>('deliveryLocationData');
    // deliveryLocationBox.put('deliveryLocationData', deliveryData);

    Box<DeliveryType> box = Hive.box<DeliveryType>('deliveryType');
    DeliveryType? currentDeliver = box.get('deliveryType');
    // if (currentDeliver == null) {
    //   DeliveryType deliveryType = DeliveryType();
    //   deliveryType.value = DeliveryTypeEnum.deliver;
    //   Box<DeliveryType> box = Hive.box<DeliveryType>('deliveryType');
    //   box.put('deliveryType', deliveryType);
    // }
    // else if (currentDeliver.value != DeliveryTypeEnum.pickup) {
    //   DeliveryType deliveryType = DeliveryType();
    //   deliveryType.value = DeliveryTypeEnum.pickup;
    //   Box<DeliveryType> box = Hive.box<DeliveryType>('deliveryType');
    //   box.put('deliveryType', deliveryType);
    // }

    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json'
    };

    var url = Uri.https('api.lesailes.uz', 'api/terminals/find_nearest', {
      'lat': location.latitude.toString(),
      'lon': location.longitude.toString()
    });
    var response = await http.get(url, headers: requestHeaders);
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      List<Terminals> terminal = List<Terminals>.from(
          json['data']['items'].map((m) => Terminals.fromJson(m)).toList());
      Box<Terminals> transaction = Hive.box<Terminals>('currentTerminal');
      if (terminal.isNotEmpty) {
        // transaction.put('currentTerminal', terminal[0]);

        var stockUrl = Uri.https('api.lesailes.uz', 'api/terminals/get_stock',
            {'terminal_id': terminal[0].id.toString()});
        var stockResponse = await http.get(stockUrl, headers: requestHeaders);
        if (stockResponse.statusCode == 200) {
          var json = jsonDecode(stockResponse.body);
          Stock newStockData = Stock(
              prodIds: List<int>.from(json[
                  'data']) /* json['data'].map((id) => id as int).toList()*/);
          Box<Stock> box = Hive.box<Stock>('stock');
          box.put('stock', newStockData);
        }
      }
    }
  }

  void _instanceId() async {
    if (Platform.isIOS) {
      FirebaseMessaging.instance.requestPermission();
    }
    var token = await FirebaseMessaging.instance.getAPNSToken();
  }

  @override
  void initState() {
    super.initState();
    initConnectivity();
    checkVersion();
    _instanceId();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    getProducts();
    () async {
      /*Location location = Location();

      bool _serviceEnabled;
      PermissionStatus _permissionGranted;
      LocationData _locationData;

      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          return;
        }
      }

      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      // location.enableBackgroundMode(enable: true);
      location.changeSettings(
          distanceFilter: 100,
          interval: 60000,
          accuracy: LocationAccuracy.balanced);
      _locationData = await location.getLocation();
      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json'
      };
      var url = Uri.https('api.lesailes.uz', 'api/geocode', {
        'lat': _locationData.latitude.toString(),
        'lon': _locationData.longitude.toString()
      });
      var response = await http.get(url, headers: requestHeaders);
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        var geoData = YandexGeoData.fromJson(json['data']);
        var house = '';
        geoData.addressItems?.forEach((element) {
          if (element.kind == 'house') {
            house = element.name;
          }
        });
        DeliveryLocationData deliveryData = DeliveryLocationData(
            house: house ?? '',
            flat: '',
            entrance: '',
            doorCode: '',
            lat: _locationData.latitude,
            lon: _locationData.longitude,
            address: geoData.formatted ?? '');

        setLocation(_locationData, deliveryData, house);
      }*/
      /*location.onLocationChanged.listen((LocationData currentLocation) async {
        DeliveryLocationData? deliveryLocationData =
            Hive.box<DeliveryLocationData>('deliveryLocationData')
                .get('deliveryLocationData');
        if ("${currentLocation.latitude.toString()}${currentLocation.longitude.toString()}" !=
            "${deliveryLocationData?.lat?.toString()}${deliveryLocationData?.lon?.toString()}") {
          Map<String, String> requestHeaders = {
            'Content-type': 'application/json',
            'Accept': 'application/json'
          };
          var url = Uri.https('api.lesailes.uz', 'api/geocode', {
            'lat': _locationData.latitude.toString(),
            'lon': _locationData.longitude.toString()
          });
          var response = await http.get(url, headers: requestHeaders);
          if (response.statusCode == 200) {
            var json = jsonDecode(response.body);
            var geoData = YandexGeoData.fromJson(json['data']);
            var house = '';
            geoData.addressItems?.forEach((element) {
              if (element.kind == 'house') {
                house = element.name;
              }
            });
            DeliveryLocationData deliveryData = DeliveryLocationData(
                house: house ?? '',
                flat: '',
                entrance: '',
                doorCode: '',
                lat: _locationData.latitude,
                lon: _locationData.longitude,
                address: geoData.formatted ?? '');

            // showAlertOnChangeLocation(currentLocation, deliveryData, house,
            //     "${currentLocation.latitude.toString()},${currentLocation.longitude.toString()} ${deliveryLocationData?.lat?.toString()},${deliveryLocationData?.lon?.toString()}");
            setLocation(currentLocation, deliveryData, house);
          }
        }
      });
    */
    }();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e);
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
  }

  Future<void> checkVersion() async {
    /// For example: You got status code of 412 from the
    /// response of HTTP request.
    /// Let's say the statusCode 412 requires you to force update
    //int statusCode = 412;

    /// This could be kept in our local
    //int localVersion = 9;

    /// This could get from the API
    //int serverLatestVersion = 10;

    // Future.delayed(Duration.zero, () {
    //   NativeUpdater.displayUpdateAlert(
    //     context,
    //     forceUpdate: false,
    //     appStoreUrl: 'https://apps.apple.com/uz/app/les-ailes-uzb/id1616011426',
    //     iOSUpdateButtonLabel: tr("update"),
    //     iOSIgnoreButtonLabel: tr("nextTime"),
    //   );
    // });
  }

  late double pinnedHeaderHeight;

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    pinnedHeaderHeight =
        //statusBar height
        statusBarHeight +
            //pinned SliverAppBar height in header
            kToolbarHeight;
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
          _connectionStatus.toString() == 'ConnectivityResult.none'
              ? Center(
                  child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(tr('checkInet'), style: const TextStyle(fontSize: 20)),
                    const SizedBox(
                      height: 50,
                    ),
                    const Icon(
                      Icons.wifi_off_outlined,
                      color: AppColors.mainColor,
                      size: 100,
                    )
                  ],
                ))
              : isProductsLoading
                  ? Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: AppColors.mainColor,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ))
                  : ProductTabListStateful(products: products),
      // SafeArea(
      //         child: Stack(children: [
      //           SingleChildScrollView(
      //               controller: _parentScrollController,
      //               scrollDirection: Axis.vertical,
      //               child: Container(
      //                   // height: double.maxFinite,
      //                   // width: double.maxFinite,
      //                   height: Platform.isAndroid
      //                       ? MediaQuery.of(context).size.height * 1.50
      //                       : MediaQuery.of(context).size.height * 1.45,
      //                   padding: const EdgeInsets.symmetric(
      //                       horizontal: 16, vertical: 1),
      //                   // margin: EdgeInsets.only(
      //                   //     top: MediaQuery.of(context).padding.top),
      //                   child: Column(children: [
      //                     const Header(),
      //                     const ChooseCity(),
      //                     const WayToReceiveAnOrder(),
      //                     SliderCarousel(),
      //                     ProductTabListStateful(
      //                         parentScrollController:
      //                             _parentScrollController),
      //                   ]))),
      //           const Positioned(
      //               child: Align(
      //             alignment: Alignment.bottomCenter,
      //             child: FixedBasket(),
      //           )),
      //         ]),
      //       ),
      // SafeArea(child: Stack(children: [
      //   ExtendedNestedScrollView(headerSliverBuilder: (context, innerBoxIsScrolled) => [SliverAppBar(title: Text('davr'),aut)],
      //       body: Container(
      //                         // height: double.maxFinite,
      //                         // width: double.maxFinite,
      //                         height: Platform.isAndroid
      //                             ? MediaQuery.of(context).size.height * 1.50
      //                             : MediaQuery.of(context).size.height * 1.45,
      //                         padding: const EdgeInsets.symmetric(
      //                             horizontal: 16, vertical: 1),
      //                         // margin: EdgeInsets.only(
      //                         //     top: MediaQuery.of(context).padding.top),
      //                         child: Column(children: [
      //                           const Header(),
      //                           const ChooseCity(),
      //                           const WayToReceiveAnOrder(),
      //                           SliderCarousel(),
      //                           // ProductTabListStateful(
      //                           //     parentScrollController:
      //                           //         _parentScrollController),
      //                         ]))),
      //     Positioned(
      //         child: Align(
      //       alignment: Alignment.bottomCenter,
      //       child: FixedBasket(),
      //     )),
      // ],))
      // Scaffold(
      //     body: CustomScrollView(
      //       slivers: <Widget>[
      //         SliverAppBar(
      //           pinned: true,
      //           snap: false,
      //           floating: false,
      //           stretch: false,
      //           expandedHeight: 500.0,
      //           // backgroundColor: Colors.transparent,
      //           // stretchTriggerOffset: 200,
      //           // toolbarHeight: 200,
      //           // backgroundColor: Colors.transparent,
      //           flexibleSpace: FlexibleSpaceBar(
      //             title: const Text('SliverAppBar'),
      //             background: SafeArea(
      //               child: Padding(
      //                 padding: const EdgeInsets.symmetric(horizontal: 10.0),
      //                 child: Column(
      //                   children: [
      //                     const Header(),
      //                     const ChooseCity(),
      //                     const WayToReceiveAnOrder(),
      //                     SliderCarousel(),
      //                   ],
      //                 ),
      //               ),
      //             ),
      //           ),
      //           // actions: [
      //           //   Column(
      //           //     children: [
      //           //       Header(),
      //           //       ChooseCity(),
      //           //     ],
      //           //   )
      //           // ],
      //         ),
      //         const SliverToBoxAdapter(
      //           child: SizedBox(
      //             height: 20,
      //             child: Center(
      //               child: Text(
      //                   'Scroll to see the SliverAppBar in effect.'),
      //             ),
      //           ),
      //         ),
      //         SliverList(
      //           delegate: SliverChildBuilderDelegate(
      //             (BuildContext context, int index) {
      //               return Container(
      //                 color:
      //                     index.isOdd ? Colors.white : Colors.black12,
      //                 height: 100.0,
      //                 child: Center(
      //                   child: Text('$index', textScaleFactor: 5),
      //                 ),
      //               );
      //             },
      //             childCount: 20,
      //           ),
      //         ),
      //       ],
      //     ),
      //     bottomNavigationBar: BottomAppBar(
      //       child: Padding(
      //         padding: const EdgeInsets.all(8),
      //         child: OverflowBar(
      //           overflowAlignment: OverflowBarAlignment.center,
      //           children: <Widget>[
      //             Row(
      //               mainAxisSize: MainAxisSize.min,
      //               children: <Widget>[
      //                 const Text('pinned'),
      //               ],
      //             ),
      //             Row(
      //               mainAxisSize: MainAxisSize.min,
      //               children: <Widget>[
      //                 const Text('snap'),
      //               ],
      //             ),
      //             Row(
      //               mainAxisSize: MainAxisSize.min,
      //               children: <Widget>[
      //                 const Text('floating'),
      //               ],
      //             ),
      //           ],
      //         ),
      //       ),
      //     ),
      //   )
      bottomNavigationBar: Container(
        color: Colors.transparent,
        child: const FixedBasket(),
      ),
    );
  }
}
