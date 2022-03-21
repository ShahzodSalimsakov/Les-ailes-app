import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:auto_route/auto_route.dart';
import 'package:les_ailes/routes/router.gr.dart';
import 'package:url_launcher/url_launcher.dart';

class LeftMenu extends StatefulWidget {
  const LeftMenu({Key? key}) : super(key: key);

  @override
  State<LeftMenu> createState() => _LeftMenuState();
}

class _LeftMenuState extends State<LeftMenu> {
  Future<void>? _launched;

  @override
  Future<void> _launchInBrowser(String url) async {
    if (!await launch(
      url,
      forceSafariVC: false,
      forceWebView: false,
      headers: <String, String>{'my_header_key': 'my_header_value'},
    )) {
      throw 'Could not launch $url';
    }
  }

  Widget build(BuildContext context) {
    const String toLaunch = 'https://t.me/lesaileshelpbot';
    return Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 1),
          ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                leading: SvgPicture.asset("images/profile.svg",
                    width: 24, height: 24),
                title: Text(
                  tr("leftMenu.signIn"),
                  style: const TextStyle(color: Colors.black, fontSize: 20),
                ),
                onTap: () {
                  context.router.pushNamed("/signIn");
                },
              ),
              ListTile(
                leading: SvgPicture.asset("images/settings.svg",
                    width: 24, height: 24),
                title: Text(
                  tr('leftMenu.settings'),
                  style: const TextStyle(color: Colors.black, fontSize: 20),
                ),
                onTap: () {
                  context.router.pushNamed("/settings");
                },
              ),
              ListTile(
                leading:
                    SvgPicture.asset("images/about.svg", width: 24, height: 24),
                title: Text(
                  tr("leftMenu.aboutUs"),
                  style: const TextStyle(color: Colors.black, fontSize: 20),
                ),
                onTap: () {
                  context.router.pushNamed("/about");
                },
              ),
            ],
          ),
          const Spacer(flex: 1),
          GestureDetector(
            onTap: () => setState(() {
              _launched = _launchInBrowser(toLaunch);
            }),
            child: Container(
              padding: const EdgeInsets.all(10),
              margin:
                  const EdgeInsets.only(bottom: 50, left: 0, right: 30, top: 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey.shade200,
              ),
              height: 75,
              width: 233,
              child: Row(
                children: [
                  SvgPicture.asset('images/chat.svg', width: 50, height: 50),
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 0, left: 10, bottom: 0, top: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr("leftMenu.writeUs"),
                          style: const TextStyle(
                              color: Colors.black, fontSize: 20),
                        ),
                        SizedBox(
                          width: 150,
                          child: Text(
                            tr("leftMenu.writeUsDesc"),
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
