import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hashids2/hashids2.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'package:niku/niku.dart' as n;

import '../models/basket.dart';
import '../models/basket_data.dart';
import '../models/basket_item_quantity.dart';
import '../models/delivery_location_data.dart';
import '../models/delivery_type.dart';
import '../models/productSection.dart';
import '../models/stock.dart';
import '../models/terminals.dart';
import '../models/user.dart';
import '../utils/colors.dart';

class ProductCard extends HookWidget {
  final Items? product;

  const ProductCard(this.product, {Key? key}) : super(key: key);

  Widget productImage(String? image) {
    if (image != null) {
      return CachedNetworkImage(
        imageUrl: image,
        progressIndicatorBuilder: (context, url, downloadProgress) =>
            CircularProgressIndicator(
                value: downloadProgress.progress, color: AppColors.mainColor),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      );
      // return Image.network(
      //   image,
      //   width: 164.0,
      //   height: 164.0,
      //   // width: MediaQuery.of(context).size.width / 2.5,
      // );
    } else {
      return ClipOval(
        child: SvgPicture.network(
          'https://lesailes.uz/no_photo.svg',
          width: 175.0,
          height: 175.0,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String? image = product!.image;
    final formatCurrency =
        NumberFormat.currency(locale: 'ru_RU', symbol: 'сум', decimalDigits: 0);
    String productPrice = '';

    productPrice = product!.price;

    productPrice = formatCurrency.format(double.tryParse(productPrice));
    final _isBasketLoading = useState<bool>(false);

    Box<BasketItemQuantity> basketItemQuantityBox =
        Hive.box<BasketItemQuantity>('basketItemQuantity');
    BasketItemQuantity? basketItemQuantity =
        basketItemQuantityBox.get(product!.id);

    final hashids = HashIds(
      salt: 'basket',
      minHashLength: 15,
      alphabet: 'abcdefghijklmnopqrstuvwxyz1234567890',
    );

    int? lineId;

    if (basketItemQuantity != null) {
      lineId = basketItemQuantity.lineId;
    }

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
        Box<Basket> basketBox = Hive.box<Basket>('basket');
        Basket? basket = basketBox.get('basket');

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
          basket.totalPrice = newBasket.total;
          basketItemQuantityBox.delete(product!.id);
          basketBox.put('basket', basket);
        }
      }
    }

    Future<void> decreaseQuantity(int lineId) async {
      if (basketItemQuantity!.quantity == 1) {
        destroyLine(lineId);
        return;
      }

      Box<Basket> basketBox = Hive.box<Basket>('basket');
      Basket? basket = basketBox.get('basket');
      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json'
      };
      BasketItemQuantity newBasketItemQuantity = BasketItemQuantity();
      newBasketItemQuantity.lineId = lineId;
      newBasketItemQuantity.quantity = basketItemQuantity!.quantity - 1;
      await basketItemQuantityBox.put(product!.id, newBasketItemQuantity);
      var url = Uri.https(
          'api.lesailes.uz',
          '/api/v1/basket-lines/${hashids.encode(lineId.toString())}/remove',
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
          BasketData basketData = BasketData.fromJson(json['data']);
          Basket newBasket = Basket(
              encodedId: basket.encodedId ?? '',
              lineCount: basketData!.lines?.length ?? 0,
              totalPrice: basketData!.total);
          basketBox.put('basket', newBasket);
        }
      }
    }

    Future<void> increaseQuantity(int lineId) async {
      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json'
      };

      Box<Basket> basketBox = Hive.box<Basket>('basket');
      Basket? basket = basketBox.get('basket');
      BasketItemQuantity newBasketItemQuantity = BasketItemQuantity();
      newBasketItemQuantity.lineId = lineId;
      newBasketItemQuantity.quantity = basketItemQuantity!.quantity + 1;
      await basketItemQuantityBox.put(product!.id, newBasketItemQuantity);
      var url = Uri.https(
          'api.lesailes.uz',
          '/api/v1/basket-lines/${hashids.encode(lineId.toString())}/add',
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
          BasketData basketData = BasketData.fromJson(json['data']);
          Basket newBasket = Basket(
              encodedId: basket.encodedId ?? '',
              lineCount: basketData!.lines?.length ?? 0,
              totalPrice: basketData!.total);
          basketBox.put('basket', newBasket);
        }
      }
    }

    Future<void> addToBasket() async {
      ModifierProduct? modifierProduct;
      List<Map<String, int>>? selectedModifiers;
      _isBasketLoading.value = true;

      int selectedProdId = product!.id;

      Box userBox = Hive.box<User>('user');
      User? user = userBox.get('user');
      Box basketBox = Hive.box<Basket>('basket');
      Basket? basket = basketBox.get('basket');

      if (basket != null &&
          basket.encodedId.isNotEmpty &&
          basket.encodedId.length > 0) {
        Map<String, String> requestHeaders = {
          'Content-type': 'application/json',
          'Accept': 'application/json'
        };

        if (user != null) {
          requestHeaders['Authorization'] = 'Bearer ${user.userToken}';
        }

        var url = Uri.https('api.lesailes.uz', '/api/baskets-lines');
        var formData = {
          'basket_id': basket.encodedId,
          'variants': [
            {
              'id': selectedProdId,
              'quantity': 1,
              'modifiers': selectedModifiers
            }
          ]
        };
        var response = await http.post(url,
            headers: requestHeaders, body: jsonEncode(formData));
        if (response.statusCode == 200 || response.statusCode == 201) {
          var json = jsonDecode(response.body);
          BasketData basketLocalData = BasketData.fromJson(json['data']);
          int lineId;
          Basket newBasket = Basket(
              encodedId: basketLocalData.encodedId ?? '',
              lineCount: basketLocalData.lines?.length ?? 0,
              totalPrice: basketLocalData.total);
          basketBox.put('basket', newBasket);
          Lines line = basketLocalData.lines!.firstWhere(
              (element) => element.variant!.productId == product!.id);
          BasketItemQuantity newBasketItemQuantity = BasketItemQuantity();
          newBasketItemQuantity.lineId = line.id;
          newBasketItemQuantity.quantity = 1;
          await basketItemQuantityBox.put(product!.id, newBasketItemQuantity);
        }
      } else {
        Map<String, String> requestHeaders = {
          'Content-type': 'application/json',
          'Accept': 'application/json'
        };

        if (user != null) {
          requestHeaders['Authorization'] = 'Bearer ${user.userToken}';
        }

        var url = Uri.https('api.lesailes.uz', '/api/baskets');
        var formData = {
          'variants': [
            {
              'id': selectedProdId,
              'quantity': 1,
              'modifiers': selectedModifiers
            }
          ]
        };
        var response = await http.post(url,
            headers: requestHeaders, body: jsonEncode(formData));
        if (response.statusCode == 200 || response.statusCode == 201) {
          var json = jsonDecode(response.body);
          BasketData basketLocalData = BasketData.fromJson(json['data']);
          Basket newBasket = Basket(
              encodedId: basketLocalData.encodedId ?? '',
              lineCount: basketLocalData.lines?.length ?? 0,
              totalPrice: basketLocalData.total);
          basketBox.put('basket', newBasket);
          Lines line = basketLocalData.lines!.firstWhere(
              (element) => element.variant!.productId == product!.id);
          BasketItemQuantity newBasketItemQuantity = BasketItemQuantity();
          newBasketItemQuantity.lineId = line.id;
          newBasketItemQuantity.quantity = 1;
          await basketItemQuantityBox.put(product!.id, newBasketItemQuantity);
        }
      }
      _isBasketLoading.value = false;

      return;
    }

    var locale = context.locale.toString();
    var attributeDataName = '';
    switch (locale) {
      // case 'en':
      //   attributeDataName  = products.value[index].attributeData?.name?.chopar?.en ?? '';
      //   break;
      case 'uz':
        attributeDataName = product!.attributeData?.name?.chopar?.uz ?? '';
        break;
      default:
        attributeDataName = product!.attributeData?.name?.chopar?.ru ?? '';
        break;
    }

    Widget renderProduct(BuildContext context) {
      Box<Stock> stockBox = Hive.box<Stock>('stock');
      Stock? stock = stockBox.get('stock');

      bool isInStock = false;

      if (stock != null) {
        if (stock.prodIds.isNotEmpty) {
          if (stock.prodIds.contains(product!.id)) {
            isInStock = true;
          }
        }
      }

      return Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(0.0, 0.0), //(x,y)
                blurRadius: 1.0,
              ),
            ],
          ),
          child: Opacity(
            opacity: isInStock ? 0.3 : 1,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  productImage(image),
                  const Spacer(
                    flex: 1,
                  ),
                  Text(
                    attributeDataName,
                    style: const TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(
                    flex: 1,
                  ),
                  lineId != null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                                height: 50,
                                width: 50,
                                child: n.NikuButton.elevated(const Icon(
                                  Icons.remove,
                                  color: Colors.white,
                                  size: 40,
                                ))
                                  ..bg = AppColors.mainColor
                                  ..rounded = 20
                                  ..p = 0
                                  ..onPressed = () {
                                    decreaseQuantity(lineId!);
                                  }),
                            n.NikuText(basketItemQuantity!.quantity.toString())
                              ..style = n.NikuTextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            SizedBox(
                                height: 50,
                                width: 50,
                                child: n.NikuButton.elevated(const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 40,
                                ))
                                  ..bg = AppColors.mainColor
                                  ..rounded = 20
                                  ..p = 0
                                  ..onPressed = () {
                                    increaseQuantity(lineId!);
                                  }),
                          ],
                        )
                      : SizedBox(
                          height: 50,
                          width: 144,
                          child: ElevatedButton(
                            onPressed: () {
                              Box<DeliveryType> box =
                                  Hive.box<DeliveryType>('deliveryType');
                              DeliveryType? deliveryType =
                                  box.get('deliveryType');
                              Terminals? currentTerminal =
                                  Hive.box<Terminals>('currentTerminal')
                                      .get('currentTerminal');
                              DeliveryLocationData? deliveryLocationData =
                                  Hive.box<DeliveryLocationData>(
                                          'deliveryLocationData')
                                      .get('deliveryLocationData');

                              //Check pickup terminal
                              if (deliveryType != null &&
                                  deliveryType.value ==
                                      DeliveryTypeEnum.pickup) {
                                if (currentTerminal == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Не выбран филиал самовывоза')));
                                  return;
                                }
                              }

                              // Check delivery address
                              if (deliveryType != null &&
                                  deliveryType.value ==
                                      DeliveryTypeEnum.deliver) {
                                if (deliveryLocationData == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Не указан адрес доставки')));
                                  return;
                                } else if (deliveryLocationData.address ==
                                    null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Не указан адрес доставки')));
                                  return;
                                }
                              }

                              if (isInStock) {
                                return;
                              }

                              addToBasket();
                            },
                            child: _isBasketLoading.value
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(productPrice),
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              )),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  AppColors.mainColor),
                            ),
                          ),
                        )
                ]),
          ));
    }

    return ValueListenableBuilder<Box<Stock>>(
        valueListenable: Hive.box<Stock>('stock').listenable(),
        builder: (context, box, _) {
          return renderProduct(context);
        });
  }
}
