import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:les_ailes/routes/router.gr.dart';
import 'package:niku/niku.dart' as n;

class Header extends StatelessWidget {
  const Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [ Container(
        color: Colors.white,
        child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                n.NikuButton(Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.grey.shade200, spreadRadius: 1),
                    ],
                  ),
                  child:
                      SvgPicture.asset("images/menu.svg", width: 20, height: 20),
                ))
                  ..onPressed = () {
                    Scaffold.of(context).openDrawer();
                  },
                SvgPicture.asset("images/logo.svg", height: 20,),
                n.NikuButton(
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(color: Colors.grey.shade200, spreadRadius: 1),
                      ],
                    ),
                    child: SvgPicture.asset("images/notification.svg",
                        width: 20, height: 20),
                  ),
                )..onPressed = () {
                    context.router.pushNamed("notifications");
                  }
              ],
            ),
      ),
      ],
    );
  }
}
