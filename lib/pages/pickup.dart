import 'dart:convert';
import 'package:dart_date/dart_date.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:http/http.dart' as http;
import 'package:niku/niku.dart' as n;
import '../models/city.dart';
import '../models/delivery_location_data.dart';
import '../models/delivery_type.dart';
import '../models/stock.dart';
import '../models/terminals.dart';

import '../utils/colors.dart';
import '../widgets/terminals_modal.dart';

class PickupPage extends HookWidget {
  late YandexMapController controller;
  final MapObjectId mapObjectCollectionId =
      MapObjectId('map_object_collection');
  final animation =
      const MapAnimation(type: MapAnimationType.smooth, duration: 1.5);

  bool zoomGesturesEnabled = true;

  @override
  Widget build(BuildContext context) {
    final terminals = useState<List<Terminals>>(List<Terminals>.empty());
    City? currentCity = Hive.box<City>('currentCity').get('currentCity');
    final tabController = useTabController(initialLength: 2);
    final defaultTabIndex = useState(0);
    final _tabKey = GlobalKey();
    final localSelectedTerminal = useState<Terminals?>(null);
    var mapObjects = useState<List<MapObject>>([]);

    tabController.addListener(() async {
      defaultTabIndex.value = tabController.index;
    });

    Terminals? selectedTerminal = useMemoized(() {
      Terminals? currentTerminal =
          Hive.box<Terminals>('currentTerminal').get('currentTerminal');

      if (currentTerminal != null && localSelectedTerminal.value == null) {
        return currentTerminal;
      }

      if (localSelectedTerminal.value != null) {
        return localSelectedTerminal.value;
      }

      return null;
    }, [localSelectedTerminal.value]);

    Future<void> getTerminals() async {
      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json'
      };
      bool serviceEnabled;
      LocationPermission permission;
      var formData = {'city_id': currentCity?.id.toString()};
      var url = Uri.https('api.lesailes.uz', 'api/terminals/pickup', formData);
      var response = await http.get(url, headers: requestHeaders);
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        List<Terminals> terminal = List<Terminals>.from(
            json['data'].map((m) => Terminals.fromJson(m)).toList());
        DateTime currentTime = DateTime.now();
        List<Terminals> resultTerminals = [];
        for (var t in terminal) {
          if (currentTime.weekday >= 1 && currentTime.weekday <= 5) {
            if (t.openWork == null) {
              return;
            } else {
              DateTime openWork = Date.parse(t.openWork!);
              openWork = openWork.toLocal();
              openWork = openWork.setDay(currentTime.day);
              openWork = openWork.setMonth(currentTime.month);
              openWork = openWork.setYear(currentTime.year);
              DateTime closeWork = Date.parse(t.closeWork!);
              closeWork = closeWork.toLocal();
              closeWork = closeWork.setDay(currentTime.day);
              closeWork = closeWork.setMonth(currentTime.month);
              closeWork = closeWork.setYear(currentTime.year);

              if (closeWork.hour < openWork.hour) {
                closeWork = closeWork.setDay(currentTime.day + 1);
              }
              if (currentTime.isAfter(openWork) &&
                  currentTime.isBefore(closeWork)) {
                t.isWorking = true;
              } else {
                t.isWorking = false;
              }
            }
          } else {
            if (t.openWeekend == null) {
              return;
            } else {
              DateTime openWork = Date.parse(t.openWeekend!);
              openWork = openWork.toLocal();
              openWork = openWork.setDay(currentTime.day);
              openWork = openWork.setMonth(currentTime.month);
              openWork = openWork.setYear(currentTime.year);
              DateTime closeWork = Date.parse(t.closeWeekend!);
              closeWork = closeWork.toLocal();
              closeWork = closeWork.setDay(currentTime.day);
              closeWork = closeWork.setMonth(currentTime.month);
              closeWork = closeWork.setYear(currentTime.year);

              if (closeWork.hour < openWork.hour) {
                closeWork = closeWork.setDay(currentTime.day + 1);
              }
              if (currentTime.isAfter(openWork) &&
                  currentTime.isBefore(closeWork)) {
                t.isWorking = true;
              } else {
                t.isWorking = false;
              }
            }
          }
          resultTerminals.add(t);
        }

        terminals.value = resultTerminals;

        List<Placemark> mapsList = <Placemark>[];
        for (var element in resultTerminals) {
          var _placemark = Placemark(
              mapId: MapObjectId(element.id!),
              point: Point(
                  latitude: double.parse(element.latitude!),
                  longitude: double.parse(element.longitude!)),
              onTap: (Placemark self, Point point) {
                localSelectedTerminal.value = element;
              },
              opacity: 0.7,
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
        }
        final mapObjectCollection = MapObjectCollection(
          mapId: mapObjectCollectionId,
          // onClusterAdded: (ClusterizedPlacemarkCollection self, Cluster cluster) async {
          //   return cluster.copyWith(
          //       appearance: cluster.appearance.copyWith(
          //           icon: PlacemarkIcon.single(PlacemarkIconStyle(
          //               image: BitmapDescriptor.fromAssetImage('lib/assets/cluster.png'),
          //               scale: 1
          //           ))
          //       )
          //   );
          // },
          // onClusterTap: (ClusterizedPlacemarkCollection self, Cluster cluster) {
          //   print('Tapped cluster');
          // },
          mapObjects: mapsList,
          // onTap: (MapObjectCollection self, Point point) => print('Tapped me at $point'),
        );

        mapObjects.value = [mapObjectCollection];
      }

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
      var currentPosition;

      if (!isLocationSet) {
        // Test if location services are enabled.
        serviceEnabled = await Geolocator.isLocationServiceEnabled();

        permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          serviceEnabled = false;
        }

        if (permission == LocationPermission.deniedForever) {
          serviceEnabled = false;
        }

        if (!serviceEnabled) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'Включите геолокацию, чтобы увидеть ближайшие филиалы первыми')));
        }
        try {
          if (serviceEnabled) {
            currentPosition = await Geolocator.getCurrentPosition();
          }
        } catch (e) {}
      } else {
        currentPosition = Position(
            longitude: deliveryData!.lon!,
            latitude: deliveryData!.lat!,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0);
      }

      if (currentPosition != null) {
        formData = {
          'city_id': currentCity?.id.toString(),
          'lat': currentPosition.latitude.toString(),
          'lon': currentPosition.longitude.toString()
        };
      }

      url = Uri.https('api.lesailes.uz', 'api/terminals/pickup', formData);
      response = await http.get(url, headers: requestHeaders);
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        List<Terminals> terminal = List<Terminals>.from(
            json['data'].map((m) => Terminals.fromJson(m)).toList());
        DateTime currentTime = DateTime.now();
        List<Terminals> resultTerminals = [];
        for (var t in terminal) {
          if (currentTime.weekday >= 1 && currentTime.weekday <= 5) {
            if (t.openWork == null) {
              return null;
            } else {
              DateTime openWork = Date.parse(t.openWork!);
              openWork = openWork.toLocal();
              openWork = openWork.setDay(currentTime.day);
              openWork = openWork.setMonth(currentTime.month);
              openWork = openWork.setYear(currentTime.year);
              DateTime closeWork = Date.parse(t.closeWork!);
              closeWork = closeWork.toLocal();
              closeWork = closeWork.setDay(currentTime.day);
              closeWork = closeWork.setMonth(currentTime.month);
              closeWork = closeWork.setYear(currentTime.year);

              if (closeWork.hour < openWork.hour) {
                closeWork = closeWork.setDay(currentTime.day + 1);
              }
              if (currentTime.isAfter(openWork) &&
                  currentTime.isBefore(closeWork)) {
                t.isWorking = true;
              } else {
                t.isWorking = false;
              }
            }
          } else {
            if (t.openWeekend == null) {
              return null;
            } else {
              DateTime openWork = Date.parse(t.openWeekend!);
              openWork = openWork.toLocal();
              openWork = openWork.setDay(currentTime.day);
              openWork = openWork.setMonth(currentTime.month);
              openWork = openWork.setYear(currentTime.year);
              DateTime closeWork = Date.parse(t.closeWeekend!);
              closeWork = closeWork.toLocal();
              closeWork = closeWork.setDay(currentTime.day);
              closeWork = closeWork.setMonth(currentTime.month);
              closeWork = closeWork.setYear(currentTime.year);

              if (closeWork.hour < openWork.hour) {
                closeWork = closeWork.setDay(currentTime.day + 1);
              }
              if (currentTime.isAfter(openWork) &&
                  currentTime.isBefore(closeWork)) {
                t.isWorking = true;
              } else {
                t.isWorking = false;
              }
            }
          }
          resultTerminals.add(t);
        }

        terminals.value = resultTerminals;
      }
    }

    useEffect(() {
      getTerminals();
    }, []);

    return ValueListenableBuilder<Box<Terminals>>(
        valueListenable: Hive.box<Terminals>('currentTerminal').listenable(),
        builder: (context, box, _) {
          Terminals? currentTerminal =
              Hive.box<Terminals>('currentTerminal').get('currentTerminal');

          var locale = context.locale.toString();
          DateTime currentTime = DateTime.now();

          return Scaffold(
            body: SafeArea(
                child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              n.NikuText(
                                tr('pickup.pageTitle'),
                                style: n.NikuTextStyle(fontSize: 24),
                              ),
                              n.NikuButton(const Icon(
                                Icons.close_outlined,
                                size: 25,
                                color: Colors.black,
                              ))
                                ..p = 0
                                ..m = 0
                                ..onPressed = () {
                                  Navigator.of(context).pop();
                                }
                            ],
                          ),
                        ),
                        Expanded(
                            child: TabBarView(
                                key: _tabKey,
                                controller: tabController,
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 15, right: 15, bottom: 200),
                                child: ListView.builder(
                                    itemCount: terminals.value.length,
                                    itemBuilder: (context, index) {
                                      var terminal = terminals.value[index];
                                      var terminalName = '';
                                      var address = '';
                                      switch (locale) {
                                        case 'en':
                                          terminalName = terminal.nameEn ?? '';
                                          address = terminal.descEn ?? '';
                                          break;
                                        case 'uz':
                                          terminalName = terminal.nameUz ?? '';
                                          address = terminal.descUz ?? '';
                                          break;
                                        default:
                                          terminalName = terminal.name!;
                                          address = terminal.desc ?? '';
                                          break;
                                      }

                                      var fromTime = '';
                                      var toTime = '';
                                      if (currentTime.weekday >= 1 &&
                                          currentTime.weekday <= 5) {
                                        fromTime = DateFormat.Hm().format(
                                            Date.parse(terminal.openWork!)
                                                .toLocal());
                                        toTime = DateFormat.Hm().format(
                                            Date.parse(terminal.closeWork!)
                                                .toLocal());
                                      } else {
                                        fromTime = DateFormat.Hm().format(
                                            Date.parse(terminal.openWeekend!));
                                        toTime = DateFormat.Hm().format(
                                            Date.parse(terminal.closeWeekend!));
                                      }

                                      return InkWell(
                                          onTap: () async {
                                            if (!terminal.isWorking!) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      content: Text(tr(
                                                          'pickup.terminalIsNotWorking'))));
                                              return;
                                            }

                                            localSelectedTerminal.value =
                                                terminal;
                                          },
                                          child: Opacity(
                                              opacity:
                                                  terminal.isWorking! ? 1 : 0.5,
                                              child: Card(
                                                elevation: 5,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25)),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      15.0),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          n.NikuText(
                                                            terminalName,
                                                            style:
                                                                n.NikuTextStyle(
                                                                    fontSize:
                                                                        18),
                                                          )..mb = 10,
                                                          SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.7,
                                                              child: address
                                                                      .isNotEmpty
                                                                  ? n.NikuText(
                                                                      '${tr('pickup.addressLabel')}: $address',
                                                                      style: n.NikuTextStyle(
                                                                          fontSize:
                                                                              14),
                                                                    )
                                                                  : const SizedBox(
                                                                      height: 0,
                                                                    )),
                                                          n.NikuText(
                                                            tr('pickup.workSchedule',
                                                                namedArgs: {
                                                                  'fromTime':
                                                                      fromTime,
                                                                  'toTime':
                                                                      toTime
                                                                }),
                                                            style: n.NikuTextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          )..mt = 10
                                                        ],
                                                      ),
                                                      selectedTerminal !=
                                                                  null &&
                                                              selectedTerminal
                                                                      .id ==
                                                                  terminal.id
                                                          ? Container(
                                                              // height: 26,
                                                              // width: 26,
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .grey
                                                                          .shade200,
                                                                      width:
                                                                          2)),
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20),
                                                                    color: AppColors
                                                                        .mainColor),
                                                                height: 24,
                                                                width: 24,
                                                                margin:
                                                                    const EdgeInsets
                                                                        .all(2),
                                                              ),
                                                            )
                                                          : Container(
                                                              height: 26,
                                                              width: 26,
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .grey
                                                                          .shade200,
                                                                      width:
                                                                          2)),
                                                            )
                                                    ],
                                                  ),
                                                ),
                                              )));
                                    }),
                              ),
                              YandexMap(
                                  mapObjects: mapObjects.value,
                                  zoomGesturesEnabled: zoomGesturesEnabled,
                                  onMapCreated: (YandexMapController
                                      yandexMapController) async {
                                    controller = yandexMapController;
                                    if (currentCity?.lat != null) {
                                      try {
                                        await controller.moveCamera(
                                            CameraUpdate.newCameraPosition(
                                                CameraPosition(
                                                    target: Point(
                                                        latitude: double.parse(
                                                            currentCity!.lat),
                                                        longitude: double.parse(
                                                            currentCity.lon)),
                                                    zoom: 12)),
                                            animation: animation);
                                      } catch (e) {}
                                    }
                                  })
                            ]))
                      ],
                    ))),
            bottomSheet: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.8),
                      spreadRadius: 10,
                      blurRadius: 10,
                      offset: const Offset(0, 7), // changes position of shadow
                    )
                  ]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(30))),
                    child: TabBar(
                      onTap: (index) {},
                      controller: tabController,
                      tabs: [
                        Tab(
                          text: tr('pickup.tabList'),
                        ),
                        Tab(text: tr('pickup.tabMap'))
                      ],
                      // labelPadding: const EdgeInsets.symmetric(vertical: 2),
                      indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.white),
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.black,
                      labelStyle: const TextStyle(fontSize: 15),
                      unselectedLabelStyle: const TextStyle(fontSize: 15),
                    ),
                  ),
                  Container(
                      width: double.infinity,
                      height: 60,
                      margin: const EdgeInsets.only(top: 20),
                      child: n.NikuButton(n.NikuText(
                        tr('pickup.buttonSelectThisBranch'),
                        style:
                            n.NikuTextStyle(color: Colors.white, fontSize: 20),
                      ))
                        ..bg = selectedTerminal == null
                            ? Colors.grey.shade200
                            : AppColors.mainColor
                        ..rounded = 20
                        ..onPressed = () async {
                          if (selectedTerminal == null) {
                            return;
                          }

                          Box<Terminals> transaction =
                              Hive.box<Terminals>('currentTerminal');
                          transaction.put('currentTerminal', selectedTerminal);

                          Map<String, String> requestHeaders = {
                            'Content-type': 'application/json',
                            'Accept': 'application/json'
                          };

                          var stockUrl = Uri.https(
                              'api.lesailes.uz',
                              'api/terminals/get_stock',
                              {'terminal_id': selectedTerminal.id.toString()});
                          var stockResponse =
                              await http.get(stockUrl, headers: requestHeaders);
                          if (stockResponse.statusCode == 200) {
                            var json = jsonDecode(stockResponse.body);
                            Stock newStockData = Stock(
                                prodIds: List<int>.from(json[
                                    'data']) /* json['data'].map((id) => id as int).toList()*/);
                            Box<Stock> box = Hive.box<Stock>('stock');
                            box.put('stock', newStockData);

                            Box<DeliveryType> deliveryBox =
                                Hive.box<DeliveryType>('deliveryType');
                            DeliveryType newDeliveryType = DeliveryType();
                            newDeliveryType.value = DeliveryTypeEnum.pickup;
                            deliveryBox.put('deliveryType', newDeliveryType);

                            // Box<DeliveryLocationData> deliveryLocationBox = Hive.box<DeliveryLocationData>('deliveryLocationData');
                            // deliveryLocationBox.delete('deliveryLocationData');
                            // DeliveryLocationData? deliveryLocationData =
                            // deliveryLocationBox.get('deliveryLocationData');

                            Navigator.of(context).pop();
                          }
                        })
                ],
              ),
            ),
          );
        });
  }
}
