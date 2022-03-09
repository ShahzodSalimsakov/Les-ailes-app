import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:niku/niku.dart' as n;

class Header extends StatelessWidget {
  const Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              n.NikuButton(Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(color: Colors.grey, spreadRadius: 1),
                  ],
                ),
                child:
                    SvgPicture.asset("images/menu.svg", width: 24, height: 24),
              ))
                ..onPressed = () {
                  print("text");
                  Scaffold.of(context).openDrawer();
                },
              SvgPicture.asset("images/logo.svg"),
              n.NikuButton(
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(color: Colors.grey, spreadRadius: 1),
                    ],
                  ),
                  child: SvgPicture.asset("images/notification.svg",
                      width: 24, height: 24),
                ),
              )..onPressed = () {}
            ],
          ),
        ),
      ],
    );
  }
}
