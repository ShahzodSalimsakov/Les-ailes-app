import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:les_ailes/models/basket_item_quantity.dart';
import 'package:les_ailes/widgets/productCardList.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:scrolls_to_top/scrolls_to_top.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

import '../models/basket.dart';
import '../models/productSection.dart';
import '../utils/colors.dart';

class ProductTabListStateful extends StatefulWidget {
  final ScrollController parentScrollController;

  const ProductTabListStateful({Key? key, required this.parentScrollController})
      : super(key: key);

  @override
  State<ProductTabListStateful> createState() => _ProductListStatefulState();
}

class _ProductListStatefulState extends State<ProductTabListStateful> {
  List<GlobalKey> categories = [];
  late ScrollController scrollCont;
  BuildContext? tabContext;

  // ItemScrollController itemScrollController = ItemScrollController();
  // ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  // ItemScrollController verticalScrollController = ItemScrollController();
  // ItemPositionsListener verticalPositionsListener =
  //     ItemPositionsListener.create();
  List<ProductSection> products = List<ProductSection>.empty();
  int scrolledIndex = 0;

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
      List<GlobalKey> localCategories = [];
      for (var i = 0; i < productSections.length; i++) {
        localCategories.add(GlobalKey());
      }
      setState(() {
        products = productSections;
        categories = localCategories;
        scrollCont.addListener(changeTabs);
      });
    }
  }

  double getProductHeight(ProductSection section) {
    double height = 200;

    if (section.halfMode == 1) {
      height = 260;
    } else {
      if (section.items != null && section.items!.length > 0) {
        height = ((section.items!.length * 330) / 2) + 250;
      }
    }
    print('Height $height');
    return height;
  }

  changeTabs() {
    late RenderBox box;
    int scrolledIndex = 0;
    late Offset position;
    for (var i = 0; i < categories.length; i++) {
      box = categories[i].currentContext!.findRenderObject() as RenderBox;
      position = box.localToGlobal(Offset.zero);
      // print('Scroll ${scrollCont.offset}');
      // print('Position ${position.dy}');
      // Scrollable.of(tabContext!).v
      if (scrollCont.offset >= position.dy && position.dy < 250) {
        scrolledIndex = i;
        position = box.localToGlobal(Offset.zero);
      }
    }
    // print(scrolledIndex);
    // print(scrollCont.offset);
    // print(widget.parentScrollController.position.maxScrollExtent);
    if (scrolledIndex == 0) {
      if (scrollCont.offset == 0) {
        widget.parentScrollController.animateTo(0.0,
            duration: Duration(milliseconds: 100), curve: Curves.easeIn);
      } else {
        widget.parentScrollController.animateTo(
            widget.parentScrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 100),
            curve: Curves.easeIn);
      }
    }
    DefaultTabController.of(tabContext!)!.animateTo(
      scrolledIndex,
      duration: Duration(milliseconds: 100),
    );
  }

  scrollTo(int index) async {
    scrollCont.removeListener(changeTabs);
    final category = categories[index].currentContext!;
    await Scrollable.ensureVisible(
      category,
      duration: Duration(milliseconds: 600),
    );
    scrollCont.addListener(changeTabs);
  }

  // scrollListening() {
  //   // print('listened');
  //   // print(verticalPositionsListener.itemPositions.value);
  //   verticalPositionsListener.itemPositions.addListener(() {
  //     ItemPosition min;
  //     // print(verticalPositionsListener.itemPositions.value);
  //     if (verticalPositionsListener.itemPositions.value.isNotEmpty) {
  //       min = verticalPositionsListener.itemPositions.value.first;
  //       // print('Min Index $min');
  //       // print('Products count ${products.length}');
  //       // print(widget.parentScrollController.position.pixels);
  //       // print(widget.parentScrollController.position.maxScrollExtent);
  //       if (min.itemLeadingEdge < 0 &&
  //           widget.parentScrollController.position.maxScrollExtent !=
  //               widget.parentScrollController.position.pixels) {
  //         widget.parentScrollController.animateTo(
  //             widget.parentScrollController.position.maxScrollExtent,
  //             duration: const Duration(milliseconds: 200),
  //             curve: Curves.easeIn);
  //       } else if (min.itemLeadingEdge == 0 && min.index == 0 &&
  //           widget.parentScrollController.position.pixels != 0.0) {
  //         widget.parentScrollController.animateTo(0.0,
  //             duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
  //       }
  //
  //       itemScrollController.scrollTo(
  //           index: min.index,
  //           duration: const Duration(milliseconds: 200),
  //           curve: Curves.easeInOutCubic,
  //           alignment: 0.02);
  //
  //       if (scrolledIndex != min.index) {
  //         Future.delayed(const Duration(milliseconds: 200), () {
  //           setState(() {
  //             scrolledIndex = min.index;
  //           });
  //         });
  //       }
  //     }
  //   });
  // }

  @override
  void initState() {
    getProducts();
    scrollCont = ScrollController();
    // TODO: implement initState
    super.initState();
    // itemScrollController = ItemScrollController();
    // itemPositionsListener = ItemPositionsListener.create();
    // verticalScrollController = ItemScrollController();
    // verticalPositionsListener = ItemPositionsListener.create();
    // scrollListening();
  }

  @override
  void dispose() {
    // verticalPositionsListener.itemPositions.removeListener(() {});
    // TODO: implement dispose
    super.dispose();
  }

  Widget productSection(BuildContext context, int index) {
    var locale = context.locale.toString();
    var attributeDataName = '';
    switch (locale) {
      // case 'en':
      //   attributeDataName  = products.value[index].attributeData?.name?.chopar?.en ?? '';
      //   break;
      case 'uz':
        attributeDataName =
            products[index].attributeData?.name?.chopar?.uz ?? '';
        break;
      default:
        attributeDataName =
            products[index].attributeData?.name?.chopar?.ru ?? '';
        break;
    }
    return GestureDetector(
      onTap: () {
        // verticalScrollController.scrollTo(
        //     index: index,
        //     duration: const Duration(milliseconds: 300),
        //     curve: Curves.easeInOutCubic,
        //     alignment: 0.0005);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        margin: const EdgeInsets.only(right: 6),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color:
                scrolledIndex == index ? AppColors.mainColor : AppColors.grey),
        child: Center(
            child: Text(
          attributeDataName,
          style: TextStyle(
              fontSize: 18,
              color: scrolledIndex == index ? Colors.white : Colors.black,
              fontWeight: FontWeight.w500),
        )),
      ),
    );
  }

  List<Widget> getSectionsList() {
    List<Widget> sections = [];

    products.asMap().forEach((index,section) {
      sections.add(Padding(
        key: categories[index],
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child:Text(
          section.attributeData?.name?.chopar?.ru ?? '',
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 30,
                            fontWeight: FontWeight.w500),
                      ),
      ));

        sections.add(ProductCardList(section.items));
    });

    return sections;
  }

  @override
  Widget build(BuildContext context) {
    return ScrollsToTop(
      onScrollsToTop: (ScrollsToTopEvent event) async {
        scrollTo(0);
        DefaultTabController.of(tabContext!)!.animateTo(
          0,
          duration: const Duration(milliseconds: 100),
        );
      },
      child: DefaultTabController(
          length: products.length,
          child: Builder(builder: (BuildContext context) {
            tabContext = context;
            return Expanded(
              child: Column(children: [
                const SizedBox(height: 24),
                SizedBox(
                  child: TabBar(
                    indicator: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(20),
                        color: AppColors.mainColor
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black,
                    isScrollable: true,
                    tabs: products.map((section) {
                      return Text(
                        section.attributeData?.name?.chopar?.ru ?? '',
                      );
                    }).toList(),
                    onTap: (int index) => scrollTo(index),
                  ),
                  height: 40,
                ),
                const SizedBox(height: 5,),
                Expanded(
                    child: SingleChildScrollView(
                        controller: scrollCont,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: getSectionsList()))),
                // SizedBox(
                //   child: ScrollablePositionedList.builder(
                //     itemCount: products.length,
                //     itemBuilder: productSection,
                //     itemScrollController: itemScrollController,
                //     itemPositionsListener: itemPositionsListener,
                //     scrollDirection: Axis.horizontal,
                //   ),
                //   height: 40,
                // ),
                const SizedBox(height: 24),
                // Expanded(
                //     child: ScrollablePositionedList.builder(
                //   shrinkWrap: true,
                //   itemCount: products.length,
                //   itemBuilder: (context, index) {
                //     var locale = context.locale.toString();
                //     var attributeDataName = '';
                //     switch (locale) {
                //       // case 'en':
                //       //   attributeDataName  = products.value[index].attributeData?.name?.chopar?.en ?? '';
                //       //   break;
                //       case 'uz':
                //         attributeDataName =
                //             products[index].attributeData?.name?.chopar?.uz ?? '';
                //         break;
                //       default:
                //         attributeDataName =
                //             products[index].attributeData?.name?.chopar?.ru ?? '';
                //         break;
                //     }
                //     return SizedBox(
                //         height: getProductHeight(products[index]),
                //         width: double.infinity,
                //         child: Column(
                //             crossAxisAlignment: CrossAxisAlignment.start,
                //             children: [
                //               Text(
                //                 products[index].attributeData?.name?.chopar?.ru ?? '',
                //                 style: const TextStyle(
                //                     color: Colors.black,
                //                     fontSize: 30,
                //                     fontWeight: FontWeight.w500),
                //               ),
                //               const SizedBox(height: 10,),
                //               ProductCardList(products[index].items),
                //             ]));
                //   },
                //   itemScrollController: verticalScrollController,
                //   itemPositionsListener: verticalPositionsListener,
                //   scrollDirection: Axis.vertical,
                // ))
              ]),
            );
          })),
    );
  }
}
