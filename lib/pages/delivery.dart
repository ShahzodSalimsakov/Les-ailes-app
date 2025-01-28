import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
class DeliveryPage extends StatefulWidget {
  final YandexGeoData? geoData;

  const DeliveryPage({Key? key, this.geoData}) : super(key: key);

  @override
  State<DeliveryPage> createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> {
  late YandexMapController controller;
  final MapObjectId placemarkId = const MapObjectId('delivery_placemark');
  final animation =
      const MapAnimation(type: MapAnimationType.smooth, duration: 1.5);
  bool zoomGesturesEnabled = true;

  final ValueNotifier<List<MapObject>> mapObjects =
      ValueNotifier<List<MapObject>>([]);
  final ValueNotifier<bool> isLookingLocation = ValueNotifier<bool>(false);
  final ValueNotifier<Point?> currentPoint = ValueNotifier<Point?>(null);
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    mapObjects.dispose();
    isLookingLocation.dispose();
    currentPoint.dispose();
    super.dispose();
  }

  void updateMapObjects(List<MapObject> objects) {
    if (!_disposed && mounted) {
      mapObjects.value = objects;
    }
  }

  Future<void> lookForLocation() async {
    if (!mounted) return;
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

    Location location = Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Недостаточно прав для получения локации')));
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Недостаточно прав для получения локации')));
        return;
      }
    }

    _locationData = await location.getLocation();
    if (!mounted) return;

    var _placemark = PlacemarkMapObject(
        mapId: placemarkId,
        point: Point(
            latitude: _locationData.latitude!,
            longitude: _locationData.longitude!),
        opacity: 0.7,
        direction: 90,
        icon: PlacemarkIcon.single(PlacemarkIconStyle(
            image:
                BitmapDescriptor.fromAssetImage('images/location_picker.png'),
            rotationType: RotationType.noRotation,
            scale: 3,
            anchor: Offset.fromDirection(1.1, 1))));

    if (!mounted) return;
    updateMapObjects([_placemark]);
    currentPoint.value = Point(
        latitude: _locationData.latitude!, longitude: _locationData.longitude!);

    await controller.moveCamera(
        CameraUpdate.newCameraPosition(CameraPosition(
            target: Point(
                latitude: _locationData.latitude!,
                longitude: _locationData.longitude!),
            zoom: 17)),
        animation: animation);

    if (!mounted) return;
    isLookingLocation.value = false;
  }

  void changeLocation(Point point) async {
    if (!mounted) return;

    var _placemark = PlacemarkMapObject(
        mapId: placemarkId,
        point: point,
        opacity: 0.7,
        direction: 90,
        icon: PlacemarkIcon.single(PlacemarkIconStyle(
            image:
                BitmapDescriptor.fromAssetImage('images/location_picker.png'),
            rotationType: RotationType.noRotation,
            scale: 3,
            anchor: Offset.fromDirection(1.1, 1))));

    if (!mounted) return;
    updateMapObjects([_placemark]);
    currentPoint.value = point;

    await controller.moveCamera(
        CameraUpdate.newCameraPosition(CameraPosition(target: point, zoom: 17)),
        animation: animation);
  }

  @override
  Widget build(BuildContext context) {
    Terminals? currentTerminal =
        Hive.box<Terminals>('currentTerminal').get('currentTerminal');

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
          child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(fit: StackFit.loose, children: [
          ValueListenableBuilder<List<MapObject>>(
              valueListenable: mapObjects,
              builder: (context, value, child) {
                return YandexMap(
                  mapObjects: value,
                  zoomGesturesEnabled: zoomGesturesEnabled,
                  onMapCreated:
                      (YandexMapController yandexMapController) async {
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

                    if (widget.geoData != null) {
                      if (!mounted) return;
                      var _placemark = PlacemarkMapObject(
                          mapId: placemarkId,
                          point: Point(
                              latitude:
                                  double.parse(widget.geoData!.coordinates.lat),
                              longitude: double.parse(
                                  widget.geoData!.coordinates.long)),
                          icon: PlacemarkIcon.single(PlacemarkIconStyle(
                              image: BitmapDescriptor.fromAssetImage(
                                  'images/location_picker.png'),
                              rotationType: RotationType.noRotation,
                              scale: 3,
                              anchor: Offset.fromDirection(1.1, 1))));

                      updateMapObjects([_placemark]);
                      currentPoint.value = Point(
                          latitude:
                              double.parse(widget.geoData!.coordinates.lat),
                          longitude:
                              double.parse(widget.geoData!.coordinates.long));

                      await controller.moveCamera(
                          CameraUpdate.newCameraPosition(CameraPosition(
                              target: Point(
                                  latitude: double.parse(
                                      widget.geoData!.coordinates.lat),
                                  longitude: double.parse(
                                      widget.geoData!.coordinates.long)),
                              zoom: 17)),
                          animation: animation);
                    } else {
                      Location location = Location();

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
                        if (!mounted) return;
                        var _placemark = PlacemarkMapObject(
                            mapId: placemarkId,
                            point: Point(
                                latitude: _locationData.latitude!,
                                longitude: _locationData.longitude!),
                            opacity: 0.7,
                            direction: 90,
                            icon: PlacemarkIcon.single(PlacemarkIconStyle(
                                image: BitmapDescriptor.fromAssetImage(
                                    'images/location_picker.png'),
                                rotationType: RotationType.noRotation,
                                scale: 3,
                                anchor: Offset.fromDirection(1.1, 1))));

                        updateMapObjects([_placemark]);
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
                      }
                    }
                    if (!mounted) return;
                    isLookingLocation.value = false;
                  },
                  onMapTap: (point) async {
                    if (!mounted) return;
                    var _placemark = PlacemarkMapObject(
                        mapId: placemarkId,
                        point: point,
                        opacity: 0.9,
                        direction: 0,
                        icon: PlacemarkIcon.single(PlacemarkIconStyle(
                            image: BitmapDescriptor.fromAssetImage(
                                'images/location_picker.png'),
                            rotationType: RotationType.noRotation,
                            scale: 3,
                            anchor: Offset.fromDirection(1.1, 1))));

                    updateMapObjects([_placemark]);
                    currentPoint.value = point;

                    await controller.moveCamera(
                        CameraUpdate.newCameraPosition(
                            CameraPosition(target: point, zoom: 17)),
                        animation: animation);
                  },
                );
              }),
          Positioned(
              top: 30,
              child: RawMaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                elevation: 2.0,
                fillColor: AppColors.mainColor,
                padding: const EdgeInsets.all(10.0),
                shape: const CircleBorder(),
                child: const Icon(Icons.close, size: 30.0, color: Colors.white),
              )),
          Positioned(
              right: 0,
              bottom: 210,
              child: ValueListenableBuilder<bool>(
                  valueListenable: isLookingLocation,
                  builder: (context, isLoading, child) {
                    return RawMaterialButton(
                      onPressed: () async {
                        lookForLocation();
                      },
                      elevation: 6.0,
                      fillColor: AppColors.mainColor,
                      padding: const EdgeInsets.all(10.0),
                      shape: const CircleBorder(),
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Icon(Icons.navigation,
                              size: 23.0, color: Colors.white),
                    );
                  })),
        ]),
      )),
      bottomSheet: ValueListenableBuilder<Point?>(
          valueListenable: currentPoint,
          builder: (context, point, child) {
            return DeliveryBottomSheet(
                currentPoint: point, onSetLocation: changeLocation);
          }),
    );
  }
}
