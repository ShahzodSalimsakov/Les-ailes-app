import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:les_ailes/utils/colors.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:niku/niku.dart' as n;

import '../../models/city.dart';
import '../../models/pickup_type.dart';
import '../../models/temp_terminals.dart';

class PickupMapViewListen extends HookWidget {
  final List<TempTerminals> terminals;

  PickupMapViewListen(this.terminals);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<TempTerminals>>(
        valueListenable: Hive.box<TempTerminals>('tempTerminal').listenable(),
        builder: (context, box, _) {
          return PickupMapView(terminals);
        });
  }
}

class PickupMapView extends HookWidget {
  final List<TempTerminals> terminals;

  PickupMapView(this.terminals);

  late YandexMapController controller;
  final MapObjectId mapObjectCollectionId =
      const MapObjectId('map_object_collection');
  final animation =
      const MapAnimation(type: MapAnimationType.smooth, duration: 1.5);

  bool zoomGesturesEnabled = true;

  @override
  Widget build(BuildContext context) {
    var mapObjects = useState<List<MapObject>>([]);
    City? currentCity = Hive.box<City>('currentCity').get('currentCity');
    Box<TempTerminals> box = Hive.box<TempTerminals>('tempTerminal');
    TempTerminals? selectedTerminal = box.get('tempTerminal');

    useEffect(() {
      List<PlacemarkMapObject> mapsList = <PlacemarkMapObject>[];
      Box<TempTerminals> box = Hive.box<TempTerminals>('tempTerminal');
      TempTerminals? selectedTerminal = box.get('tempTerminal');
      for (var element in terminals) {
        if (element.latitude == null ||
            element.longitude == null ||
            element.id == null) {
          continue;
        }

        try {
          var _placemark = PlacemarkMapObject(
              mapId: MapObjectId(element.id!),
              point: Point(
                  latitude: double.parse(element.latitude!),
                  longitude: double.parse(element.longitude!)),
              onTap: (PlacemarkMapObject self, Point point) {
                if (!element.isWorking!) {
                  return;
                }
                Box<TempTerminals> transaction =
                    Hive.box<TempTerminals>('tempTerminal');
                transaction.put('tempTerminal', element);
              },
              opacity: element.isWorking == true ? 0.7 : 0.4,
              direction: 90,
              icon: PlacemarkIcon.single(PlacemarkIconStyle(
                  image: BitmapDescriptor.fromAssetImage(
                      'images/location_picker.png'),
                  rotationType: RotationType.noRotation,
                  scale: selectedTerminal != null &&
                          selectedTerminal.id == element.id
                      ? 4
                      : 2,
                  anchor: Offset.fromDirection(1.1, 1))));

          mapsList.add(_placemark);
        } catch (e) {
          print('Error creating map marker: $e');
          continue;
        }
      }
      final mapObjectCollection = MapObjectCollection(
        mapId: mapObjectCollectionId,
        mapObjects: mapsList,
      );

      mapObjects.value = [mapObjectCollection];
      return null;
    }, [selectedTerminal]);

    return Stack(
      children: [
        YandexMap(
            mapObjects: mapObjects.value,
            zoomGesturesEnabled: zoomGesturesEnabled,
            onMapCreated: (YandexMapController yandexMapController) async {
              controller = yandexMapController;
              if (currentCity?.lat != null && currentCity?.lon != null) {
                try {
                  await controller.moveCamera(
                      CameraUpdate.newCameraPosition(CameraPosition(
                          target: Point(
                              latitude: double.parse(currentCity!.lat!),
                              longitude: double.parse(currentCity.lon!)),
                          zoom: 12)),
                      animation: animation);
                } catch (e) {
                  print('Error moving camera: $e');
                }
              }
            }),
        Positioned(
          top: 15,
          right: 15,
          child: SizedBox(
              child: n.NikuButton.elevated(const Icon(
            Icons.close,
            color: Colors.white,
            size: 30,
          ))
                ..bg = AppColors.mainColor
                ..rounded = 40
                ..elevation = 3
                ..px = 3
                ..py = 17
                ..onPressed = () {
                  Box<PickupType> transaction =
                      Hive.box<PickupType>('pickupType');
                  transaction.delete('pickupType');
                  Navigator.of(context).pop();
                }),
        )
      ],
    );
  }
}
