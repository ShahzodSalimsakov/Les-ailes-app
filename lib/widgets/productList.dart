import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:les_ailes/utils/colors.dart';
import 'package:http/http.dart' as http;
import 'package:les_ailes/widgets/productCard.dart';
import 'package:sticky_headers/sticky_headers.dart';
import '../models/basket.dart';
import '../models/productSection.dart';

class ProductList extends HookWidget {
  const ProductList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final products =
        useState<List<ProductSection>>(List<ProductSection>.empty());
    Future<void> getProducts() async {
      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json'
      };
      var url = Uri.https(
          'api.lesailes.uz', '/api/products/public', {'perSection': '1'});
      var response = await http.get(url, headers: requestHeaders);
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        List<ProductSection> productSections = List<ProductSection>.from(
            json['data'].map((m) => ProductSection.fromJson(m)).toList());
        products.value = productSections;
      }
    }

    useEffect(() {
      getProducts();
    }, []);

    Widget _productSection(BuildContext context, int index) {
      var locale = context.locale.toString();
      var attributeDataName = '';
      switch (locale) {
        // case 'en':
        //   attributeDataName  = products.value[index].attributeData?.name?.chopar?.en ?? '';
        //   break;
        case 'uz':
          attributeDataName =
              products.value[index].attributeData?.name?.chopar?.uz ?? '';
          break;
        default:
          attributeDataName =
              products.value[index].attributeData?.name?.chopar?.ru ?? '';
          break;
      }
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        margin: const EdgeInsets.only(right: 6),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: AppColors.grey),
        child: Center(
            child: Text(
          attributeDataName,
          style: const TextStyle(
              fontSize: 18, color: Colors.black, fontWeight: FontWeight.w500),
        )),
      );
    }

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

    return Column(
      children: [
        const SizedBox(height: 24),
        SizedBox(
          height: 40,
          child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: products.value.length,
              itemBuilder: _productSection),
        ),
        const SizedBox(height: 24),
        ListView.builder(
          itemCount: products.value.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            var locale = context.locale.toString();
            var attributeDataName = '';
            switch (locale) {
              // case 'en':
              //   attributeDataName  = products.value[index].attributeData?.name?.chopar?.en ?? '';
              //   break;
              case 'uz':
                attributeDataName =
                    products.value[index].attributeData?.name?.chopar?.uz ?? '';
                break;
              default:
                attributeDataName =
                    products.value[index].attributeData?.name?.chopar?.ru ?? '';
                break;
            }
            return StickyHeader(
              header: Container(
                margin: const EdgeInsets.only(top: 30, bottom: 20),
                height: 38.0,
                alignment: Alignment.centerLeft,
                child: Text(
                  attributeDataName,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.w500),
                ),
              ),
              content: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.value[index].items?.length ?? 0,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: (164 / 300),
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 20),
                itemBuilder: (context, indx) {
                  Items? product = products.value[index].items?[indx];
                  return ProductCard(product!);
                },
              ),
            );
          },
          shrinkWrap: true,
        )
      ],
    );
  }
}
