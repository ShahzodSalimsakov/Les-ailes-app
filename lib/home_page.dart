import 'package:flutter/material.dart';
import 'package:les_ailes/widgets/header.dart';
import 'package:les_ailes/widgets/leftMenu.dart';
import 'package:les_ailes/widgets/slider.dart';
import 'package:les_ailes/widgets/way_to_receive_an_order.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const LeftMenu(),
      body: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
            child: Column(
            children: const [Header(), WayToReceiveAnOrder(), SliderCarousel()]),
          )),
    );
  }
}
