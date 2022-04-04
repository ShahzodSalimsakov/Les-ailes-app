import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class BasketWidget extends StatelessWidget {
  const BasketWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        extendBody: false,
            appBar: AppBar(
              leading: const SizedBox(width: 0,),
              title: const Text('asd', style: TextStyle(color: Colors.black)),
              centerTitle: true,
              backgroundColor: Colors.yellow,
              elevation: 0,
            ),
            body: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('aaaaaaaaaaaaaaaa'),
                      Text('aaaaaaaaaaaaaaaa'),
                      Text('aaaaaaaaaaaaaaaa'),
                      Text('aaaaaaaaaaaaaaaa'),
                      Text('aaaaaaaaaaaaaaaa'),
                    ],
                  ),
              ),
            ),
          ),
    );
  }
}
