import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:les_ailes/widgets/productCard.dart';

import '../models/basket.dart';
import '../models/basket_data.dart';
import '../models/basket_item_quantity.dart';
import '../models/productSection.dart';

class ProductCardList extends HookWidget {
  final List<Items>? products;

  ProductCardList(this.products);

  @override
  Widget build(BuildContext context) {
    // final basketData = useState<BasketData?>(null);
    // Box<Basket> basketBox = Hive.box<Basket>('basket');
    // Basket? basket = basketBox.get('basket');
    // Future<void> getBasket() async {
    //   if (basket != null) {
    //   Map<String, String> requestHeaders = {
    //     'Content-type': 'application/json',
    //     'Accept': 'application/json'
    //   };
    //
    //   var url =
    //   Uri.https('api.lesailes.uz', '/api/baskets/${basket!.encodedId}');
    //   var response = await http.get(url, headers: requestHeaders);
    //   if (response.statusCode == 200 || response.statusCode == 201) {
    //     var json = jsonDecode(response.body);
    //     BasketData basketLocalData = BasketData.fromJson(json['data']);
    //     if (basketLocalData.lines != null) {
    //       basket.lineCount = basketLocalData.lines!.length;
    //       basketBox.put('basket', basket);
    //     }
    //     basketData.value = basketLocalData;
    //   }
    //   }
    // }
    // useEffect(() {
    //   getBasket();
    //   return null;
    // }, [basket?.totalPrice]);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products?.length ?? 0,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: (164 / 300),
          crossAxisSpacing: 15,
          mainAxisSpacing: 20),
      itemBuilder: (context, indx) {
        Items? product = products?[indx];
        return ValueListenableBuilder<Box<BasketItemQuantity>>(
            valueListenable:
                Hive.box<BasketItemQuantity>('basketItemQuantity').listenable(),
            builder: (context, box, _) {
              return ProductCard(product!);
            });
      },
    );
  }
}
