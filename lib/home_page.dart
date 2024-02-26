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
    if (mounted) {
      setState(() {
        isProductsLoading = true;
      });
    }
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
      if (mounted) {
        setState(() {
          products = productSections;
          isProductsLoading = false;
        });
      }
    }
  }

  Future<void> setLocation(LocationData location,
      DeliveryLocationData deliveryData, String house) async {
    Hive.box<DeliveryLocationData>('deliveryLocationData');

    Box<DeliveryType> box = Hive.box<DeliveryType>('deliveryType');
    box.get('deliveryType');
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
      Hive.box<Terminals>('currentTerminal');
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
  }

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _instanceId();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    getProducts();
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
    if (_connectionStatus == ConnectivityResult.none &&
        result != ConnectivityResult.none) {
      getProducts();
    }

    setState(() {
      _connectionStatus = result;
    });
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
      drawer: const LeftMenu(),
      body: 
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
      bottomNavigationBar: Container(
        color: Colors.transparent,
        child: const FixedBasket(),
      ),
    );
  }
}
