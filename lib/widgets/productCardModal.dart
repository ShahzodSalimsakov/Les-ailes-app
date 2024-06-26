import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:hive/hive.dart';
import 'package:les_ailes/models/productSection.dart';
import 'package:http/http.dart' as http;

import '../models/basket.dart';
import '../models/basket_data.dart';
import '../models/related_product.dart';
import '../models/user.dart';
import '../utils/colors.dart';
import '../utils/simplified_url.dart';

class ProductCardModal extends HookWidget {
  Items? product;

  ProductCardModal({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final relatedBiData =
        useState<List<RelatedProduct>>(List<RelatedProduct>.empty());
    final topProducts =
        useState<List<RelatedProduct>>(List<RelatedProduct>.empty());
    final _isBasketLoading = useState<bool>(false);
    final basketData = useState<BasketData?>(null);
    final isMounted = useValueNotifier<bool>(true);

    Future<void> fetchBiRecomendedItems() async {
      _isBasketLoading.value = true;
      List<String> productIds = [product!.id.toString()];

      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json'
      };

      var url = SimplifiedUri.uri(
          'https://api.lesailes.uz/api/baskets/bi_related/',
          {"productIds": productIds});
      var response = await http.get(url, headers: requestHeaders);
      if (response.statusCode == 200 || response.statusCode == 201) {
        var json = jsonDecode(response.body);
        if (isMounted.value) {
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
            _isBasketLoading.value = false;
          }
        }
      }
    }

    useEffect(() {
      fetchBiRecomendedItems();
      return () {
        isMounted.value = false;
      };
    }, []);

    var locale = context.locale.toString();
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

