import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:les_ailes/widgets/ChooseCity.dart';
import 'package:les_ailes/widgets/header.dart';
import 'package:les_ailes/widgets/leftMenu.dart';
import 'package:les_ailes/widgets/productList.dart';
import 'package:les_ailes/widgets/slider.dart';
import 'package:les_ailes/widgets/ui/fixed_basket.dart';
import 'package:les_ailes/widgets/way_to_receive_an_order.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        title: const Header(),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: const LeftMenu(),
      body: SafeArea(
          child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
        child: ListView(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          children: [
            Column(children: [
              // const Header(),
              const ChooseCity(),
              const WayToReceiveAnOrder(),
              SliderCarousel(),
              const ProductList()
            ])
          ],
        ),
      )),
      bottomNavigationBar: const FixedBasket(),
    );
  }
}
