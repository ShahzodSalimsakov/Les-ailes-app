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
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

@RoutePage()
class MyAddressesPage extends HookWidget {
  const MyAddressesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var locale = context.locale.toString();
    final address = useState<List<MyAddress>>(List<MyAddress>.empty());
    final isLoading = useState(false);

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

    useEffect(() {
      getMyAddresses();
    }, []);

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
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
            child: address.value.isEmpty
                ? Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.not_listed_location_outlined,
                            size: 50),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(tr("addressNotFound"),
                            style: const TextStyle(fontSize: 22)),
                      ],
                    ),
                  )
                : isLoading.value
                    ? const Center(
                        child: CircularProgressIndicator(
                        color: AppColors.mainColor,
                      ))
                    : ListView(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        children: [
                          Column(
                            children: [
                              ListView.separated(
                                  separatorBuilder: (context, index) =>
                                      const Divider(
                                        color: Colors.grey,
                                      ),
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: address.value.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final hashids = HashIds(
                                      salt: 'order',
                                      minHashLength: 15,
                                      alphabet:
                                          'abcdefghijklmnopqrstuvwxyz1234567890',
                                    );

                                    final formatCurrency =
                                        NumberFormat.currency(
                                            locale: 'ru_RU',
                                            symbol: locale == 'uz'
                                                ? "so'm"
                                                : locale == 'en'
                                                    ? 'sum'
                                                    : 'сум',
                                            decimalDigits: 0);
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Icon(
                                            Icons.bookmark_border_outlined),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            address.value[index].label != null
                                                ? Text(
                                                    address.value[index].label
                                                            ?.toUpperCase() ??
                                                        '',
                                                    style: const TextStyle(
                                                        fontSize: 18))
                                                : const SizedBox(),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.7,
                                              child: Text(
                                                  address.value[index]
                                                          .address ??
                                                      '',
                                                  style: address.value[index]
                                                              .label !=
                                                          null
                                                      ? TextStyle(
                                                          fontSize: 14,
                                                          color: Colors
                                                              .grey.shade400)
                                                      : const TextStyle(
                                                          fontSize: 18)),
                                            ),
                                          ],
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Future<void> deleteAddress() async {
                                              isLoading.value = true;
                                              Box box = Hive.box<User>('user');
                                              User? currentUser =
                                                  box.get('user');
                                              if (currentUser != null) {
                                                Map<String, String>
                                                    requestHeaders = {
                                                  'Content-type':
                                                      'application/json',
                                                  'Accept': 'application/json',
                                                  'Authorization':
                                                      'Bearer ${currentUser.userToken}'
                                                };
                                                var url = Uri.https(
                                                    'api.lesailes.uz',
                                                    '/api/address/${address.value[index].id}');
                                                var response = await http
                                                    .delete(url,
                                                        headers:
                                                            requestHeaders);
                                                if (response.statusCode ==
                                                    200) {
                                                  getMyAddresses();
                                                  isLoading.value = false;
                                                }
                                              }
                                            }

                                            deleteAddress();
                                          },
                                          child: Image.asset(
                                            'images/delete.png',
                                            height: 25,
                                            width: 30,
                                          ),
                                        )
                                      ],
                                    );
                                  }),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(vertical: 28),
                              //   child: SizedBox(
                              //       height: 60,
                              //       width: double.infinity,
                              //       child: n.NikuButton.elevated(Text(
                              //         tr('newAddress'),
                              //         style: const TextStyle(
                              //             fontSize: 20, fontWeight: FontWeight.w500),
                              //       ))
                              //         ..bg = AppColors.mainColor
                              //         ..color = Colors.white
                              //         ..mx = 36
                              //         ..rounded = 20
                              //         ..onPressed = () {}),
                              // )
                            ],
                          ),
                        ],
                      )),
      ),
    );
  }
}