    return Container(
      height: MediaQuery.of(context).size.height * 0.80,
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
        topLeft: Radius.circular(40.0),
        topRight: Radius.circular(40.0),
      ), 
      color: Colors.white
      ),
      // height: 200,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildHandle(context),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                attributeDataName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: attributeDataDesc.isNotEmpty
                ? MainAxisAlignment.spaceEvenly
                : MainAxisAlignment.center,
            children: [
              CachedNetworkImage(
                imageUrl: product!.image!,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    CircularProgressIndicator(
                        value: downloadProgress.progress,
                        color: AppColors.mainColor),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                // height: 200,
                width: 200,
              ),
              SizedBox(
                width: attributeDataDesc.isNotEmpty ? 160 : 0,
                child: Html(
                  data: attributeDataDesc,
                  shrinkWrap: true,
                ),
              ),
            ],
          ),
          relatedBiData.value.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(
                      top: 10, bottom: 10, left: 30, right: 30),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(tr('buyWithThisProduct'),
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w500))),
                )
              : const SizedBox(),
          relatedBiData.value.isNotEmpty
              ? Padding(
                  padding:
                      const EdgeInsets.only(bottom: 30, left: 30, right: 30),
                  child: SizedBox(
                    height: 240,
                    child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: relatedBiData.value.length,
                        itemBuilder: (context, index) {
                          final formatCurrency = NumberFormat.currency(
                              locale: 'ru_RU',
                              symbol: locale == 'uz'
                                  ? "so'm"
                                  : locale == 'en'
                                      ? 'sum'
                                      : "сум",
                              decimalDigits: 0);
                          String productPrice = '';
                          productPrice = relatedBiData.value[index].price;
                          productPrice = formatCurrency
                              .format(double.tryParse(productPrice));
                          return Container(
                              width: 140,
                              margin: const EdgeInsets.only(right: 10),
                              child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: Colors.white,
                                  ),
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Image.network(
                                          relatedBiData.value[index].image,
                                          height: 100,
                                          width: 100,
                                        ),
                                        const Spacer(
                                          flex: 1,
                                        ),
                                        Text(
                                          relatedBiData.value[index].customName,
                                          style: const TextStyle(fontSize: 16),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 3,
                                        ),
                                        const Spacer(
                                          flex: 1,
                                        ),
                                        SizedBox(
                                          height: 50,
                                          width: 144,
                                          child: _isBasketLoading.value ? const Center(child: CircularProgressIndicator(color: AppColors.mainColor,)) : ElevatedButton(
                                            onPressed: () async {
                                              
            _isBasketLoading.value = true;
                                              List<Map<String, int>>?
                                                  selectedModifiers;

                                              int selectedProdId =
                                                  relatedBiData.value[index].id;

                                              Box userBox =
                                                  Hive.box<User>('user');
                                              User? user = userBox.get('user');
                                              Box basketBox =
                                                  Hive.box<Basket>('basket');
                                              Basket? basket =
                                                  basketBox.get('basket');

                                              if (basket != null &&
                                                  basket.encodedId.isNotEmpty &&
                                                  basket.encodedId.isNotEmpty) {
                                                Map<String, String>
                                                    requestHeaders = {
                                                  'Content-type':
                                                      'application/json',
                                                  'Accept': 'application/json'
                                                };

                                                if (user != null) {
                                                  requestHeaders[
                                                          'Authorization'] =
                                                      'Bearer ${user.userToken}';
                                                }

                                                var url = Uri.https(
                                                    'api.lesailes.uz',
                                                    '/api/baskets-lines');
                                                var formData = {
                                                  'basket_id': basket.encodedId,
                                                  'variants': [
                                                    {
                                                      'id': selectedProdId,
                                                      'quantity': 1,
                                                      'modifiers':
                                                          selectedModifiers
                                                    }
                                                  ]
                                                };
                                                var response = await http.post(
                                                    url,
                                                    headers: requestHeaders,
                                                    body: jsonEncode(formData));
                                                if (response.statusCode ==
                                                        200 ||
                                                    response.statusCode ==
                                                        201) {
                                                  var json =
                                                      jsonDecode(response.body);
                                                  BasketData basketLocalData =
                                                      BasketData.fromJson(
                                                          json['data']);
                                                  Basket newBasket = Basket(
                                                      encodedId: basketLocalData
                                                              .encodedId ??
                                                          '',
                                                      lineCount: basketLocalData
                                                              .lines?.length ??
                                                          0,
                                                      totalPrice:
                                                          basketLocalData
                                                              .total);
                                                  basketBox.put(
                                                      'basket', newBasket);
                                                  basketData.value =
                                                      basketLocalData;
                                                }
                                              } else {
                                                Map<String, String>
                                                    requestHeaders = {
                                                  'Content-type':
                                                      'application/json',
                                                  'Accept': 'application/json'
                                                };

                                                if (user != null) {
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
                                                      'id': selectedProdId,
                                                      'quantity': 1,
                                                      'modifiers':
                                                          selectedModifiers
                                                    }
                                                  ]
                                                };
                                                var response = await http.post(
                                                    url,
                                                    headers: requestHeaders,
                                                    body: jsonEncode(formData));
                                                if (response.statusCode ==
                                                        200 ||
                                                    response.statusCode ==
                                                        201) {
                                                  var json =
                                                      jsonDecode(response.body);
                                                  BasketData basketLocalData =
                                                      BasketData.fromJson(
                                                          json['data']);
                                                  Basket newBasket = Basket(
                                                      encodedId: basketLocalData
                                                              .encodedId ??
                                                          '',
                                                      lineCount: basketLocalData
                                                              .lines?.length ??
                                                          0,
                                                      totalPrice:
                                                          basketLocalData
                                                              .total);
                                                  basketBox.put(
                                                      'basket', newBasket);
                                                  basketData.value =
                                                      basketLocalData;
                                                }
                                              }
                                              
            _isBasketLoading.value = false;
                                              Flushbar(
                                                title: tr('product'),
                                                message: tr('addedToBasket'),
                                                duration: const Duration(seconds: 1),
                                                flushbarPosition:
                                                    FlushbarPosition.BOTTOM,
                                              ).show(context);
                                              return;
                                            },
                                            style: ButtonStyle(
                                              shape: MaterialStateProperty.all<
                                                      RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(18.0),
                                              )),
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                          Color>(
                                                      AppColors.mainColor),
                                                      padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                                            ),
                                            child: Text(productPrice, style: const TextStyle(color: Colors.white),),
                                          ),
                                        )
                                      ])));
                        }),
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(
                  color: AppColors.mainColor,
                )),
        ],
      ),
    );
  }
}
