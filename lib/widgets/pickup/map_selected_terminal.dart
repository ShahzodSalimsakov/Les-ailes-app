import 'package:dart_date/dart_date.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:les_ailes/models/pickup_type.dart';
import 'package:les_ailes/utils/colors.dart';
import 'package:les_ailes/widgets/pickup/map_selection.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:niku/niku.dart' as n;

import '../../models/temp_terminals.dart';

class PickupMapSelectedTerminal extends HookWidget {
  const PickupMapSelectedTerminal({Key? key}) : super(key: key);

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
                        if (terminal.openWork != null &&
                            terminal.closeWork != null) {
                          var openWorkTime =
                              DateTime.parse(terminal.openWork!).toLocal();
                          var closeWorkTime =
                              DateTime.parse(terminal.closeWork!).toLocal();
                          fromTime =
                              '${openWorkTime.hour.toString().padLeft(2, '0')}:${openWorkTime.minute.toString().padLeft(2, '0')}';
                          toTime =
                              '${closeWorkTime.hour.toString().padLeft(2, '0')}:${closeWorkTime.minute.toString().padLeft(2, '0')}';
                        }
                      } else {
                        if (terminal.openWeekend != null &&
                            terminal.closeWeekend != null) {
                          var openWeekendTime =
                              DateTime.parse(terminal.openWeekend!).toLocal();
                          var closeWeekendTime =
                              DateTime.parse(terminal.closeWeekend!).toLocal();
                          fromTime =
                              '${openWeekendTime.hour.toString().padLeft(2, '0')}:${openWeekendTime.minute.toString().padLeft(2, '0')}';
                          toTime =
                              '${closeWeekendTime.hour.toString().padLeft(2, '0')}:${closeWeekendTime.minute.toString().padLeft(2, '0')}';
                        }
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
                              const SizedBox(
                                height: 20,
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const FaIcon(FontAwesomeIcons.clock),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    n.NikuText(
                                      tr('pickup.scheduleLabel'),
                                      style: n.NikuTextStyle(fontSize: 20),
                                    ),
                                    const Spacer(),
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
                              const SizedBox(
                                height: 30,
                              ),
                              MapSelection(
                                  latitude: double.parse(terminal.latitude!),
                                  longitude: double.parse(terminal.longitude!),
                                  desc: address)
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
