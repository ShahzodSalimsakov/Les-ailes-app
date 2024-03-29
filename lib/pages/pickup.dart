import 'dart:convert';
import 'package:auto_route/auto_route.dart';
import 'package:dart_date/dart_date.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:les_ailes/models/pickup_type.dart';
import 'package:les_ailes/models/temp_terminals.dart';
import 'package:les_ailes/widgets/pickup/choose_terminal.dart';
import 'package:les_ailes/widgets/pickup/listview.dart';
import 'package:les_ailes/widgets/pickup/map.dart';
import 'package:les_ailes/widgets/pickup/map_selected_terminal.dart';
import 'package:location/location.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:http/http.dart' as http;
import 'package:niku/niku.dart' as n;
import '../models/city.dart';
import '../models/delivery_location_data.dart';
import '../models/terminals.dart';

import '../utils/colors.dart';

@RoutePage()
class PickupPage extends HookWidget {
  late YandexMapController controller;
  final MapObjectId mapObjectCollectionId =
      MapObjectId('map_object_collection');
  final animation =
      const MapAnimation(type: MapAnimationType.smooth, duration: 1.5);

  bool zoomGesturesEnabled = true;

  @override
  Widget build(BuildContext context) {
    final terminals =
        useState<List<TempTerminals>>(List<TempTerminals>.empty());
    City? currentCity = Hive.box<City>('currentCity').get('currentCity');
    final tabController = useTabController(initialLength: 2);
    final defaultTabIndex = useState(0);
    final _tabKey = GlobalKey();
    useState<List<MapObject>>([]);
    final isLoading = useState(false);

    tabController.addListener(() async {
      defaultTabIndex.value = tabController.index;
      PickupType element = PickupType();
      if (tabController.index == 0) {
        element.value = PickupTypeEnum.list;
      } else {
        element.value = PickupTypeEnum.map;
      }
      Box<PickupType> transaction = Hive.box<PickupType>('pickupType');
      transaction.put('pickupType', element);
    });



    Future<void> getTerminals() async {
      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json'
      };
      var formData = {'city_id': currentCity?.id.toString()};

      isLoading.value = true;
      final Box<DeliveryLocationData> deliveryLocationBox =
          Hive.box<DeliveryLocationData>('deliveryLocationData');
      DeliveryLocationData? deliveryData =
          deliveryLocationBox.get('deliveryLocationData');

      if (deliveryData == null) {
      } else if (deliveryData.lat == null) {
      }

      Location location = new Location();

      bool _serviceEnabled;
      bool hasPermission = true;
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
        formData = {
          'city_id': currentCity?.id.toString(),
          'lat': _locationData.latitude.toString(),
          'lon': _locationData.longitude.toString()
        };
      }

      var url = Uri.https('api.lesailes.uz', 'api/terminals/pickup', formData);
      var response = await http.get(url, headers: requestHeaders);
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        List<TempTerminals> terminal = List<TempTerminals>.from(
            json['data'].map((m) => TempTerminals.fromJson(m)).toList());
        DateTime currentTime = DateTime.now();
        List<TempTerminals> resultTerminals = [];
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

              if (closeWork.getHours < openWork.getHours) {
                if (currentTime < openWork && currentTime > closeWork) {
                  t.isWorking = false;
                } else {
                  t.isWorking = true;
                }
              } else {
                if (currentTime < openWork || currentTime > closeWork) {
                  t.isWorking = false;
                } else {
                  t.isWorking = true;
                }
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

              if (closeWork.getHours < openWork.getHours) {
                if (currentTime < openWork && currentTime > closeWork) {
                  t.isWorking = false;
                } else {
                  t.isWorking = true;
                }
              } else {
                if (currentTime < openWork || currentTime > closeWork) {
                  t.isWorking = false;
                } else {
                  t.isWorking = true;
                }
              }
            }
          }
          resultTerminals.add(t);
        }
        isLoading.value = false;
        terminals.value = resultTerminals;
      }
    }

    useEffect(() {
      getTerminals();
      return null;
    }, []);

    return ValueListenableBuilder<Box<Terminals>>(
        valueListenable: Hive.box<Terminals>('currentTerminal').listenable(),
        builder: (context, box, _) {
          Hive.box<Terminals>('currentTerminal').get('currentTerminal');

          context.locale.toString();

          return Scaffold(
            body: SafeArea(
                child: SizedBox(
                    width: double.infinity,
                    child: TabBarView(
                        key: _tabKey,
                        controller: tabController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 15, right: 15, bottom: 175),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                          Box<PickupType> transaction =
                                              Hive.box<PickupType>(
                                                  'pickupType');
                                          transaction.delete('pickupType');
                                          Navigator.of(context).pop();
                                        }
                                    ],
                                  ),
                                ),
                                isLoading.value == true
                                    ? const Expanded(
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: AppColors.mainColor,
                                          ),
                                        ),
                                      )
                                    : terminals.value.isNotEmpty
                                        ? PickupListView(
                                            terminals: terminals.value)
                                        : Expanded(
                                            child: Center(
                                            child:
                                                Text(tr("nearBranchNotFound")),
                                          ))
                              ],
                            ),
                          ),
                          PickupMapViewListen(terminals.value)
                        ]))),
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
                  const PickupMapSelectedTerminal(),
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
                      indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.white),
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.black,
                      labelStyle: const TextStyle(fontSize: 15),
                      unselectedLabelStyle: const TextStyle(fontSize: 15),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerHeight: 0,
                    ),
                  ),
                  ChooseSelecteTerminal()
                ],
              ),
            ),
          );
        });
  }
}
