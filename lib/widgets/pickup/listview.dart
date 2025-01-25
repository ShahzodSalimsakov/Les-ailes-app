import 'package:dart_date/dart_date.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:les_ailes/models/temp_terminals.dart';
import 'package:les_ailes/models/terminals.dart';
import 'package:niku/niku.dart' as n;

import '../../utils/colors.dart';

class PickupListView extends HookWidget {
  final List<TempTerminals> terminals;

  const PickupListView({Key? key, required this.terminals}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var locale = context.locale.toString();
    DateTime currentTime = DateTime.now();
    return Expanded(
      child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: terminals.length,
          itemBuilder: (context, index) {
            var terminal = terminals[index];
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
            if (currentTime.weekday >= 1 && currentTime.weekday <= 5) {
              if (terminal.openWork != null && terminal.closeWork != null) {
                var openWorkTime = DateTime.parse(terminal.openWork!).toLocal();
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

            return ValueListenableBuilder<Box<TempTerminals>>(
                valueListenable:
                    Hive.box<TempTerminals>('tempTerminal').listenable(),
                builder: (context, box, _) {
                  TempTerminals? selectedTerminal = box.get('tempTerminal');
                  return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () async {
                        if (terminal.isWorking != true) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content:
                                  Text(tr('pickup.terminalIsNotWorking'))));
                          return;
                        }

                        Box<TempTerminals> transaction =
                            Hive.box<TempTerminals>('tempTerminal');
                        transaction.put('tempTerminal', terminal);
                      },
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                        child: Opacity(
                          opacity: terminal.isWorking == true ? 1 : 0.5,
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      n.NikuText(
                                        terminalName,
                                        style: n.NikuTextStyle(fontSize: 18),
                                      )..mb = 10,
                                      address.isNotEmpty
                                          ? n.NikuText(
                                              '${tr('pickup.addressLabel')}: $address',
                                              style:
                                                  n.NikuTextStyle(fontSize: 14),
                                            )
                                          : const SizedBox(height: 0),
                                      n.NikuText(
                                        tr('pickup.workSchedule', namedArgs: {
                                          'fromTime': fromTime,
                                          'toTime': toTime
                                        }),
                                        style: n.NikuTextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      )..mt = 10
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                selectedTerminal != null &&
                                        selectedTerminal.id == terminal.id
                                    ? Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                                color: Colors.grey.shade200,
                                                width: 2)),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              color: AppColors.mainColor),
                                          height: 24,
                                          width: 24,
                                          margin: const EdgeInsets.all(2),
                                        ),
                                      )
                                    : Container(
                                        height: 26,
                                        width: 26,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                                color: Colors.grey.shade200,
                                                width: 2)),
                                      )
                              ],
                            ),
                          ),
                        ),
                      ));
                });
          }),
    );
  }
}
