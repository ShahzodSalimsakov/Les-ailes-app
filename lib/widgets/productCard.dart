import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hashids2/hashids2.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'package:les_ailes/widgets/productCardModal.dart';
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
        height: 100,
        width: 100,
        fit: BoxFit.cover,
        memCacheHeight: 200,
        memCacheWidth: 200,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(
            color: AppColors.mainColor,
            strokeWidth: 2,
          ),
        ),
        errorWidget: (context, url, error) => const Center(
          child: Icon(Icons.error_outline, color: Colors.red),
        ),
      );
    } else {
      return ClipOval(
        child: SvgPicture.network(
          'https://lesailes.uz/no_photo.svg',
          width: 175.0,
          height: 175.0,
          placeholderBuilder: (BuildContext context) => const Center(
            child: CircularProgressIndicator(
              color: AppColors.mainColor,
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var locale = context.locale.toString();
    String? image = product!.image;
    final formatCurrency = NumberFormat.currency(
        locale: 'ru_RU',
        symbol: locale == 'uz'
            ? "so'm"
            : locale == 'en'
                ? 'sum'
                : "сум",
        decimalDigits: 0);
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
      List<Map<String, int>>? selectedModifiers;
      _isBasketLoading.value = true;

      int selectedProdId = product!.id;

      Box userBox = Hive.box<User>('user');
      User? user = userBox.get('user');
      Box basketBox = Hive.box<Basket>('basket');
      Basket? basket = basketBox.get('basket');

      if (basket != null &&
          basket.encodedId.isNotEmpty &&
          basket.encodedId.isNotEmpty) {
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

    var attributeDataName = '';
    var attributeDataDesc = '';
    switch (locale) {
      case 'uz':
        attributeDataName = product!.attributeData?.name?.chopar?.uz ?? '';
        attributeDataDesc =
            product!.attributeData?.description?.chopar?.uz ?? '';
        break;
      case 'ru':
        attributeDataName = product!.attributeData?.name?.chopar?.ru ?? '';
        attributeDataDesc =
            product!.attributeData?.description?.chopar?.ru ?? '';
        break;
      case 'en':
        attributeDataName = product!.attributeData?.name?.chopar?.en ?? '';
        attributeDataDesc =
            product!.attributeData?.description?.chopar?.en ?? '';
        break;
      default:
        attributeDataName = product!.attributeData?.name?.chopar?.ru ?? '';
        attributeDataDesc =
            product!.attributeData?.description?.chopar?.ru ?? '';
        break;
    }

    Widget _buildHandle(BuildContext context) {
      final theme = Theme.of(context);

      return FractionallySizedBox(
        widthFactor: 0.25,
        child: Container(
          margin: const EdgeInsets.symmetric(
            vertical: 1.0,
          ),
          child: Container(
            height: 5.0,
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: const BorderRadius.all(Radius.circular(2.5)),
            ),
          ),
        ),
      );
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
                blurRadius: 0.1,
              ),
            ],
          ),
          child: Opacity(
            opacity: isInStock ? 0.3 : 1,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(40.0),
                                topRight: Radius.circular(40.0),
                              ),
                            ),
                            isScrollControlled: true,
                            context: context,
                            builder: (BuildContext builder) {
                              return ProductCardModal(product: product);
                            });
                      },
                      child: SizedBox(
                        height: 130,
                        child: Column(
                          children: [
                            productImage(image),
                            // const Spacer(
                            //   flex: 1,
                            // ),
                            Text(
                              attributeDataName,
                              style: const TextStyle(
                                  fontSize: 20,
                                  overflow: TextOverflow.ellipsis),
                              textAlign: TextAlign.center,
                            ),
                            // SizedBox(
                            //   height: 60,
                            //   child: Html(
                            //     data: attributeDataDesc,
                            //     style: {
                            //       'p': Style(
                            //           maxLines: 2,
                            //           textAlign: TextAlign.center,
                            //           textOverflow: TextOverflow.ellipsis,
                            //           alignment: Alignment.center),
                            //     },
                            //   ),
                            // ),
                          ],
                        ),
                      )),
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
                                      SnackBar(
                                          content: Text(tr("p_b_n_selected"))));
                                  return;
                                }
                              }

                              // Check delivery address
                              if (deliveryType != null &&
                                  deliveryType.value ==
                                      DeliveryTypeEnum.deliver) {
                                if (deliveryLocationData == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text(tr("d_a_n_specified"))));
                                  return;
                                } else if (deliveryLocationData.address ==
                                    null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text(tr("d_a_n_specified"))));
                                  return;
                                }
                              }

                              if (isInStock) {
                                return;
                              }

                              addToBasket();
                            },
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                )),
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        AppColors.mainColor),
                                padding: MaterialStateProperty.all(
                                    const EdgeInsets.all(0))),
                            child: _isBasketLoading.value
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(productPrice,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500)),
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
