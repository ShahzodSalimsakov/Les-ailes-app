import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:les_ailes/utils/colors.dart';

@RoutePage()
class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  bool status = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(tr("settings.settings"),
            style: const TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  margin: const EdgeInsets.only(top: 40, bottom: 50),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(width: 1.0, color: AppColors.grey),
                      bottom: BorderSide(width: 1.0, color: AppColors.grey),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 180,
                            child: Text(tr("settings.reportPoints"),
                                style: const TextStyle(fontSize: 20)),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          Text(tr("settings.pushNotify"),
                              style: TextStyle(
                                  fontSize: 15, color: Colors.grey.shade400)),
                        ],
                      ),
                      FlutterSwitch(
                        width: 50.0,
                        height: 30.0,
                        value: status,
                        padding: 2,
                        borderRadius: 30.0,
                        inactiveColor: Colors.grey.shade300,
                        activeColor: AppColors.green,
                        onToggle: (val) {
                          setState(() {
                            status = val;
                          });
                        },
                      ),
                    ],
                  )),
              GestureDetector(
                onTap: () {
                  context.router.pushNamed("/changeLang");
                },
                child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 1.0, color: AppColors.grey),
                        bottom: BorderSide(width: 1.0, color: AppColors.grey),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              // width: 180,
                              child: Text(tr("settings.changeLang"),
                                  style: const TextStyle(fontSize: 20)),
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_forward_ios)
                      ],
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
