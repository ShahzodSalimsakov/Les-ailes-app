import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:les_ailes/utils/colors.dart';
import 'package:location/location.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import '../models/city.dart';
import '../models/delivery_location_data.dart';
import '../models/terminals.dart';
import '../models/yandex_geo_data.dart';
import '../widgets/delivery_bottom_sheet.dart';
import '../widgets/delivery_modal_sheet.dart';

@RoutePage()
class DeliveryPage extends HookWidget {
  final YandexGeoData? geoData;

  DeliveryPage({Key? key, this.geoData}) : super(key: key);

  late YandexMapController controller;
  final MapObjectId placemarkId = const MapObjectId('delivery_placemark');
  final animation =
      const MapAnimation(type: MapAnimationType.smooth, duration: 1.5);

  bool zoomGesturesEnabled = true;

  @override
  Widget build(BuildContext context) {
    Terminals? currentTerminal =
        Hive.box<Terminals>('currentTerminal').get('currentTerminal');
    var mapObjects = useState<List<MapObject>>([]);
    var isLookingLocation = useState<bool>(false);
    var currentPoint = useState<Point?>(null);

    Future<void> lookForLocation() async {
      isLookingLocation.value = true;

      bool isLocationSet = true;

      final Box<DeliveryLocationData> deliveryLocationBox =
          Hive.box<DeliveryLocationData>('deliveryLocationData');
      DeliveryLocationData? deliveryData =
          deliveryLocationBox.get('deliveryLocationData');

      if (deliveryData == null) {
        isLocationSet = false;
      } else if (deliveryData.lat == null) {
        isLocationSet = false;
      }

      Location location = new Location();

      bool _serviceEnabled;
      PermissionStatus _permissionGranted;
      LocationData _locationData;

      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Недостаточно прав для получения локации')));
          return;
        }
      }

      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Недостаточно прав для получения локации')));
          return;
        }
      }

      _locationData = await location.getLocation();

      // if (!isLocationSet) {

      // } else {
      //   currentPosition = Position(
      //       longitude: deliveryData!.lon!,
      //       latitude: deliveryData!.lat!,
      //       timestamp: DateTime.now(),
      //       accuracy: 0,
      //       altitude: 0,
      //       heading: 0,
      //       speed: 0,
      //       speedAccuracy: 0);
      // }
      var _placemark = PlacemarkMapObject(
          mapId: placemarkId,
          point: Point(
              latitude: _locationData.latitude!,
              longitude: _locationData.longitude!),
          // onTap: (Placemark self, Point point) =>
          //     setCurrentTerminal(element),
          opacity: 0.7,
          direction: 90,
          icon: PlacemarkIcon.single(PlacemarkIconStyle(
              image:
                  BitmapDescriptor.fromAssetImage('images/location_picker.png'),
              rotationType: RotationType.noRotation,
              scale: 3,
              anchor: Offset.fromDirection(1.1, 1))));
      List<MapObject> mapsList = <MapObject>[];
      mapsList.add(_placemark);
      mapObjects.value = mapsList;
      currentPoint.value = Point(
          latitude: _locationData.latitude!,
          longitude: _locationData.longitude!);
      await controller.moveCamera(
          CameraUpdate.newCameraPosition(CameraPosition(
              target: Point(
                  latitude: _locationData.latitude!,
                  longitude: _locationData.longitude!),
              zoom: 17)),
          animation: animation);
      // showBottomSheet(Point(
      //     latitude: currentPosition.latitude,
      //     longitude: currentPosition.longitude));
      isLookingLocation.value = false;
    }

    void changeLocation(Point point) async {
      var _placemark = PlacemarkMapObject(
          mapId: placemarkId,
          point: point,
          // onTap: (Placemark self, Point point) =>
          //     setCurrentTerminal(element),
          opacity: 0.7,
          direction: 90,
          icon: PlacemarkIcon.single(PlacemarkIconStyle(
              image:
                  BitmapDescriptor.fromAssetImage('images/location_picker.png'),
              rotationType: RotationType.noRotation,
              scale: 3,
              anchor: Offset.fromDirection(1.1, 1))));
      List<MapObject> mapsList = <MapObject>[];
      mapsList.add(_placemark);
      mapObjects.value = mapsList;
      currentPoint.value = point;
      await controller.moveCamera(
          CameraUpdate.newCameraPosition(
              CameraPosition(target: point, zoom: 17)),
          animation: animation);
    }

    return Scaffold(
      body: SafeArea(
          child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(fit: StackFit.loose, children: [
          /*Expanded(
            child: */
          YandexMap(
            mapObjects: mapObjects.value,
            zoomGesturesEnabled: zoomGesturesEnabled,
            onMapCreated: (YandexMapController yandexMapController) async {
              controller = yandexMapController;
              isLookingLocation.value = true;
              Box<City> box = Hive.box<City>('currentCity');
              City? currentCity = box.get('currentCity');

              await controller.moveCamera(
                  CameraUpdate.newCameraPosition(CameraPosition(
                      target: Point(
                          latitude: double.parse(currentCity!.lat!),
                          longitude: double.parse(currentCity.lon!)),
                      zoom: 12)),
                  animation: animation);

              if (geoData != null) {
                var _placemark = PlacemarkMapObject(
                    mapId: placemarkId,
                    point: Point(
                        latitude: double.parse(geoData!.coordinates.lat),
                        longitude: double.parse(geoData!.coordinates.long)),
                    // onTap: (Placemark self, Point point) =>
                    //     setCurrentTerminal(element),
                    icon: PlacemarkIcon.single(PlacemarkIconStyle(
                        image: BitmapDescriptor.fromAssetImage(
                            'images/location_picker.png'),
                        rotationType: RotationType.noRotation,
                        scale: 3,
                        anchor: Offset.fromDirection(1.1, 1))));
                List<MapObject> mapsList = <MapObject>[];
                mapsList.add(_placemark);
                mapObjects.value = mapsList;
                currentPoint.value = Point(
                    latitude: double.parse(geoData!.coordinates.lat),
                    longitude: double.parse(geoData!.coordinates.long));
                await controller.moveCamera(
                    CameraUpdate.newCameraPosition(CameraPosition(
                        target: Point(
                            latitude: double.parse(geoData!.coordinates.lat),
                            longitude: double.parse(geoData!.coordinates.long)),
                        zoom: 17)),
                    animation: animation);
              } else {
                Location location = new Location();

                bool hasPermission = true;
                bool _serviceEnabled;
                PermissionStatus _permissionGranted;
                LocationData _locationData;

                _serviceEnabled = await location.serviceEnabled();
                if (!_serviceEnabled) {
                  _serviceEnabled = await location.requestService();
                  if (!_serviceEnabled) {
                    hasPermission = false;
                  }
                }

                _permissionGranted = await location.hasPermission();
                if (_permissionGranted == PermissionStatus.denied) {
                  _permissionGranted = await location.requestPermission();
                  if (_permissionGranted != PermissionStatus.granted) {
                    hasPermission = false;
                  }
                }

                if (hasPermission) {
                  _locationData = await location.getLocation();
                  var _placemark = PlacemarkMapObject(
                      mapId: placemarkId,
                      point: Point(
                          latitude: _locationData.latitude!,
                          longitude: _locationData.longitude!),
                      // onTap: (Placemark self, Point point) =>
                      //     setCurrentTerminal(element),
                      opacity: 0.7,
                      direction: 90,
                      icon: PlacemarkIcon.single(PlacemarkIconStyle(
                          image: BitmapDescriptor.fromAssetImage(
                              'images/location_picker.png'),
                          rotationType: RotationType.noRotation,
                          scale: 3,
                          anchor: Offset.fromDirection(1.1, 1))));
                  List<MapObject> mapsList = <MapObject>[];
                  mapsList.add(_placemark);
                  mapObjects.value = mapsList;
                  currentPoint.value = Point(
                      latitude: _locationData.latitude!,
                      longitude: _locationData.longitude!);
                  await controller.moveCamera(
                      CameraUpdate.newCameraPosition(CameraPosition(
                          target: Point(
                              latitude: _locationData.latitude!,
                              longitude: _locationData.longitude!),
                          zoom: 17)),
                      animation: animation);
                  // showBottomSheet(Point(
                  //     latitude: currentPosition.latitude,
                  //     longitude: currentPosition.longitude));
                } else {
                  // await controller.move(
                  //     point: Point(
                  //         latitude: double.parse(currentCity!.lat!),
                  //         longitude: double.parse(currentCity!.lon!)),
                  //     animation: MapAnimation(smooth: true, duration: 1.5),
                  //     zoom: double.parse(currentCity.mapZoom));
                }
              }
              isLookingLocation.value = false;
            },
            onMapTap: (point) async {
              var _placemark = PlacemarkMapObject(
                  mapId: placemarkId,
                  point: point,
                  opacity: 0.9,
                  direction: 0,
                  // onTap: (Placemark self, Point point) =>
                  //     setCurrentTerminal(element),
                  icon: PlacemarkIcon.single(PlacemarkIconStyle(
                      image: BitmapDescriptor.fromAssetImage(
                          'images/location_picker.png'),
                      rotationType: RotationType.noRotation,
                      scale: 3,
                      anchor: Offset.fromDirection(1.1, 1))));
              List<MapObject> mapsList = <MapObject>[];
              mapsList.add(_placemark);
              mapObjects.value = mapsList;
              currentPoint.value = point;
              await controller.moveCamera(
                  CameraUpdate.newCameraPosition(
                      CameraPosition(target: point, zoom: 17)),
                  animation: animation);
              // showBottomSheet(point);
            },
          ) /*)*/,
          Positioned(
              top: 50,
              child: RawMaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                elevation: 2.0,
                fillColor: Colors.white,
                child: const Icon(Icons.close, size: 14.0, color: Colors.black),
                padding: const EdgeInsets.all(10.0),
                shape: const CircleBorder(),
              )),
          Positioned(
              right: 0,
              bottom: 210,
              child: RawMaterialButton(
                onPressed: () async {
                  lookForLocation();
                },
                elevation: 6.0,
                fillColor: Colors.white,
                child: isLookingLocation.value
                    ? const CircularProgressIndicator(
                        color: AppColors.mainColor,
                      )
                    : const Icon(Icons.navigation,
                        size: 23.0, color: AppColors.mainColor),
                padding: const EdgeInsets.all(10.0),
                shape: const CircleBorder(),
              )),
        ]),
      )),
      bottomSheet: DeliveryBottomSheet(
          currentPoint: currentPoint.value, onSetLocation: changeLocation),
    );
  }
}

// class DeliveryPage extends StatefulWidget {
//   final YandexGeoData? geoData;
//   const DeliveryPage({Key? key, this.geoData}) : super(key: key);
//
//   @override
//   State<DeliveryPage> createState() => _DeliveryPageState();
// }
//
// class _DeliveryPageState extends State<DeliveryPage> {
//   late YandexMapController controller;
//   Placemark? _placemark;
//
//   bool isLookingLocation = false;
//
//   showBottomSheet(Point point) {
//     showModalBottomSheet(
//       isScrollControlled: true,
//       context: context,
//       backgroundColor: Colors.white,
//       builder: (context) => DeliveryModalSheet(currentPoint: point),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Terminals? currentTerminal =
//     Hive.box<Terminals>('currentTerminal').get('currentTerminal');
//     final List<MapObject> mapObjects = [];
//
//   }
// }
