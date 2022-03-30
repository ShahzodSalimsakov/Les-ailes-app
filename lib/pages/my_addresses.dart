import 'dart:convert';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hashids2/hashids2.dart';
import 'package:hive/hive.dart';
import '../models/my_address.dart';
import '../models/user.dart';
import '../utils/colors.dart';
import 'package:http/http.dart' as http;
import 'package:niku/niku.dart' as n;

class MyAddresses extends HookWidget {
  const MyAddresses({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final address = useState<List<MyAddress>>(List<MyAddress>.empty());

    Future<void> getMyAddresses() async {
      Box box = Hive.box<User>('user');
      User? currentUser = box.get('user');
      if (currentUser != null) {
        Map<String, String> requestHeaders = {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${currentUser.userToken}'
        };
        var url = Uri.https('api.lesailes.uz', '/api/address/my_addresses');
        var response = await http.get(url, headers: requestHeaders);
        if (response.statusCode == 200) {
          var json = jsonDecode(response.body);
          List<MyAddress> addressList = List<MyAddress>.from(
              json['data'].map((m) => MyAddress.fromJson(m)).toList());
          address.value = addressList;
        }
      }
    }

    // Future<void> deleteAddress() async {
    //   Box box = Hive.box<User>('user');
    //   User? currentUser = box.get('user');
    //   if (currentUser != null) {
    //     Map<String, String> requestHeaders = {
    //       'Content-type': 'application/json',
    //       'Accept': 'application/json',
    //       'Authorization': 'Bearer ${currentUser.userToken}'
    //     };
    //     var url = Uri.https('api.lesailes.uz', '/api/address/${address.value}');
    //     var response = await http.get(url, headers: requestHeaders);
    //     if (response.statusCode == 200) {
    //       var json = jsonDecode(response.body);
    //       List<MyAddress> addressList = List<MyAddress>.from(
    //           json['data'].map((m) => MyAddress.fromJson(m)).toList());
    //       address.value = addressList;
    //     }
    //   }
    // }

    useEffect(() {
      getMyAddresses();
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(tr("leftMenu.myAddresses"),
            style: const TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              children: [
                Column(
                  children: [
                    ListView.separated(
                        separatorBuilder: (context, index) => const Divider(
                              color: Colors.grey,
                            ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: address.value.length,
                        itemBuilder: (BuildContext context, int index) {
                          final hashids = HashIds(
                            salt: 'order',
                            minHashLength: 15,
                            alphabet: 'abcdefghijklmnopqrstuvwxyz1234567890',
                          );

                          final formatCurrency = NumberFormat.currency(
                              locale: 'ru_RU', symbol: 'сум', decimalDigits: 0);
                          return Container(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              // margin: const EdgeInsets.symmetric(
                              //     vertical: 10, horizontal: 15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.7,
                                        child: Text(
                                            address.value[index].address ?? '',
                                            style:
                                                const TextStyle(fontSize: 18)),
                                      ),
                                      const SizedBox(
                                        height: 6,
                                      ),
                                      Text("Мой дом",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade400)),
                                    ],
                                  ),
                                  Image.asset(
                                    'images/delete.png',
                                    height: 25,
                                    width: 30,
                                  )
                                ],
                              ));
                        }),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      child: SizedBox(
                          height: 60,
                          width: double.infinity,
                          child: n.NikuButton.elevated(Text(
                            tr('newAddress'),
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500),
                          ))
                            ..bg = AppColors.mainColor
                            ..color = Colors.white
                            ..mx = 36
                            ..rounded = 20
                            ..onPressed = () {}),
                    )
                  ],
                ),
              ],
            )),
      ),
    );
  }
}
