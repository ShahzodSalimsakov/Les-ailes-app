import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hashids2/hashids2.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:les_ailes/models/payment_card_model.dart';
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
import '../models/terminals.dart';
import '../models/user.dart';
import '../utils/simplified_url.dart';
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
    final relatedBiData =
        useState<List<RelatedProduct>>(List<RelatedProduct>.empty());
    final topProducts =
        useState<List<RelatedProduct>>(List<RelatedProduct>.empty());
    final hashids = HashIds(
      salt: 'basket',
      minHashLength: 15,
      alphabet: 'abcdefghijklmnopqrstuvwxyz1234567890',
    );
    final _isBasketLoading = useState<bool>(false);
    final deliveryPrice = useState(0);
    final isMounted = useRef(true);
    Box<DeliveryType> box = Hive.box<DeliveryType>('deliveryType');
    DeliveryType? deliveryType = box.get('deliveryType');
    final loadingItems = useState<Set<int>>({});

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
                borderRadius: BorderRadius.circular(26), color: Colors.white),
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
              borderRadius: BorderRadius.circular(26), color: Colors.white),
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
      context.locale.toString();
      String? productName = '';
      if (lines.child != null && lines.child!.length > 1) {
        productName = lines.variant!.product!.attributeData!.name!.chopar!.ru;
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
      }
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            renderProductImage(context, lines),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    productName ?? '',
                    style: const TextStyle(fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${NumberFormat.currency(
                            symbol: '',
                            decimalDigits: 0,
                          ).format(lines.variant?.price ?? 0)} ${tr('sum')}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () => decreaseQuantity(lines),
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(),
                            ),
                            Text(
                              '${lines.quantity}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => increaseQuantity(lines),
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    String totalPrice = useMemoized(() {
      var locale = context.locale.toString();
      String result = '0';
      if (basketData.value != null) {
        if (deliveryPrice.value > 0) {
          result = (basketData.value!.total + deliveryPrice.value).toString();
        } else {
          result = basketData.value!.total.toString();
        }
      }

      final formatCurrency = NumberFormat.currency(
          locale: 'ru_RU',
          symbol: locale == 'uz'
              ? "so'm"
              : locale == 'en'
                  ? 'sum'
                  : 'сум',
          decimalDigits: 0);

      result = formatCurrency.format(double.tryParse(result));
      return result;
    }, [basketData.value, deliveryPrice.value]);

    Future<void> fetchBiRecomendedItems(BasketData basketData) async {
      if (basket != null && isMounted.value) {
        List<String> productIds = [];

        if (basketData?.lines != null) {
          if (basketData!.lines!.length > 0) {
            for (var line in basketData!.lines!) {
              productIds.add(line.variant!.productId.toString());
            }
          }
        }

        Map<String, String> requestHeaders = {
          'Content-type': 'application/json',
          'Accept': 'application/json'
        };

        var url = SimplifiedUri.uri(
            'https://api.lesailes.uz/api/baskets/bi_related/',
            {"productIds": productIds});
        var response = await http.get(url, headers: requestHeaders);
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (!isMounted.value) return;
          var json = jsonDecode(response.body);
          if (json['data'] != null) {
            List<RelatedProduct> localBiRelatedProduct =
                List<RelatedProduct>.from(json['data']['relatedItems']
                    .map((m) => RelatedProduct.fromJson(m))
                    .toList());
            relatedBiData.value = localBiRelatedProduct;
            List<RelatedProduct> topProduct = List<RelatedProduct>.from(
                json['data']['topItems']
                    .map((m) => RelatedProduct.fromJson(m))
                    .toList());
            topProducts.value = topProduct;
          }
        }
      }
    }

    Future<void> getBasket() async {
      if (basket != null && isMounted.value) {
        Map<String, String> requestHeaders = {
          'Content-type': 'application/json',
          'Accept': 'application/json'
        };

        var url =
            Uri.https('api.lesailes.uz', '/api/baskets/${basket.encodedId}');
        var response = await http.get(url, headers: requestHeaders);
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (!isMounted.value) return;
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
                if (!isMounted.value) return;
                var json = jsonDecode(deliveryPriceResponse.body);
                deliveryPrice.value = json['totalPrice'];
              }
            } else {
              deliveryPrice.value = 0;
            }
          }
          basketData.value = basketLocalData;
          fetchBiRecomendedItems(basketLocalData);
          _isBasketLoading.value = false;
        }
      }
    }

    Future<void> fetchRecomendedItems() async {
      if (basket != null && isMounted.value) {
        Map<String, String> requestHeaders = {
          'Content-type': 'application/json',
          'Accept': 'application/json'
        };

        var url = Uri.https(
            'api.lesailes.uz', '/api/baskets/related/${basket.encodedId}');
        var response = await http.get(url, headers: requestHeaders);
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (!isMounted.value) return;
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

    String productsTotalPrice = useMemoized(() {
      var locale = context.locale.toString();
      String result = '0';
      if (basketData.value != null) {
        result = basketData.value!.total.toString();
      }

      final formatCurrency = NumberFormat.currency(
          locale: 'ru_RU',
          symbol: locale == 'uz'
              ? "so'm"
              : locale == 'en'
                  ? 'sum'
                  : 'сум',
          decimalDigits: 0);

      result = formatCurrency.format(double.tryParse(result));
      return result;
    }, [basketData.value]);

    useEffect(() {
      isMounted.value = true;
      getBasket();
      fetchRecomendedItems();
      return () {
        isMounted.value = false;
      };
    }, [deliveryType]);

    return Material(
        child: Scaffold(
      backgroundColor: Colors.white,
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
                  centerTitle: true,
                  surfaceTintColor: Colors.white,
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
                    child: Center(
                        child: Image.asset(
                      'images/delete.png',
                      width: 25,
                      height: 25,
                    )),
                  ),

                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    centerTitle: true,
                    collapseMode: CollapseMode.parallax,
                    title: Text(
                      tr("basket.basket"),
                      textAlign: TextAlign.center,
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
                    var locale = context.locale.toString();
                    Box<DeliveryLocationData> deliveryLocationBox =
                        Hive.box<DeliveryLocationData>('deliveryLocationData');
                    DeliveryLocationData? deliveryLocationData =
                        deliveryLocationBox.get('deliveryLocationData');
                    String deliveryText = tr("main.deliveryOrPickup");
                    Box<Terminals> terminalBox =
                        Hive.box<Terminals>('currentTerminal');
                    Terminals? currentTerminal =
                        terminalBox.get('currentTerminal');
                    if (deliveryLocationData != null) {
                      if (deliveryType!.value == DeliveryTypeEnum.deliver) {
                        deliveryText = deliveryLocationData.address ?? '';
                        String house = deliveryLocationData.house != null &&
                                deliveryLocationData.house!.isNotEmpty
                            ? ', ${tr("house")}: ${deliveryLocationData.house}'
                            : '';
                        String flat = deliveryLocationData.flat != null &&
                                deliveryLocationData.flat!.isNotEmpty
                            ? ', ${tr("flat")}: ${deliveryLocationData.flat}'
                            : '';
                        String entrance = deliveryLocationData.entrance !=
                                    null &&
                                deliveryLocationData.entrance!.isNotEmpty
                            ? ', ${tr("entrance")}: ${deliveryLocationData.entrance}'
                            : '';
                        deliveryText = '$deliveryText$house$flat$entrance';
                      }
                    }
                    final formatCurrency = NumberFormat.currency(
                        locale: 'ru_RU',
                        symbol: locale == 'uz'
                            ? "so'm"
                            : locale == 'en'
                                ? 'sum'
                                : 'сум',
                        decimalDigits: 0);
                    return Column(
                      children: [
                        const SizedBox(height: 20),
                        deliveryType != null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      deliveryType!.value ==
                                              DeliveryTypeEnum.deliver
                                          ? Image.asset(
                                              'images/delivery_car.png',
                                              width: 30,
                                              height: 35,
                                            )
                                          : Image.asset(
                                              'images/delivery_pickup.png',
                                              width: 30,
                                              height: 35,
                                            ),
                                      const SizedBox(width: 10),
                                      Text(
                                        tr(deliveryType.value.toString()),
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  deliveryType.value == DeliveryTypeEnum.deliver
                                      ? SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.7,
                                          child: n.NikuText(
                                            deliveryText,
                                            style: n.NikuTextStyle(
                                                color: Colors.grey),
                                          ))
                                      : n.NikuText(
                                          currentTerminal!.name,
                                          style: n.NikuTextStyle(
                                              color: Colors.black,
                                              fontSize: 20),
                                        )
                                ],
                              )
                            : const WayToReceiveAnOrder(),
                        const SizedBox(height: 20),
                        const Divider(
                          thickness: 0.5,
                        ),
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
                                  return const Divider(
                                    thickness: 0.5,
                                  );
                                },
                                itemBuilder: (context, index) {
                                  final item = basketData.value!.lines![index];
                                  return item.bonusId != null
                                      ? basketItems(item)
                                      : Dismissible(
                                          direction:
                                              DismissDirection.endToStart,
                                          key: Key(item.id.toString()),
                                          background: Container(
                                            color: Colors.red,
                                          ),
                                          onDismissed:
                                              (DismissDirection direction) {
                                            destroyLine(item.id);
                                          },
                                          secondaryBackground: Container(
                                            color: Colors.red,
                                            child: const Padding(
                                              padding: EdgeInsets.all(15),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Icon(Icons.delete,
                                                      color: Colors.white),
                                                  Text('Удалить',
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                ],
                                              ),
                                            ),
                                          ),
                                          child: basketItems(item),
                                        );
                                }),
                        relatedBiData.value.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(
                                  top: 10,
                                  bottom: 10,
                                ),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(tr('buyWithTheseProducts'),
                                        style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w500))),
                              )
                            : const SizedBox(),
                        relatedBiData.value.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(bottom: 30),
                                child: SizedBox(
                                  height: 280,
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: relatedBiData.value.length,
                                      itemBuilder: (context, index) {
                                        final formatCurrency =
                                            NumberFormat.currency(
                                                locale: 'ru_RU',
                                                symbol: locale == 'uz'
                                                    ? "so'm"
                                                    : locale == 'en'
                                                        ? 'sum'
                                                        : 'сум',
                                                decimalDigits: 0);
                                        String productPrice = '';

                                        productPrice =
                                            relatedBiData.value[index].price;

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
                                                        relatedBiData
                                                            .value[index].image,
                                                        height: 140,
                                                        width: 140,
                                                      ),
                                                      const Spacer(
                                                        flex: 1,
                                                      ),
                                                      Text(
                                                        relatedBiData
                                                            .value[index]
                                                            .customName,
                                                        style: const TextStyle(
                                                            fontSize: 16),
                                                        textAlign:
                                                            TextAlign.center,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 3,
                                                      ),
                                                      const Spacer(
                                                        flex: 1,
                                                      ),
                                                      SizedBox(
                                                        height: 50,
                                                        width: 144,
                                                        child: ElevatedButton(
                                                          onPressed: () async {
                                                            if (loadingItems
                                                                .value
                                                                .contains(
                                                                    relatedBiData
                                                                        .value[
                                                                            index]
                                                                        .id)) {
                                                              return; // Prevent multiple clicks while loading
                                                            }
                                                            // Add item to loading set
                                                            loadingItems.value =
                                                                {
                                                              ...loadingItems
                                                                  .value,
                                                              relatedBiData
                                                                  .value[index]
                                                                  .id
                                                            };
                                                            List<
                                                                    Map<String,
                                                                        int>>?
                                                                selectedModifiers;
                                                            int selectedProdId =
                                                                relatedBiData
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
                                                                // Remove item from relatedBiData list
                                                                relatedBiData
                                                                    .value = List<
                                                                        RelatedProduct>.from(
                                                                    relatedBiData
                                                                        .value
                                                                        .where((item) =>
                                                                            item.id !=
                                                                            selectedProdId));
                                                              }
                                                              // Remove item from loading set
                                                              loadingItems
                                                                  .value = {
                                                                ...loadingItems
                                                                    .value
                                                              }..remove(
                                                                  selectedProdId);
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
                                                              padding:
                                                                  const MaterialStatePropertyAll(
                                                                      EdgeInsets
                                                                          .all(
                                                                              0))),
                                                          child: loadingItems
                                                                  .value
                                                                  .contains(relatedBiData
                                                                      .value[
                                                                          index]
                                                                      .id)
                                                              ? const SizedBox(
                                                                  width: 20,
                                                                  height: 20,
                                                                  child:
                                                                      CircularProgressIndicator(
                                                                    color: Colors
                                                                        .white,
                                                                    strokeWidth:
                                                                        2,
                                                                  ),
                                                                )
                                                              : Text(
                                                                  productPrice,
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          16)),
                                                        ),
                                                      )
                                                    ])));
                                      }),
                                ),
                              )
                            : const SizedBox(),
                        topProducts.value.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(
                                  top: 10,
                                  bottom: 10,
                                ),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(tr('featuredProducts'),
                                        style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w500))),
                              )
                            : const SizedBox(),
                        topProducts.value.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(bottom: 30),
                                child: SizedBox(
                                  height: 280,
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: topProducts.value.length,
                                      itemBuilder: (context, index) {
                                        final formatCurrency =
                                            NumberFormat.currency(
                                                locale: 'ru_RU',
                                                symbol: locale == 'uz'
                                                    ? "so'm"
                                                    : locale == 'en'
                                                        ? 'sum'
                                                        : 'сум',
                                                decimalDigits: 0);
                                        String productPrice = '';

                                        productPrice =
                                            topProducts.value[index].price;

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
                                                        topProducts
                                                            .value[index].image,
                                                        height: 140,
                                                        width: 140,
                                                      ),
                                                      const Spacer(
                                                        flex: 1,
                                                      ),
                                                      Text(
                                                        topProducts.value[index]
                                                            .customName,
                                                        style: const TextStyle(
                                                            fontSize: 16),
                                                        textAlign:
                                                            TextAlign.center,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 3,
                                                      ),
                                                      const Spacer(
                                                        flex: 1,
                                                      ),
                                                      SizedBox(
                                                        height: 50,
                                                        width: 144,
                                                        child: ElevatedButton(
                                                          onPressed: () async {
                                                            if (loadingItems
                                                                .value
                                                                .contains(
                                                                    topProducts
                                                                        .value[
                                                                            index]
                                                                        .id)) {
                                                              return; // Prevent multiple clicks while loading
                                                            }
                                                            // Add item to loading set
                                                            loadingItems.value =
                                                                {
                                                              ...loadingItems
                                                                  .value,
                                                              topProducts
                                                                  .value[index]
                                                                  .id
                                                            };
                                                            List<
                                                                    Map<String,
                                                                        int>>?
                                                                selectedModifiers;
                                                            int selectedProdId =
                                                                topProducts
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
                                                                // Remove item from topProducts list
                                                                topProducts
                                                                    .value = List<
                                                                        RelatedProduct>.from(
                                                                    topProducts
                                                                        .value
                                                                        .where((item) =>
                                                                            item.id !=
                                                                            selectedProdId));
                                                              }
                                                              // Remove item from loading set
                                                              loadingItems
                                                                  .value = {
                                                                ...loadingItems
                                                                    .value
                                                              }..remove(
                                                                  selectedProdId);
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
                                                              padding:
                                                                  const MaterialStatePropertyAll(
                                                                      EdgeInsets
                                                                          .all(
                                                                              0))),
                                                          child: loadingItems
                                                                  .value
                                                                  .contains(topProducts
                                                                      .value[
                                                                          index]
                                                                      .id)
                                                              ? const SizedBox(
                                                                  width: 20,
                                                                  height: 20,
                                                                  child:
                                                                      CircularProgressIndicator(
                                                                    color: Colors
                                                                        .white,
                                                                    strokeWidth:
                                                                        2,
                                                                  ),
                                                                )
                                                              : Text(
                                                                  productPrice,
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          16)),
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
                          height: 150,
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

                      PaymentCardModel? paymentCardModel =
                          Hive.box<PaymentCardModel>('paymentCardModel')
                              .get('paymentCardModel');
                      // Check deliveryType is chosen
                      if (deliveryType == null) {
                        _isOrderLoading.value = false;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(tr('notSelectedDeliveryType'))));
                        return;
                      }

                      //Check pickup terminal
                      if (deliveryType.value == DeliveryTypeEnum.pickup) {
                        if (currentTerminal == null) {
                          _isOrderLoading.value = false;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(tr('notSelectedPickupTerminal'))));
                          return;
                        }
                      }

                      // Check delivery address
                      if (deliveryType.value == DeliveryTypeEnum.deliver) {
                        if (deliveryLocationData == null) {
                          _isOrderLoading.value = false;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(tr('notSelectedDeliveryAddress'))));
                          return;
                        } else if (deliveryLocationData.address == null) {
                          _isOrderLoading.value = false;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(tr('notSelectedDeliveryAddress'))));
                          return;
                        }
                      }

                      // Check delivery time selected

                      if (deliveryTime == null) {
                        _isOrderLoading.value = false;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(tr('notSelectedDeliveryTime'))));
                        return;
                      } else if (deliveryTime.value == DeliveryTimeEnum.later) {
                        if (deliverLaterTime == null) {
                          _isOrderLoading.value = false;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(tr('notSelectedDeliveryTime'))));
                          return;
                        } else if (deliverLaterTime.value.length == 0) {
                          _isOrderLoading.value = false;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(tr('notSelectedDeliveryTime'))));
                          return;
                        }
                      }

                      if (payType == null) {
                        _isOrderLoading.value = false;
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(tr('notSelectedPayType'))));
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

                      if (formData['formData']['pay_type'] == 'card' &&
                          paymentCardModel != null) {
                        formData['formData']['cardId'] = paymentCardModel.id;
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

                          Box<BasketItemQuantity> basketItemQuantityBox =
                              Hive.box<BasketItemQuantity>(
                                  'basketItemQuantity');
                          await basketItemQuantityBox.clear();
                          Navigator.of(context).pop();
                          showBarModalBottomSheet(
                              expand: false,
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) => OrderSuccess(order: order));

                          _isOrderLoading.value = false;
                        }
                      } else {
                        var errResponse = jsonDecode(response.body);
                        _isOrderLoading.value = false;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(errResponse['error']['message'])));
                        return;
                      }
                    },
                ))
          ],
        ),
      ),
    ));
  }
}
