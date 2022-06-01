import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:les_ailes/models/basket_item_quantity.dart';
import 'package:les_ailes/widgets/productCardList.dart';
import 'package:les_ailes/widgets/slider.dart';
import 'package:les_ailes/widgets/way_to_receive_an_order.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:scrolls_to_top/scrolls_to_top.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';
import 'package:vertical_scrollable_tabview/vertical_scrollable_tabview.dart';

import '../models/basket.dart';
import '../models/productSection.dart';
import '../utils/colors.dart';
import 'ChooseCity.dart';
import 'header.dart';

class ProductTabListStateful extends StatefulWidget {
  List<ProductSection> products;
  ProductTabListStateful({Key? key, required this.products}) : super(key: key);

  @override
  State<ProductTabListStateful> createState() => _ProductListStatefulState();
}

class _ProductListStatefulState extends State<ProductTabListStateful>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int scrolledIndex = 0;


  double getProductHeight(ProductSection section) {
    double height = 200;

    if (section.halfMode == 1) {
      height = 260;
    } else {
      if (section.items != null && section.items!.isNotEmpty) {
        height = ((section.items!.length * 330) / 2) + 250;
      }
    }
    print('Height $height');
    return height;
  }

  @override
  void initState() {
    _tabController = TabController(length: widget.products.length, vsync: this, initialIndex: 0);
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  Widget getProductSection(ProductSection section, BuildContext context) {
    var locale = context.locale.toString();
    var attributeDataName = '';
    switch (locale) {
      // case 'en':
      //   attributeDataName  = products.value[index].attributeData?.name?.chopar?.en ?? '';
      //   break;
      case 'uz':
        attributeDataName = section.attributeData?.name?.chopar?.uz ?? '';
        break;
      default:
        attributeDataName = section.attributeData?.name?.chopar?.ru ?? '';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              attributeDataName,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.w500),
            ),
          ),
          ProductCardList(section.items)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ScrollsToTop(
        onScrollsToTop: (ScrollsToTopEvent event) async {
          _tabController.animateTo(
            0,
            duration: const Duration(milliseconds: 100),
          );
        },
        child: VerticalScrollableTabView(
            tabController: _tabController,
            listItemData: widget.products,
            verticalScrollPosition: VerticalScrollPosition.begin,
            slivers: [
              SliverAppBar(
                pinned: true,
                // floating: false,
                expandedHeight: 450.0,
                backgroundColor: Colors.white,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Header(),
                  titlePadding: const EdgeInsets.all(0),
                  centerTitle: true,
                  collapseMode: CollapseMode.pin,
                  background: Container(
                    margin: const EdgeInsets.only(top: 55, left: 10, right: 10),
                    child: Column(
                      children: [
                        const ChooseCity(),
                        const WayToReceiveAnOrder(),
                        SliderCarousel(),
                      ],
                    ),
                  ),
                  expandedTitleScale: 1,
                ),
                bottom: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(20),
                      color: AppColors.mainColor),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black,
                  isScrollable: true,
                  padding: const EdgeInsets.all(5),
                  tabs: widget.products.map((section) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      child: Text(
                        section.attributeData?.name?.chopar?.ru ?? '',
                      ),
                    );
                  }).toList(),
                  onTap: (index) {
                    VerticalScrollableTabBarStatus.setIndex(index);
                  },
                ),
              ),
            ],
            eachItemChild: (object, index) =>
                getProductSection(object as ProductSection, context)),
      ),
    );
  }
}
