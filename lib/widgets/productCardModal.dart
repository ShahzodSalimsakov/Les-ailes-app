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
import 'package:shimmer/shimmer.dart';

import '../models/basket.dart';
import '../models/basket_data.dart';
import '../models/related_product.dart';
import '../models/user.dart';
import '../utils/colors.dart';
import '../utils/simplified_url.dart';
import 'basket.dart';

class ProductCardModal extends HookWidget {
  Items? product;

  ProductCardModal({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final relatedBiData =
        useState<List<RelatedProduct>>(List<RelatedProduct>.empty());
    final topProducts =
        useState<List<RelatedProduct>>(List<RelatedProduct>.empty());
    final loadingStates = useState<Map<int, bool>>({});
    final isMounted = useRef(true);
    final scrollController = useScrollController();
    final isImageLoading = useState(true);
    final quantity = useState<int>(1);
    final isInCart = useState(false);

    // Анимация для появления модального окна
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 300),
      initialValue: 0,
    );
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOut,
    ));

    useEffect(() {
      animationController.forward();
      return null;
    }, []);

    useEffect(() {
      isMounted.value = true;
      return () {
        isMounted.value = false;
      };
    }, []);

    Future<void> fetchBiRecomendedItems() async {
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

    Future<void> _updateBasket(http.Response response) async {
      if (!isMounted.value) return;
      var json = jsonDecode(response.body);
      BasketData basketData = BasketData.fromJson(json['data']);
      Box basketBox = Hive.box<Basket>('basket');
      await basketBox.put(
          'basket',
          Basket(
              encodedId: basketData.encodedId ?? '',
              lineCount: basketData.lines?.length ?? 0,
              totalPrice: basketData.total));
      isInCart.value = true;
    }

    void _showSuccessMessage(BuildContext context) {
      Flushbar(
        title: tr('product'),
        message: tr('addedToBasket'),
        duration: const Duration(seconds: 1),
        flushbarPosition: FlushbarPosition.BOTTOM,
        backgroundColor: AppColors.green,
      ).show(context);
    }

    void _showErrorMessage(BuildContext context) {
      Flushbar(
        title: tr('error'),
        message: tr('errorAddingToBasket'),
        duration: const Duration(seconds: 2),
        flushbarPosition: FlushbarPosition.BOTTOM,
        backgroundColor: AppColors.mainColor,
      ).show(context);
    }

    void _navigateToCart(BuildContext context) {
      if (!isMounted.value) return;
      Navigator.of(context).pop();
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const BasketWidget(),
      );
    }

    Future<void> addToBasket(int productId, int index) async {
      if (loadingStates.value[productId] == true || !isMounted.value) return;

      try {
        loadingStates.value = {...loadingStates.value, productId: true};

        Box userBox = Hive.box<User>('user');
        User? user = userBox.get('user');
        Box basketBox = Hive.box<Basket>('basket');
        Basket? basket = basketBox.get('basket');

        Map<String, String> requestHeaders = {
          'Content-type': 'application/json',
          'Accept': 'application/json'
        };

        if (user != null) {
          requestHeaders['Authorization'] = 'Bearer ${user.userToken}';
        }

        if (basket != null && basket.encodedId.isNotEmpty) {
          // Добавление в существующую корзину
          var url = Uri.https('api.lesailes.uz', '/api/baskets-lines');
          var response = await http.post(url,
              headers: requestHeaders,
              body: jsonEncode({
                'basket_id': basket.encodedId,
                'variants': [
                  {'id': productId, 'quantity': 1, 'modifiers': null}
                ]
              }));

          if (response.statusCode == 200 || response.statusCode == 201) {
            await _updateBasket(response);
            _showSuccessMessage(context);
          } else {
            _showErrorMessage(context);
          }
        } else {
          // Создание новой корзины
          var url = Uri.https('api.lesailes.uz', '/api/baskets');
          var response = await http.post(url,
              headers: requestHeaders,
              body: jsonEncode({
                'variants': [
                  {'id': productId, 'quantity': 1, 'modifiers': null}
                ]
              }));

          if (response.statusCode == 200 || response.statusCode == 201) {
            await _updateBasket(response);
            _showSuccessMessage(context);
          } else {
            _showErrorMessage(context);
          }
        }
      } catch (e) {
        _showErrorMessage(context);
      } finally {
        if (isMounted.value) {
          loadingStates.value = {...loadingStates.value, productId: false};
        }
      }
    }

    Widget _buildRelatedProductCard(
        RelatedProduct relatedProduct, int index, String locale) {
      final formatCurrency = NumberFormat.currency(
          locale: 'ru_RU',
          symbol: locale == 'uz'
              ? "so'm"
              : locale == 'en'
                  ? 'sum'
                  : "сум",
          decimalDigits: 0);

      String productPrice =
          formatCurrency.format(double.tryParse(relatedProduct.price));
      bool isLoading = loadingStates.value[relatedProduct.id] ?? false;

      return Container(
        width: 140,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
              ),
              child: CachedNetworkImage(
                imageUrl: relatedProduct.image,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(
                    color: AppColors.mainColor,
                  ),
                ),
                errorWidget: (context, url, error) => Center(
                  child: Icon(Icons.error, color: Colors.red),
                ),
              ),
            ),
            const Spacer(flex: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                relatedProduct.customName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
            const Spacer(flex: 1),
            SizedBox(
              height: 50,
              width: 120,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () => addToBasket(relatedProduct.id, index),
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  )),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(AppColors.mainColor),
                  padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        productPrice,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      );
    }

    return SlideTransition(
      position: slideAnimation,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.80,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40.0),
            topRight: Radius.circular(40.0),
          ),
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              product?.attributeData?.name?.chopar?.getLocalizedText(context) ??
                  '',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Hero(
                            tag: 'product_${product?.id}',
                            child: CachedNetworkImage(
                              imageUrl: product?.image ?? '',
                              height: 200,
                              width: 200,
                              fit: BoxFit.contain,
                              placeholder: (context, url) => Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.mainColor,
                                ),
                              ),
                              errorWidget: (context, url, error) => Center(
                                child: Icon(Icons.error, color: Colors.red),
                              ),
                            ),
                          ),
                          if (product?.attributeData?.description?.chopar
                                  ?.getLocalizedText(context)
                                  .isNotEmpty ??
                              false)
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Html(
                                  data: product
                                          ?.attributeData?.description?.chopar
                                          ?.getLocalizedText(context) ??
                                      '',
                                  style: {
                                    "body": Style(
                                      fontSize: FontSize(16),
                                      color: Colors.grey[800],
                                    ),
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (relatedBiData.value.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Row(
                          children: [
                            Text(
                              tr('buyWithThisProduct'),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 240,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: relatedBiData.value.length,
                          itemBuilder: (context, index) =>
                              _buildRelatedProductCard(
                            relatedBiData.value[index],
                            index,
                            context.locale.toString(),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension LocalizedText on dynamic {
  String getLocalizedText(BuildContext context) {
    if (this == null) return '';

    final locale = context.locale.toString();

    switch (locale) {
      case 'uz':
        return this.uz ?? this.ru ?? '';
      case 'en':
        return this.en ?? this.ru ?? '';
      default:
        return this.ru ?? '';
    }
  }
}
