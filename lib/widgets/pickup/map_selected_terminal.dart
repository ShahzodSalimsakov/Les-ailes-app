import 'package:dart_date/dart_date.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:les_ailes/models/pickup_type.dart';
import 'package:les_ailes/utils/colors.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:niku/niku.dart' as n;

import '../../models/temp_terminals.dart';

class PickupMapSelectedTerminal extends HookWidget {
  @override
  Widget build(BuildContext context) {
    var locale = context.locale.toString();
    return ValueListenableBuilder<Box<PickupType>>(
        valueListenable: Hive.box<PickupType>('pickupType').listenable(),
        builder: (context, box, _) {
          PickupType? pickupType = box.get('pickupType');
          if (pickupType == null) {
            return const SizedBox(
              height: 0,
            );
          } else {
            if (pickupType.value != PickupTypeEnum.map) {
              return const SizedBox(
                height: 0,
              );
            } else {
              return ValueListenableBuilder<Box<TempTerminals>>(
                  valueListenable:
                      Hive.box<TempTerminals>('tempTerminal').listenable(),
                  builder: (context, box, _) {
                    DateTime currentTime = DateTime.now();
                    TempTerminals? terminal = box.get('tempTerminal');
                    if (terminal == null) {
                      return const SizedBox(
                        height: 0,
                      );
                    } else {
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
                        fromTime = DateFormat.Hm()
                            .format(Date.parse(terminal.openWork!).toLocal());
                        toTime = DateFormat.Hm()
                            .format(Date.parse(terminal.closeWork!).toLocal());
                      } else {
                        fromTime = DateFormat.Hm()
                            .format(Date.parse(terminal.openWeekend!));
                        toTime = DateFormat.Hm()
                            .format(Date.parse(terminal.closeWeekend!));
                      }

                      return SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 15, bottom: 30, right: 1),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              n.NikuText(
                                terminalName,
                                style: n.NikuTextStyle(
                                    fontSize: 20, color: Colors.black),
                              )..mb = 10,
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.7,
                                  child: address.isNotEmpty
                                      ? n.NikuText(
                                          '${tr('pickup.addressLabel')}: $address',
                                          style: n.NikuTextStyle(fontSize: 16),
                                        )
                                      : const SizedBox(
                                          height: 0,
                                        )),
                              SizedBox(
                                height: 20,
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    FaIcon(FontAwesomeIcons.clock),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    n.NikuText(
                                      tr('pickup.scheduleLabel'),
                                      style: n.NikuTextStyle(fontSize: 20),
                                    ),
                                    Spacer(),
                                    n.NikuText(
                                      tr('pickup.workScheduleNumbers',
                                          namedArgs: {
                                            'fromTime': fromTime,
                                            'toTime': toTime
                                          }),
                                      style: n.NikuTextStyle(
                                          color: AppColors.mainColor,
                                          fontSize: 20),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              n.NikuButton(Row(
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.route,
                                    color: AppColors.plum,
                                  ),
                                  SizedBox(width: 15,),
                                  n.NikuText(
                                    tr('pickup.showRoute'),
                                    style: n.NikuTextStyle(
                                        color: AppColors.plum, fontSize: 20),
                                  )
                                ],
                              ))
                                ..onPressed = () {
                                  MapsLauncher.launchCoordinates(double.parse(terminal.latitude!), double.parse(terminal.longitude!));
                                }
                            ],
                          ),
                        ),
                      );
                    }
                  });
            }
          }
        });
  }
}
