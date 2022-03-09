import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class LeftMenu extends StatelessWidget {
  const LeftMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: Center(
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            leading:
                SvgPicture.asset("images/profile.svg", width: 24, height: 24),
            title: Text(
              tr("leftMenu.signIn"),
              style: const TextStyle(color: Colors.black, fontSize: 20),
            ),
            onTap: () {
              // Update the state of the app.
              // ...
            },
          ),
          ListTile(
            leading:
                SvgPicture.asset("images/settings.svg", width: 24, height: 24),
            title: Text(
              tr('leftMenu.settings'),
              style: const TextStyle(color: Colors.black, fontSize: 20),
            ),
            onTap: () {
              // Update the state of the app.
              // ...
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
              // Update the state of the app.
              // ...
            },
          ),
        ],
      ),
    ));
  }
}
