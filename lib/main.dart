import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:les_ailes/widgets/header.dart';
import 'package:les_ailes/widgets/leftMenu.dart';
import 'package:niku/niku.dart' as n;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Les Ailes',
      home: Scaffold(
        drawer: const LeftMenu(),
        body: SafeArea(child: Column(children: const [Header()])),
      ),
    );
  }
}
