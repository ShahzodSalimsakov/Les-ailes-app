import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hashids2/hashids2.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:les_ailes/models/related_product.dart';
import 'package:les_ailes/pages/order_success.dart';
import 'package:les_ailes/utils/colors.dart';
import 'package:les_ailes/widgets/choose_delivery_time.dart';
import 'package:les_ailes/widgets/pay_type/choose_pay_type.dart';
import 'package:les_ailes/widgets/way_to_receive_an_order.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:niku/niku.dart' as n;
import 'package:http/http.dart' as http;

import '../models/additional_phone_number.dart';
import '../models/basket.dart';
import '../models/basket_data.dart';
import '../models/basket_item_quantity.dart';
import '../models/deliver_later_time.dart';
import '../models/delivery_location_data.dart';
import '../models/delivery_notes.dart';
import '../models/delivery_time.dart';
import '../models/delivery_type.dart';
import '../models/order.dart';
import '../models/pay_cash.dart';
import '../models/pay_type.dart';
import '../models/productSection.dart';
import '../models/terminals.dart';
import '../models/user.dart';
import '../services/user_repository.dart';
import 'additional_phone_number.dart';
import 'comment.dart';

class BasketWidget extends HookWidget {
  const BasketWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Box<Basket> basketBox = Hive.box<Basket>('basket');
    Basket? basket = basketBox.get('basket');
    final _isOrderLoading = useState<bool>(false);
    final basketData = useState<BasketData?>(null);
    final relatedData =
        useState<List<RelatedProduct>>(List<RelatedProduct>.empty());
    final hashids = HashIds(
      salt: 'basket',
      minHashLength: 15,
      alphabet: 'abcdefghijklmnopqrstuvwxyz1234567890',
    );
    final _isBasketLoading = useState<bool>(false);
    final deliveryPrice = useState(0);
    Box<DeliveryType> box = Hive.box<DeliveryType>('deliveryType');
    DeliveryType? deliveryType = box.get('deliveryType');

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
          if (newBasket.lines == null) {
            basket.lineCount = 0;
          } else {
            basket.lineCount = newBasket!.lines!.length ?? 0;
          }

