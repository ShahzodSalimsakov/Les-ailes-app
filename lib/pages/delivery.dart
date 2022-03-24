import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../models/yandex_geo_data.dart';
import '../widgets/delivery_modal_sheet.dart';

class DeliveryPage extends StatefulWidget {
  final YandexGeoData? geoData;
  const DeliveryPage({Key? key, this.geoData}) : super(key: key);

  @override
  State<DeliveryPage> createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> {
  late YandexMapController controller;
  Placemark? _placemark;

  bool isLookingLocation = false;

  showBottomSheet(Point point) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.white,
      builder: (context) => DeliveryModalSheet(currentPoint: point),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Container(child: const YandexMap())),
    );
  }
}
