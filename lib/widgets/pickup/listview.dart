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
              fromTime = DateFormat.Hm()
                  .format(Date.parse(terminal.openWork!).toLocal());
              toTime = DateFormat.Hm()
                  .format(Date.parse(terminal.closeWork!).toLocal());
            } else {
              fromTime =
                  DateFormat.Hm().format(Date.parse(terminal.openWeekend!));
              toTime =
                  DateFormat.Hm().format(Date.parse(terminal.closeWeekend!));
            }

            return ValueListenableBuilder<Box<TempTerminals>>(
                valueListenable:
                    Hive.box<TempTerminals>('tempTerminal').listenable(),
                builder: (context, box, _) {
                  TempTerminals? selectedTerminal = box.get('tempTerminal');
                  return InkWell(
                      onTap: () async {
                        if (!terminal.isWorking!) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content:
                                  Text(tr('pickup.terminalIsNotWorking'))));
                          return;
                        }

                        Box<TempTerminals> transaction =
                            Hive.box<TempTerminals>('tempTerminal');
                        transaction.put('tempTerminal', terminal);
                      },
                      child: Opacity(
                          opacity: terminal.isWorking! ? 1 : 0.5,
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25)),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      n.NikuText(
                                        terminalName,
                                        style: n.NikuTextStyle(fontSize: 18),
                                      )..mb = 10,
                                      SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.7,
                                          child: address.isNotEmpty
                                              ? n.NikuText(
                                                  '${tr('pickup.addressLabel')}: $address',
                                                  style: n.NikuTextStyle(
                                                      fontSize: 14),
                                                )
                                              : const SizedBox(
                                                  height: 0,
                                                )),
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
                                  selectedTerminal != null &&
                                          selectedTerminal.id == terminal.id
                                      ? Container(
                                          // height: 26,
                                          // width: 26,
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
                          )));
                });
          }),
    );
  }
}