          basket.totalPrice = newBasket.total;
          basketBox.put('basket', basket);
          // await Future.delayed(Duration(milliseconds: 50));
          basketData.value = newBasket;
          if (basket.lineCount == 0) {
            Navigator.of(context).pop();
          }
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
          Basket newBasket = Basket(
              encodedId: basket.encodedId ?? '',
              lineCount: basketData!.value!.lines?.length ?? 0,
              totalPrice: basketData!.value!.total);
          basketBox.put('basket', newBasket);
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
          Basket newBasket = Basket(
              encodedId: basket.encodedId ?? '',
              lineCount: basketData!.value!.lines?.length ?? 0,
              totalPrice: basketData!.value!.total);
          basketBox.put('basket', newBasket);
        }
      }
    }

    Widget renderProductImage(BuildContext context, Lines lineItem) {
      if (lineItem.child != null &&
          lineItem.child!.isNotEmpty &&
          lineItem.child![0].variant?.product?.id !=
              lineItem.variant?.product?.boxId) {
        return Container(
            margin: const EdgeInsets.only(right: 10),
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
          margin: const EdgeInsets.only(right: 10),
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
        if (childsName.isNotEmpty) {
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
                            color: Colors.grey.shade100,
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

    String totalPrice = useMemoized(() {
      String result = '0';
      if (basketData.value != null) {
        if (deliveryPrice.value > 0) {
          result = (basketData.value!.total + deliveryPrice.value).toString();
        } else {
          result = basketData.value!.total.toString();
        }
      }

      final formatCurrency = NumberFormat.currency(
          locale: 'ru_RU', symbol: 'сум', decimalDigits: 0);

      result = formatCurrency.format(double.tryParse(result));
      return result;
    }, [basketData.value, deliveryPrice.value]);

    Future<void> getBasket() async {
      if (basket != null) {
        Map<String, String> requestHeaders = {
          'Content-type': 'application/json',
          'Accept': 'application/json'
        };

        var url =
            Uri.https('api.lesailes.uz', '/api/baskets/${basket.encodedId}');
        var response = await http.get(url, headers: requestHeaders);
        if (response.statusCode == 200 || response.statusCode == 201) {
          _isBasketLoading.value = true;
          var json = jsonDecode(response.body);
          BasketData basketLocalData = BasketData.fromJson(json['data']);
          if (basketLocalData.lines != null) {
            basket.lineCount = basketLocalData.lines!.length;
            basketBox.put('basket', basket);

            Box<DeliveryType> box = Hive.box<DeliveryType>('deliveryType');
            DeliveryType? deliveryType = box.get('deliveryType');

            DeliveryLocationData? deliveryLocationData =
                Hive.box<DeliveryLocationData>('deliveryLocationData')
                    .get('deliveryLocationData');

            Terminals? currentTerminal =
                Hive.box<Terminals>('currentTerminal').get('currentTerminal');

            if (deliveryType?.value == DeliveryTypeEnum.deliver) {
              var urlDeliveryPrice = Uri.https(
                  'api.lesailes.uz', '/api/orders/calc_basket_delivery', {
                "lat": deliveryLocationData?.lat.toString(),
                "lon": deliveryLocationData?.lon.toString(),
                "terminal_id": currentTerminal?.id.toString(),
                "total_price": basketLocalData.total.toString()
              });
              var deliveryPriceResponse =
                  await http.get(urlDeliveryPrice, headers: requestHeaders);
              if (deliveryPriceResponse.statusCode == 200) {
                var json = jsonDecode(deliveryPriceResponse.body);
                deliveryPrice.value = json['totalPrice'];
              }
            } else {
              deliveryPrice.value = 0;
            }
          }
          basketData.value = basketLocalData;
          _isBasketLoading.value = false;
        }
      }
    }

    Future<void> fetchRecomendedItems() async {
      if (basket != null) {
        Map<String, String> requestHeaders = {
          'Content-type': 'application/json',
          'Accept': 'application/json'
        };

        var url = Uri.https(
            'api.lesailes.uz', '/api/baskets/related/${basket.encodedId}');
        var response = await http.get(url, headers: requestHeaders);
        if (response.statusCode == 200 || response.statusCode == 201) {
          var json = jsonDecode(response.body);
          List<RelatedProduct> localRelatedProduct = List<RelatedProduct>.from(
              json['data'].map((m) => RelatedProduct.fromJson(m)).toList());
          relatedData.value = localRelatedProduct;
        }
      }
    }

    Future<void> clearBasket() async {
      if (basket != null) {
        Map<String, String> requestHeaders = {
          'Content-type': 'application/json',
          'Accept': 'application/json'
        };

        var url = Uri.https(
            'api.lesailes.uz', '/api/baskets/${basket.encodedId}/clear');
        var response = await http.get(url, headers: requestHeaders);
        if (response.statusCode == 200 || response.statusCode == 201) {
          var json = jsonDecode(response.body);
          BasketData newBasket = BasketData.fromJson(json['data']);
          if (newBasket.lines == null) {
            basket.lineCount = 0;
          } else {
            basket.lineCount = newBasket!.lines!.length ?? 0;
          }

          basketBox.put('basket', basket);
          basket.totalPrice = newBasket.total;
          // await Future.delayed(Duration(milliseconds: 50));
          basketData.value = newBasket;
          Box<BasketItemQuantity> basketItemQuantityBox =
              Hive.box<BasketItemQuantity>('basketItemQuantity');
          await basketItemQuantityBox.clear();
          if (basket.lineCount == 0) {
            Navigator.of(context).pop();
          }
        }
      }
    }

    String cashback = useMemoized(() {
      String result = '0';
      if (basketData.value != null) {
        result = (basketData.value!.total * 0.05).round().toString();
      }

      final formatCurrency = NumberFormat.currency(
          locale: 'ru_RU', symbol: 'сум', decimalDigits: 0);

      result = formatCurrency.format(double.tryParse(result));
      return result;
    }, [basketData.value]);

    String productsTotalPrice = useMemoized(() {
      String result = '0';
      if (basketData.value != null) {
        result = basketData.value!.total.toString();
      }

      final formatCurrency = NumberFormat.currency(
          locale: 'ru_RU', symbol: 'сум', decimalDigits: 0);

      result = formatCurrency.format(double.tryParse(result));
      return result;
    }, [basketData.value]);

    useEffect(() {
      getBasket();
      fetchRecomendedItems();
      return null;
    }, [deliveryType]);

    return Material(
        child: Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Stack(
          children: [
            CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  // shape: const ContinuousRectangleBorder(
                  //     borderRadius: BorderRadius.only(
                  //         topRight: Radius.circular(30),
                  //         topLeft:  Radius.circular(30))),
                  backgroundColor: Colors.white,
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
                  leading: GestureDetector(
                    onTap: () {
                      clearBasket();
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Center(
                          child: Image.asset(
                        'images/delete.png',
                        width: 25,
                        height: 25,
                      )),
                    ),
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
                  delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                    Box<DeliveryType> box =
                        Hive.box<DeliveryType>('deliveryType');
                    DeliveryType? deliveryType = box.get('deliveryType');

                    final formatCurrency = NumberFormat.currency(
                        locale: 'ru_RU', symbol: 'сум', decimalDigits: 0);
                    return Column(
                      children: [
                        const SizedBox(height: 20),
                        // const WayToReceiveAnOrder(),
                        const SizedBox(height: 20),
                        const Divider(),
                        _isBasketLoading.value != false
                            ? const CircularProgressIndicator(
                                color: AppColors.mainColor,
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.only(top: 0),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                itemCount: basketData.value?.lines?.length ?? 0,
                                separatorBuilder: (context, index) {
                                  return const Divider();
                                },
                                itemBuilder: (context, index) {
                                  final item = basketData.value!.lines![index];
                                  return item.bonusId != null
                                      ? basketItems(item)
                                      : Dismissible(
                                          direction:
                                              DismissDirection.endToStart,
                                          key: Key(item.id.toString()),
                                          child: basketItems(item),
                                          background: Container(
                                            color: Colors.red,
                                          ),
                                          onDismissed:
                                              (DismissDirection direction) {
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
                        relatedData.value.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(
                                  top: 45,
                                  bottom: 10,
                                ),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(tr('basket.addToOrder'),
                                        style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w500))),
                              )
                            : const SizedBox(),
                        relatedData.value.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(bottom: 30),
                                child: SizedBox(
                                  height: 280,
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: relatedData.value.length,
                                      itemBuilder: (context, index) {
                                        final formatCurrency =
                                            NumberFormat.currency(
                                                locale: 'ru_RU',
                                                symbol: 'сум',
                                                decimalDigits: 0);
                                        String productPrice = '';

                                        productPrice =
                                            relatedData.value[index].price;

                                        productPrice = formatCurrency.format(
                                            double.tryParse(productPrice));
                                        return Container(
                                            width: 140,
                                            margin: const EdgeInsets.only(
                                                right: 10),
                                            child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10,
                                                        horizontal: 10),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  color: Colors.white,
                                                ),
                                                child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Image.network(
                                                        relatedData
                                                            .value[index].image,
                                                        height: 140,
                                                        width: 140,
                                                      ),
                                                      const Spacer(
                                                        flex: 1,
                                                      ),
                                                      Text(
                                                        relatedData.value[index]
                                                            .customName,
                                                        style: const TextStyle(
                                                            fontSize: 20),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                      const Spacer(
                                                        flex: 1,
                                                      ),
                                                      SizedBox(
                                                        height: 50,
                                                        width: 144,
                                                        child: ElevatedButton(
                                                          onPressed: () async {
                                                            List<
                                                                    Map<String,
                                                                        int>>?
                                                                selectedModifiers;
                                                            _isBasketLoading
                                                                .value = true;

                                                            int selectedProdId =
                                                                relatedData
                                                                    .value[
                                                                        index]
                                                                    .id;

                                                            Box userBox =
                                                                Hive.box<User>(
                                                                    'user');
                                                            User? user = userBox
                                                                .get('user');
                                                            Box basketBox = Hive
                                                                .box<Basket>(
                                                                    'basket');
                                                            Basket? basket =
                                                                basketBox.get(
                                                                    'basket');

                                                            if (basket !=
                                                                    null &&
                                                                basket.encodedId
                                                                    .isNotEmpty &&
                                                                basket.encodedId
                                                                    .isNotEmpty) {
                                                              Map<String,
                                                                      String>
                                                                  requestHeaders =
                                                                  {
                                                                'Content-type':
                                                                    'application/json',
                                                                'Accept':
                                                                    'application/json'
                                                              };

                                                              if (user !=
                                                                  null) {
                                                                requestHeaders[
                                                                        'Authorization'] =
                                                                    'Bearer ${user.userToken}';
                                                              }

                                                              var url = Uri.https(
                                                                  'api.lesailes.uz',
                                                                  '/api/baskets-lines');
                                                              var formData = {
                                                                'basket_id': basket
                                                                    .encodedId,
                                                                'variants': [
                                                                  {
                                                                    'id':
                                                                        selectedProdId,
                                                                    'quantity':
                                                                        1,
                                                                    'modifiers':
                                                                        selectedModifiers
                                                                  }
                                                                ]
                                                              };
                                                              var response = await http.post(
                                                                  url,
                                                                  headers:
                                                                      requestHeaders,
                                                                  body: jsonEncode(
                                                                      formData));
                                                              if (response.statusCode ==
                                                                      200 ||
                                                                  response.statusCode ==
                                                                      201) {
                                                                var json =
                                                                    jsonDecode(
                                                                        response
                                                                            .body);
                                                                BasketData
                                                                    basketLocalData =
                                                                    BasketData
                                                                        .fromJson(
                                                                            json['data']);
                                                                Basket newBasket = Basket(
                                                                    encodedId:
                                                                        basketLocalData.encodedId ??
                                                                            '',
                                                                    lineCount: basketLocalData
                                                                            .lines
                                                                            ?.length ??
                                                                        0,
                                                                    totalPrice:
                                                                        basketLocalData
                                                                            .total);
                                                                basketBox.put(
                                                                    'basket',
                                                                    newBasket);
                                                                basketData
                                                                        .value =
                                                                    basketLocalData;
                                                              }
                                                            } else {
                                                              Map<String,
                                                                      String>
                                                                  requestHeaders =
                                                                  {
                                                                'Content-type':
                                                                    'application/json',
                                                                'Accept':
                                                                    'application/json'
                                                              };

                                                              if (user !=
                                                                  null) {
                                                                requestHeaders[
                                                                        'Authorization'] =
                                                                    'Bearer ${user.userToken}';
                                                              }

                                                              var url = Uri.https(
                                                                  'api.lesailes.uz',
                                                                  '/api/baskets');
                                                              var formData = {
                                                                'variants': [
                                                                  {
                                                                    'id':
                                                                        selectedProdId,
                                                                    'quantity':
                                                                        1,
                                                                    'modifiers':
                                                                        selectedModifiers
                                                                  }
                                                                ]
                                                              };
                                                              var response = await http.post(
                                                                  url,
                                                                  headers:
                                                                      requestHeaders,
                                                                  body: jsonEncode(
                                                                      formData));
                                                              if (response.statusCode ==
                                                                      200 ||
                                                                  response.statusCode ==
                                                                      201) {
                                                                var json =
                                                                    jsonDecode(
                                                                        response
                                                                            .body);
                                                                BasketData
                                                                    basketLocalData =
                                                                    BasketData
                                                                        .fromJson(
                                                                            json['data']);
                                                                Basket newBasket = Basket(
                                                                    encodedId:
                                                                        basketLocalData.encodedId ??
                                                                            '',
                                                                    lineCount: basketLocalData
                                                                            .lines
                                                                            ?.length ??
                                                                        0,
                                                                    totalPrice:
                                                                        basketLocalData
                                                                            .total);
                                                                basketBox.put(
                                                                    'basket',
                                                                    newBasket);
                                                                basketData
                                                                        .value =
                                                                    basketLocalData;
                                                              }
                                                            }
                                                            _isBasketLoading
                                                                .value = false;

                                                            return;
                                                          },
                                                          child: Text(
                                                              productPrice),
                                                          style: ButtonStyle(
                                                            shape: MaterialStateProperty.all<
                                                                    RoundedRectangleBorder>(
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          18.0),
                                                            )),
                                                            backgroundColor:
                                                                MaterialStateProperty.all<
                                                                        Color>(
                                                                    AppColors
                                                                        .mainColor),
                                                          ),
                                                        ),
                                                      )
                                                    ])));
                                      }),
                                ),
                              )
                            : const SizedBox(),
                        Container(
                          margin: const EdgeInsets.only(bottom: 30),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Colors.grey.shade100),
                          height: 187,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                deliveryType?.value == DeliveryTypeEnum.deliver
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('${tr('shippingAmount')} : ',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 20,
                                              )),
                                          Text(
                                              formatCurrency.format(
                                                  (deliveryPrice.value)),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 20,
                                              ))
                                        ],
                                      )
                                    : const SizedBox(),
                                // Row(
                                //     mainAxisAlignment:
                                //         MainAxisAlignment.spaceBetween,
                                //     children: [
                                //       Text(
                                //         tr("deliveryOrPickup.delivery") + ':',
                                //         style: TextStyle(
                                //             fontSize: 20,
                                //             color: Colors.grey.shade400),
                                //       ),
                                //       Text(
                                //         '12 000',
                                //         style: TextStyle(
                                //             fontSize: 20,
                                //             color: Colors.grey.shade400),
                                //       )
                                //     ]),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${basketData.value?.lines?.length} ${tr("goods-amount")}:',
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                      Text(
                                        productsTotalPrice,
                                        style: const TextStyle(fontSize: 18),
                                      )
                                    ]),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        tr("basket.willReturn") +
                                            ' 5% ' +
                                            tr("basket.fromOrder") +
                                            ':',
                                        style: const TextStyle(
                                            fontSize: 18,
                                            color: AppColors.plum),
                                      ),
                                      const Spacer(),
                                      Image.asset(
                                        'images/coin.png',
                                        height: 16,
                                        width: 16,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        cashback,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            color: AppColors.plum),
                                      )
                                    ]),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${tr("total")}:',
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                      Text(
                                        totalPrice,
                                        style: const TextStyle(fontSize: 24),
                                      )
                                    ]),
                              ]),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ChooseDeliveryTime(),
                        const SizedBox(
                          height: 20,
                        ),
                        ChoosePayType(),
                        const SizedBox(
                          height: 10,
                        ),
                        AdditionalPhoneNumberWidget(),
                        // const SizedBox(
                        //   height: 5,
                        // ),
                        const OrderCommentWidget(),
                        const SizedBox(
                          height: 50,
                        )
                      ],
                    );
                  }, childCount: 1),
                ),
              ],
            ),
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.white,
                  child: n.NikuButton.elevated(_isOrderLoading.value == true
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          tr(
                            'basket.order',
                          ),
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                        ))
                    ..bg = AppColors.mainColor
                    ..color = Colors.white
                    ..mx = 16
                    ..mt = 10
                    ..mb = 28
                    ..py = 15
                    ..rounded = 20
                    ..onPressed = () async {
                      _isOrderLoading.value = true;
                      final hashids = HashIds(
                        salt: 'order',
                        minHashLength: 15,
                        alphabet: 'abcdefghijklmnopqrstuvwxyz1234567890',
                      );
                      Box<DeliveryType> box =
                          Hive.box<DeliveryType>('deliveryType');
                      DeliveryType? deliveryType = box.get('deliveryType');
                      DeliveryLocationData? deliveryLocationData =
                          Hive.box<DeliveryLocationData>('deliveryLocationData')
                              .get('deliveryLocationData');
                      Terminals? currentTerminal =
                          Hive.box<Terminals>('currentTerminal')
                              .get('currentTerminal');
                      DeliverLaterTime? deliverLaterTime =
                          Hive.box<DeliverLaterTime>('deliveryLaterTime')
                              .get('deliveryLaterTime');
                      DeliveryTime? deliveryTime =
                          Hive.box<DeliveryTime>('deliveryTime')
                              .get('deliveryTime');
                      PayType? payType =
                          Hive.box<PayType>('payType').get('payType');
                      PayCash? payCash =
                          Hive.box<PayCash>('payCash').get('payCash');
                      DeliveryNotes? deliveryNotes =
                          Hive.box<DeliveryNotes>('deliveryNotes')
                              .get('deliveryNotes');
                      AdditionalPhoneNumber? additionalPhoneNumber =
                          Hive.box<AdditionalPhoneNumber>(
                                  'additionalPhoneNumber')
                              .get('additionalPhoneNumber');
                      // Check deliveryType is chosen
                      if (deliveryType == null) {
                        _isOrderLoading.value = false;
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Не выбран способ доставки')));
                        return;
                      }

                      //Check pickup terminal
                      if (deliveryType.value == DeliveryTypeEnum.pickup) {
                        if (currentTerminal == null) {
                          _isOrderLoading.value = false;
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Не выбран филиал самовывоза')));
                          return;
                        }
                      }

                      // Check delivery address
                      if (deliveryType.value == DeliveryTypeEnum.deliver) {
                        if (deliveryLocationData == null) {
                          _isOrderLoading.value = false;
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Не указан адрес доставки')));
                          return;
                        } else if (deliveryLocationData.address == null) {
                          _isOrderLoading.value = false;
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Не указан адрес доставки')));
                          return;
                        }
                      }

                      // Check delivery time selected

                      if (deliveryTime == null) {
                        _isOrderLoading.value = false;
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Не указано время доставки')));
                        return;
                      } else if (deliveryTime.value == DeliveryTimeEnum.later) {
                        if (deliverLaterTime == null) {
                          _isOrderLoading.value = false;
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Не указано время доставки')));
                          return;
                        } else if (deliverLaterTime.value.length == 0) {
                          _isOrderLoading.value = false;
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Не указано время доставки')));
                          return;
                        }
                      }

                      if (payType == null) {
                        _isOrderLoading.value = false;
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Не указан способ оплаты')));
                        return;
                      }

                      Basket? basket = Hive.box<Basket>('basket').get('basket');
                      Box userBox = Hive.box<User>('user');
                      User? user = userBox.get('user');

                      Map<String, String> requestHeaders = {
                        'Content-type': 'application/json',
                        'Accept': 'application/json'
                      };

                      if (user != null) {
                        requestHeaders['Authorization'] =
                            'Bearer ${user.userToken}';
                      }

                      var url = Uri.https('api.lesailes.uz', '/api/orders');
                      Map<String, dynamic> formData = {
                        'basket_id': basket!.encodedId,
                        'formData': <String, dynamic>{
                          'address': '',
                          'flat': '',
                          'house': '',
                          'entrance': '',
                          'door_code': '',
                          'deliveryType': '',
                          'sourceType': "app"
                        }
                      };
                      if (deliveryType.value == DeliveryTypeEnum.deliver) {
                        formData['formData']['address'] =
                            deliveryLocationData!.address;
                        formData['formData']['flat'] =
                            deliveryLocationData.flat ?? '';
                        formData['formData']['house'] =
                            deliveryLocationData.house ?? '';
                        formData['formData']['entrance'] =
                            deliveryLocationData.entrance ?? '';
                        formData['formData']['door_code'] =
                            deliveryLocationData.doorCode ?? '';
                        formData['formData']['deliveryType'] = 'deliver';
                        formData['formData']['location'] = [
                          deliveryLocationData.lat,
                          deliveryLocationData.lon
                        ];
                      } else {
                        formData['formData']['deliveryType'] = 'pickup';
                      }

                      formData['formData']['terminal_id'] =
                          currentTerminal!.id.toString();
                      formData['formData']['name'] = user!.name;
                      formData['formData']['phone'] = user!.phone;
                      formData['formData']['email'] = '';
                      formData['formData']['change'] = '';
                      formData['formData']['notes'] = '';
                      formData['formData']['delivery_day'] = '';
                      formData['formData']['delivery_time'] = '';
                      formData['formData']['delivery_schedule'] = 'now';
                      formData['formData']['sms_sub'] = false;
                      formData['formData']['email_sub'] = false;
                      formData['formData']['additionalPhone'] =
                          additionalPhoneNumber?.additionalPhoneNumber ?? '';
                      if (deliveryTime.value == DeliveryTimeEnum.later) {
                        formData['formData']['delivery_schedule'] = 'later';
                        formData['formData']['delivery_time'] =
                            deliveryTime.value;
                      }

                      if (payCash != null) {
                        formData['formData']['change'] = payCash.value;
                      }

                      if (deliveryNotes != null) {
                        formData['formData']['notes'] =
                            deliveryNotes!.deliveryNotes;
                      }

                      if (payType != null) {
                        formData['formData']['pay_type'] = payType.value;
                      } else {
                        formData['formData']['pay_type'] = 'offline';
                      }

                      var response = await http.post(url,
                          headers: requestHeaders, body: jsonEncode(formData));
                      if (response.statusCode == 200 ||
                          response.statusCode == 201) {
                        var json = jsonDecode(response.body);

                        Map<String, String> requestHeaders = {
                          'Content-type': 'application/json',
                          'Accept': 'application/json'
                        };

                        requestHeaders['Authorization'] =
                            'Bearer ${user.userToken}';

                        url = Uri.https('api.lesailes.uz', '/api/orders',
                            {'id': json['order']['id']});

                        response = await http.get(url, headers: requestHeaders);
                        if (response.statusCode == 200 ||
                            response.statusCode == 201) {
                          json = jsonDecode(response.body);
                          Order order = Order.fromJson(json);
                          await Hive.box<Basket>('basket').delete('basket');
                          await Hive.box<DeliveryType>('deliveryType')
                              .delete('deliveryType');
                          await Hive.box<DeliveryLocationData>(
                                  'deliveryLocationData')
                              .delete('deliveryLocationData');
                          await Hive.box<Terminals>('currentTerminal')
                              .delete('currentTerminal');
                          await Hive.box<DeliverLaterTime>('deliveryLaterTime')
                              .delete('deliveryLaterTime');
                          await Hive.box<DeliveryTime>('deliveryTime')
                              .delete('deliveryTime');
                          await Hive.box<PayType>('payType').delete('payType');
                          await Hive.box<PayCash>('payCash').delete('payCash');
                          await Hive.box<DeliveryNotes>('deliveryNotes')
                              .delete('deliveryNotes');

                                  Box<BasketItemQuantity>
                                      basketItemQuantityBox =
                                      Hive.box<BasketItemQuantity>(
                                          'basketItemQuantity');
                                  await basketItemQuantityBox.clear();
                          Navigator.of(context).pop();
                          showBarModalBottomSheet(
                              expand: false,
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) => OrderSuccess(order: order));

                          // showPlatformDialog(
                          //     context: context,
                          //     builder: (_) => PlatformAlertDialog(
                          //           title: Text(
                          //             tr("order_is_accepted"),
                          //             textAlign: TextAlign.center,
                          //           ),
                          //           content: Text(
                          //             tr("order_is_accepted_content"),
                          //             textAlign: TextAlign.center,
                          //           ),
                          //         ));
                          _isOrderLoading.value = false;
                          // Future.delayed(
                          //     const Duration(
                          //         milliseconds: 2000), () {
                          //   Navigator.pushReplacement(
                          //     context,
                          //     MaterialPageRoute(
                          //       builder: (context) =>
                          //           OrderDetail(
                          //               orderId: hashids
                          //                   .encode(order.id)),
                          //     ),
                          //   );
                          // });
                        }
                        // BasketData basketData = new BasketData.fromJson(json['data']);
                        // Basket newBasket = new Basket(
                        //     encodedId: basketData.encodedId ?? '',
                        //     lineCount: basketData.lines?.length ?? 0);
                        // basketBox.put('basket', newBasket);
                      } else {
                        var errResponse = jsonDecode(response.body);
                        _isOrderLoading.value = false;
                        // print(response.body);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(errResponse['error']['message'])));
                        return;
                      }
                    },
                ))
          ],
        ),
      ),
      // bottomNavigationBar: BottomAppBar(
      //     child: ),
    ));
  }
}
