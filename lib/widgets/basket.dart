import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hashids2/hashids2.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:les_ailes/utils/colors.dart';
import 'package:les_ailes/widgets/way_to_receive_an_order.dart';
import 'package:niku/niku.dart' as n;
import 'package:http/http.dart' as http;

import '../models/basket.dart';
import '../models/basket_data.dart';
import '../models/user.dart';
import '../services/user_repository.dart';

class BasketWidget extends HookWidget {
  const BasketWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Box<Basket> basketBox = Hive.box<Basket>('basket');
    Basket? basket = basketBox.get('basket');
    final basketData = useState<BasketData?>(null);
    final hashids = HashIds(
      salt: 'basket',
      minHashLength: 15,
      alphabet: 'abcdefghijklmnopqrstuvwxyz1234567890',
    );

    Future<void> destroyLine(int lineId) async {
      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json'
      };

      var url = Uri.https(
          'api.lesailes.uz', '/api/basket-lines/${hashids.encode(lineId)}');
      var response = await http.delete(url, headers: requestHeaders);
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        Map<String, String> requestHeaders = {
          'Content-type': 'application/json',
          'Accept': 'application/json'
        };

        url = Uri.https('api.lesailes.uz', '/api/baskets/${basket!.encodedId}');
        response = await http.get(url, headers: requestHeaders);
        if (response.statusCode == 200 || response.statusCode == 201) {
          var json = jsonDecode(response.body);
          BasketData newBasket = BasketData.fromJson(json['data']);
          if (newBasket!.lines == null) {
            basket.lineCount = 0;
          } else {
            basket.lineCount = newBasket!.lines!.length ?? 0;
          }

          basketBox.put('basket', basket);
          // await Future.delayed(Duration(milliseconds: 50));
          basketData.value = newBasket;
        }
      }
    }

    Future<void> decreaseQuantity(Lines line) async {
      if (line.quantity == 1) {
        return;
      }

      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json'
      };

      var url = Uri.https(
          'api.lesailes.uz',
          '/api/v1/basket-lines/${hashids.encode(line.id.toString())}/remove',
          {'quantity': '1'});
      var response = await http.put(url, headers: requestHeaders);
      if (response.statusCode == 200 || response.statusCode == 201) {
        var json = jsonDecode(response.body);
        Map<String, String> requestHeaders = {
          'Content-type': 'application/json',
          'Accept': 'application/json'
        };

        url = Uri.https('api.lesailes.uz', '/api/baskets/${basket!.encodedId}');
        response = await http.get(url, headers: requestHeaders);
        if (response.statusCode == 200 || response.statusCode == 201) {
          json = jsonDecode(response.body);
          basketData.value = BasketData.fromJson(json['data']);
        }
      }
    }

    Future<void> increaseQuantity(Lines line) async {
      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json'
      };

      var url = Uri.https(
          'api.lesailes.uz',
          '/api/v1/basket-lines/${hashids.encode(line.id.toString())}/add',
          {'quantity': '1'});
      var response = await http.post(url, headers: requestHeaders);
      if (response.statusCode == 200 || response.statusCode == 201) {
        var json = jsonDecode(response.body);
        Map<String, String> requestHeaders = {
          'Content-type': 'application/json',
          'Accept': 'application/json'
        };

        url = Uri.https('api.lesailes.uz', '/api/baskets/${basket!.encodedId}');
        response = await http.get(url, headers: requestHeaders);
        if (response.statusCode == 200 || response.statusCode == 201) {
          json = jsonDecode(response.body);
          basketData.value = BasketData.fromJson(json['data']);
        }
      }
    }

    Widget renderProductImage(BuildContext context, Lines lineItem) {
      if (lineItem.child != null &&
          lineItem.child!.length > 0 &&
          lineItem.child![0].variant?.product?.id !=
              lineItem.variant?.product?.boxId) {
        return Container(
            margin: EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                color: Colors.grey.shade100),
            height: 104,
            width: 104,
            // margin: EdgeInsets.all(15),
            child: Image.network(
              'https://api.lesailes.uz/storage/${lineItem.variant?.product?.assets![0].location}/${lineItem.variant?.product?.assets![0].filename}',
              height: 104,
            ));
      } else if (lineItem.variant?.product?.assets != null &&
          lineItem.variant!.product!.assets!.isNotEmpty) {
        return Container(
          margin: EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              color: Colors.grey.shade100),
          child: Image.network(
            'https://api.lesailes.uz/storage/${lineItem.variant?.product?.assets![0].location}/${lineItem.variant?.product?.assets![0].filename}',
            width: 104,
            height: 104,
            // width: MediaQuery.of(context).size.width / 2.5,
          ),
        );
      } else {
        return SvgPicture.network(
          'https://lesailes.uz/no_photo.svg',
          width: 104,
          height: 104,
        );
      }
    }

    Widget basketItems(Lines lines) {
      final formatCurrency = NumberFormat.currency(
          locale: 'ru_RU', symbol: 'сум', decimalDigits: 0);
      String? productName = '';
      var productTotalPrice = 0;
      if (lines.child != null && lines.child!.length > 1) {
        productName = lines.variant!.product!.attributeData!.name!.chopar!.ru;
        productTotalPrice = (int.parse(
                    double.parse(lines.total ?? '0.0000').toStringAsFixed(0)) +
                int.parse(double.parse(lines.child![0].total ?? '0.0000')
                    .toStringAsFixed(0))) *
            lines.quantity;
        String childsName = lines.child!
            .where((Child child) =>
                lines.variant!.product!.boxId != child.variant!.product!.id)
            .map((Child child) =>
                child.variant!.product!.attributeData!.name!.chopar!.ru)
            .join(' + ')
            .toString();
        if (childsName.length > 0) {
          productName = '$productName + $childsName';
        }
      } else {
        productName = lines.variant!.product!.attributeData!.name!.chopar!.ru;
        productTotalPrice =
            int.parse(double.parse(lines.total ?? '0.0000').toStringAsFixed(0));
      }
      return Container(
          margin: const EdgeInsets.symmetric(vertical: 15),
          height: 104,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              renderProductImage(context, lines),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      productName ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.62,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            formatCurrency.format(productTotalPrice),
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                        Container(
                          height: 50.0,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(18)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(
                                  Icons.remove,
                                  size: 20.0,
                                ),
                                onPressed: () {
                                  decreaseQuantity(lines);
                                },
                              ),
                              Text(
                                lines.quantity.toString(),
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w700),
                              ),
                              IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(
                                    Icons.add,
                                    size: 20.0,
                                  ),
                                  onPressed: () {
                                    increaseQuantity(lines);
                                  })
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              )
            ],
          ));
    }

    Future<void> getBasket() async {
      if (basket != null) {
        Map<String, String> requestHeaders = {
          'Content-type': 'application/json',
          'Accept': 'application/json'
        };

        var url =
            Uri.https('api.lesailes.uz', '/api/baskets/${basket!.encodedId}');
        var response = await http.get(url, headers: requestHeaders);
        if (response.statusCode == 200 || response.statusCode == 201) {
          var json = jsonDecode(response.body);
          BasketData basketLocalData = BasketData.fromJson(json['data']);
          if (basketLocalData.lines != null) {
            basket.lineCount = basketLocalData.lines!.length;
            basketBox.put('basket', basket);
          }
          basketData.value = basketLocalData;
        }
      }
    }

    useEffect(() {
      getBasket();
    }, []);

    return Material(
        child: Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              // shape: const ContinuousRectangleBorder(
              //     borderRadius: BorderRadius.only(
              //         topRight: Radius.circular(30),
              //         topLeft:  Radius.circular(30))),
              backgroundColor: Colors.transparent,
              elevation: 0,
              pinned: true,
              snap: false,
              floating: false,
              expandedHeight: 100.0,
              foregroundColor: Colors.black,
              actions: [
                GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Padding(
                      padding: EdgeInsets.only(right: 28),
                      child: Center(child: Icon(Icons.close)),
                    ))
              ],
              leading: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Center(
                    child: Image.asset(
                  'images/delete.png',
                  width: 25,
                  height: 25,
                )),
              ),
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                collapseMode: CollapseMode.parallax,
                title: Text(
                  tr("basket.basket"),
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
            SliverList(
              delegate:
                  SliverChildBuilderDelegate((BuildContext context, int index) {
                return Column(
                  children: [
                    const WayToReceiveAnOrder(),
                    const SizedBox(height: 20),
                    const Divider(),
                    ListView.separated(
                        padding: const EdgeInsets.only(top: 0),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemCount: basketData.value!.lines!.length ?? 0,
                        separatorBuilder: (context, index) {
                          return const Divider();
                        },
                        itemBuilder: (context, index) {
                          final item = basketData.value!.lines![index];
                          return item.bonusId != null
                              ? basketItems(item)
                              : Dismissible(
                                  direction: DismissDirection.endToStart,
                                  key: Key(item.id.toString()),
                                  child: basketItems(item),
                                  background: Container(
                                    color: Colors.red,
                                  ),
                                  onDismissed: (DismissDirection direction) {
                                    destroyLine(item.id);
                                  },
                                  secondaryBackground: Container(
                                    color: Colors.red,
                                    child: Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: const [
                                          Icon(Icons.delete,
                                              color: Colors.white),
                                          Text('Удалить',
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                        }),
                    SizedBox(
                      height: 244,
                      child: ListView.builder(
                          shrinkWrap:  true,
                          scrollDirection: Axis.horizontal,
                          itemCount: 15,
                          itemBuilder: (context, index) {
                            return Container(
                              width: 100,
                              color: Colors.green,
                              child: Text('Recomended'),//here you can show the child or data from the list
                            );
                          }),
                    )
                  ],
                );
              }, childCount: 1),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
          child: n.NikuButton.elevated(Text(
        tr(
          'basket.order',
        ),
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
      ))
            ..bg = AppColors.mainColor
            ..color = Colors.white
            ..mx = 16
            ..mt = 10
            ..mb = 28
            ..py = 15
            ..rounded = 20
            ..onPressed = () {}),
    ));
  }
}
