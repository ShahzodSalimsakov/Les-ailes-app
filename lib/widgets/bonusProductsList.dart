import 'package:flutter/material.dart';
import 'package:les_ailes/utils/colors.dart';
import 'dart:ui';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:easy_localization/easy_localization.dart';

import '../models/productSection.dart';
import '../models/basket.dart';

class BonusProductsList extends StatefulWidget {
  final List<Items> bonusItems;
  final int parentProductId;
  const BonusProductsList({
    super.key,
    required this.bonusItems,
    required this.parentProductId,
  });

  @override
  State<BonusProductsList> createState() => _BonusProductsListState();
}

class _BonusProductsListState extends State<BonusProductsList>
    with SingleTickerProviderStateMixin {
  // Track selected product (only one can be selected)
  int? _selectedProductIndex;
  bool _isLoading = false;

  // Animation controller for selection effects
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _addBonusToBasket() async {
    if (_selectedProductIndex == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final selectedItem = widget.bonusItems[_selectedProductIndex!];

      // Get basket ID from Hive
      Box<Basket> basketBox = Hive.box<Basket>('basket');
      Basket? basket = basketBox.get('basket');

      if (basket == null || basket.encodedId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("bonusList.basket_not_found".tr()),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // Prepare request
      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json'
      };

      var url = Uri.https('api.lesailes.uz', '/api/baskets/bonus_product');
      var requestBody = jsonEncode({
        'parentProductId': widget.parentProductId,
        'productId': selectedItem.id,
        'basketId': basket.encodedId,
      });

      // Make API call
      var response = await http.post(
        url,
        headers: requestHeaders,
        body: requestBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("bonusList.added_to_basket"
                .tr(args: [_getLocalizedProductName(selectedItem, context)])),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        // Close the modal
        Navigator.of(context).pop();
      } else {
        // Error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("bonusList.failed_to_add"
                .tr(args: [response.statusCode.toString()])),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Exception
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("bonusList.error".tr(args: [e.toString()])),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Stack(
        children: [
          // Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "bonusList.choose_bonus_item".tr(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "bonusList.select_complimentary_item".tr(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Grid of products
          Padding(
            padding: const EdgeInsets.only(top: 100, bottom: 80),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: widget.bonusItems.length,
              itemBuilder: (context, index) {
                final item = widget.bonusItems[index];
                final isSelected = _selectedProductIndex == index;

                if (isSelected) {
                  _animationController.forward();
                } else {
                  _animationController.reverse();
                }

                return AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: isSelected ? _scaleAnimation.value : 1.0,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedProductIndex = null;
                            } else {
                              _selectedProductIndex = index;
                            }
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? AppColors.mainColor.withOpacity(0.3)
                                    : Colors.black.withOpacity(0.05),
                                blurRadius: isSelected ? 12 : 4,
                                spreadRadius: isSelected ? 2 : 0,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: isSelected
                                ? Border.all(
                                    color: AppColors.mainColor, width: 2)
                                : null,
                          ),
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(isSelected ? 14 : 16),
                            child: Stack(
                              children: [
                                // Product content
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Product image
                                    Expanded(
                                      flex: 3,
                                      child: Hero(
                                        tag: 'bonus_product_${item.id}',
                                        child: Container(
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: NetworkImage(item.image ??
                                                  'https://via.placeholder.com/150'),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Product info
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              _getLocalizedProductName(
                                                  item, context),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "bonusList.free".tr(),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.mainColor,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // Selection overlay
                                if (isSelected)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            AppColors.mainColor
                                                .withOpacity(0.1),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                // Selection badge
                                if (isSelected)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: AppColors.mainColor,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.mainColor
                                                .withOpacity(0.5),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Fixed button at the bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 56,
                decoration: BoxDecoration(
                  color: _selectedProductIndex == null
                      ? Colors.grey.shade300
                      : AppColors.mainColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _selectedProductIndex != null
                      ? [
                          BoxShadow(
                            color: AppColors.mainColor.withOpacity(0.4),
                            blurRadius: 12,
                            spreadRadius: 0,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _selectedProductIndex == null || _isLoading
                        ? null
                        : _addBonusToBasket,
                    borderRadius: BorderRadius.circular(16),
                    child: Center(
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.0, 0.5),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                              child: _selectedProductIndex == null
                                  ? Text(
                                      "bonusList.select_bonus_item".tr(),
                                      key: const ValueKey('select'),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54,
                                      ),
                                    )
                                  : Row(
                                      key: const ValueKey('add'),
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.add_shopping_cart,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "bonusList.add_to_basket".tr(),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getLocalizedProductName(Items item, BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    String attributeDataName = '';

    switch (locale) {
      case 'uz':
        attributeDataName = item.attributeData?.name?.chopar?.uz ?? '';
        break;
      case 'ru':
        attributeDataName = item.attributeData?.name?.chopar?.ru ?? '';
        break;
      case 'en':
        attributeDataName = item.attributeData?.name?.chopar?.en ?? '';
        break;
      default:
        attributeDataName = item.attributeData?.name?.chopar?.ru ?? '';
        break;
    }

    return attributeDataName.isNotEmpty
        ? attributeDataName
        : (item.customName ?? 'Unknown Product');
  }
}
